//
//  Thermometer.m
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import "Thermometer.h"
#import "ThermometerCell.h"
#import "TempReading.h"

@implementation Thermometer

-(id)initWithName:(NSString *)theName url:(NSString *)ustr;
{
	// Super initialization
    id rv=[super init];
	// Set the name
    name=theName;
    [name retain];
	// Set the update URL
    url=ustr;
    [url retain];
	// Initialize the array of previous readings
    lastReadings=[[NSMutableArray alloc] initWithCapacity: RING_BUFFER_SIZE];
	// Register for update notifications
	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(receivedUpdate:)
        name:[NSString stringWithFormat:@"update-%@", name]
        object:nil];

	// And return
    return(rv);
}

- (void)dealloc
{
    [lastReadings release];
    [name release];
    [super dealloc];
}

-(void)setValidReading:(float)r
{
    // Normal reading update stuff
    if(reading != r) {
        float oldreading=reading;
        reading=r;
        NSLog(@"Updated %@ (%.2f -> %.2f)", [self name], oldreading, reading);
        
		// Send the notification
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:DATA_UPDATED object:self];
    }

    // Keep the array small enough.
    while([lastReadings count] >= RING_BUFFER_SIZE) {
        [lastReadings removeLastObject];
    }
    // Add the current reading
    NSNumber *n=[[NSNumber alloc] initWithFloat: r];
	TempReading *tr=[[TempReading alloc] initWithName:[self name] reading:r];
    [lastReadings insertObject:tr atIndex: 0];
    [tr release];
    
    // Check to see whether we're going up or down
    n=[lastReadings lastObject];
    // Remember the trend (upwards or downwards)
    trend=r - [n floatValue];
}

// Check for valid values
static bool isValidReading(float r)
{
    return( (r>-100) && (r<100) );
}

-(void)setReading:(float)r
{
    if(isValidReading(r)) {
        [self setValidReading: r];
    }
}

-(float)reading
{
    return(reading);
}

-(float)trend
{
    return(trend);
}

-(int)tag
{
    return(tag);
}

-(void)setTag:(int)to
{
    tag=to;
}

-(void)setName: (NSString *)n
{
    name=n;
    [name retain];
}

-(NSString *)name
{
    return(name);
}

-(NSString *)description
{
    NSString *rv = [NSString stringWithFormat: @"%@ %.2f", name, reading];
        
    return(rv);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error 
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);

    // release the connection, and the data object
    [connection release];
    [responseData release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData: data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // NSLog(@"Response complete");
	NSString *data=[[NSString alloc]
		initWithData:responseData encoding:NSASCIIStringEncoding];

	// Send an update notification with the remaining data.
	TempReading *tr=[[TempReading alloc] initWithName: [self name]
		reading:[data floatValue]];

	[[NSNotificationCenter defaultCenter]
		postNotificationName:[NSString
				stringWithFormat:@"update-%@", [tr name]]
			object:tr];
	
	[data release];
    [connection release];
    [responseData release];
}

-(void)update
{
    NSString *s=[[NSString alloc] initWithFormat: @"%@?temp=%@", url, name];
    NSURL *u=[[NSURL alloc] initWithString: s];
	
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:u
                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                    timeoutInterval:60.0];
    NSURLConnection *theConnection=[[NSURLConnection alloc]
        initWithRequest:theRequest delegate:self];
    if (theConnection != nil) {
        // Create the NSMutableData that will hold
        // the received data
        responseData=[[NSMutableData data] retain];
    } else {
        NSLog(@"Couldn't make connection for %@", url);
    }
	[s release];
	[u release];
}

-(void)receivedUpdate:(id)ob
{
	TempReading *tr=[ob object];
	[self setValidReading: [tr reading]];
}

-(NSArray *)lastReadings
{
    return(lastReadings);
}


@end
