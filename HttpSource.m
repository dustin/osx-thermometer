//
//  HttpSource.m
//  Thermometer
//
//  Created by Dustin Sallings on 2005/2/9.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "HttpSource.h"
#import "Thermometer.h"

#ifdef GNUSTEP
#import <URLConnection.h>
#define NSURLConnection URLConnection
#define NSURLRequest URLRequest
#define NSURLResponse URLResponse
#define NSURLRequestUseProtocolCachePolicy URLRequestUseProtocolCachePolicy
#endif

@interface HttpThermometer : Thermometer {
	NSURL *url;
	NSMutableData *responseData;
}
-(id)initWithName:(NSString *)theName url:(NSURL *)u;
-(void)update;
@end

@implementation HttpThermometer

-(id)initWithName:(NSString *)theName url:(NSURL *)u
{
	id rv=[super initWithName:theName];
	url=[u retain];
	return(rv);
}

-(void)dealloc
{
	[url release];
	[responseData release];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection
	didReceiveResponse:(NSURLResponse *)response
{
	// NSLog(@"Received response:  %@", response);
	[responseData setLength:0];
	NSLog(@"Received response, connection retain count is %d",
		[connection retainCount]);
}

- (void)connection:(NSURLConnection *)connection
	didFailWithError:(NSError *)error
{
	NSLog(@"Connection failed! Error - %@", error);
	[connection release];
	[responseData release];
	responseData=nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"Connection received data, retain count:  %d",
		[connection retainCount]);
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// NSLog(@"Response complete");
	NSString *dataStr=[[NSString alloc]
		initWithData:responseData encoding:NSASCIIStringEncoding];
	// Send an update notification with the remaining data.
	TempReading *tr=[[TempReading alloc] initWithName: [self name]
		reading:[dataStr floatValue]];

	[[NSNotificationCenter defaultCenter]
		postNotificationName:[NSString stringWithFormat:@"update-%@",
			[tr name]]
		object:tr];

	[dataStr release];
	NSLog(@"finished connection retain count:  %d", [connection retainCount]);
	[connection release];
	NSLog(@"released connection");
	[responseData release];
	NSLog(@"released response data");
	responseData=nil;
}

-(void)update
{
	// NSLog(@"Updating %@ from %@", self, url);
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
			cachePolicy:NSURLRequestUseProtocolCachePolicy
		timeoutInterval:60.0];
	NSURLConnection *theConnection=[[NSURLConnection alloc]
		initWithRequest:theRequest delegate:self];
	if(theConnection != nil) {
		NSLog(@"New connection retain count: %d", [theConnection retainCount]);
		responseData=[[NSMutableData data] retain];
	} else {
		NSLog(@"Couldn't make a connection for %@", url);
	}
}

@end

@implementation HttpSource

-(id)initWithURL:(NSURL *)u
{
	id rv=[super initWithURL:u];
	NSArray *names=[self initThermList];
	if(names == nil) {
		[rv release];
		rv=nil;
	} else {
		[self initThermsFromNames:names];
		[self performSelector: @selector(update) withObject:nil afterDelay:0];
		[self scheduleTimer];
	}
	return(rv);
}

-(Thermometer *)getNamedThermometer:(NSString *)name;
{
	NSString *urlstr=[[NSString alloc]
		initWithFormat: @"%@?temp=%@", [url standardizedURL], name];
	NSURL *u=[[NSURL alloc] initWithString:urlstr];
	HttpThermometer *t=[[HttpThermometer alloc] initWithName:name url:u];
	[u release];
	[urlstr release];
	[t autorelease];
	return(t);
}

-(void)scheduleTimer
{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	int freq=[[defaults objectForKey: @"frequency"] intValue];
	NSLog(@"Scheduling timer with frequency:  %d", freq);
	updater=[NSTimer scheduledTimerWithTimeInterval:freq
		target: self
		selector: @selector(update)
		userInfo:nil repeats:YES];
}

-(void)update
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSEnumerator *e= [therms objectEnumerator];
	id object;
	while(object = [e nextObject]) {
		[object update];
	}
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	double erval=[[defaults objectForKey: @"frequency"] doubleValue];
	double cur=(double)[updater timeInterval];
	if(erval != cur) {
		NSLog(@"Time has changed from %.2f to %.2f, updating", cur, erval);
		[updater invalidate];
		[self scheduleTimer];
	}
	[pool release];
}

-(NSArray *)initThermList
{
	NSLog(@"Initializing list from %@", url);
	NSString *thermlist=[[NSString alloc] initWithContentsOfURL: url];
	NSArray *thermarray=[thermlist componentsSeparatedByString:@"\n"];
	NSLog(@"List is (%@) %@", thermlist, thermarray);
	[thermlist release];
	return(thermarray);
}

@end
