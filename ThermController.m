//
//  ThermController.m
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import "ThermController.h"
#import "Thermometer.h"
#import "LempClient.h";

@implementation ThermController

// Timer scheduling
-(void)scheduleTimer
{
    // Schedule updates
    int freq=[[defaults objectForKey: @"frequency"] intValue];
    NSLog(@"Scheduling timer with frequency:  %d", freq);
    updater=[NSTimer scheduledTimerWithTimeInterval:freq
        target: self
        selector: @selector(update)
        userInfo:nil repeats:true];
}

-(void)update
{
	// Get an autorelease pool for this update
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSLog(@"Updating.");
    NSEnumerator *enumerator = [therms objectEnumerator];
    id object;
    while (object = [enumerator nextObject]) {
        [object update];
    }
    
    // Now, verify the timer is scheduled appropriately
    double erval=[[defaults objectForKey: @"frequency"] doubleValue];
    double cur=(double)[updater timeInterval];
    if(erval != cur) {
        NSLog(@"Time has changed from %.2f to %.2f, updating", cur, erval);
        [updater invalidate];
        [self scheduleTimer];
    }
	// Release the autorelease pool
	[pool release];
}

-(IBAction)launchPreferences:(id)sender
{
	// XXX:  This leaks memory every time the preferences panel is launched
    id prefc=[[PreferenceController alloc] initWithWindowNibName: @"Preferences"];
    [prefc startUp: defaults];
    NSLog(@"Initialized Test");
}

-(IBAction)setCelsius:(id)sender
{
    [defaults setObject: @"c" forKey: @"units"];
    [thermMatrix setNeedsDisplay: true];
}

-(IBAction)setFarenheit:(id)sender
{
    [defaults setObject: @"f" forKey: @"units"];
    [thermMatrix setNeedsDisplay: true];
}

// Updates from the UI
-(IBAction)update:(id)sender
{
    [self update];
}

-(void)initDefaults
{
    // Get the default defaults
    NSMutableDictionary *dd=[[NSMutableDictionary alloc] initWithCapacity: 4];
    [dd setObject: @"c" forKey: @"units"];
    [dd setObject: @"lemp://lemp.west.spy.net/" forKey: @"url"];
    NSNumber *n=[[NSNumber alloc] initWithInt: 60];
    [dd setObject: n forKey: @"frequency"];
    [n release];
    
    defaults=[NSUserDefaults standardUserDefaults];
    // Add the default defaults
    [defaults registerDefaults: dd];
    // [self setUnits: [defaults objectForKey: @"units"]];
    [dd release];
}

// Update a menu item when the thermometer changes
-(void)updateMenuItem:(id)ob
{
	// This is the reading.
	TempReading *tr=[ob object];

	// Look for our thermometer
    NSEnumerator *enumerator = [therms objectEnumerator];
    Thermometer *therm;
    while (therm = [enumerator nextObject]) {
		NSString *tname = [therm name];
		// Is this the thermometer we're looking for?
		if([tname isEqual: [tr name]]) {
			// String for the menu update
			NSString *menuString=[[NSString alloc] initWithFormat:@"%@: %.2f",
				tname, [tr reading]];
    		// Update the menu
    		[[dockMenu itemWithTag: [therm tag]] setTitle: menuString];
			[menuString release];
		}
	}
}

// place the thermometers
-(void)placeTherms:(NSImage *)ci fImage:(NSImage *)fi
{
    // Get the current number of rows and columns
    int r, c;
    [thermMatrix getNumberOfRows:&r columns:&c];

	/* Figure out the numbers of rows and columns */
	int needrows, needcols;
	needcols=sqrt([therms count]);
	needrows=[therms count] / needcols;
	int i=0;
	for(i=r; i<needrows; i++) {
		[thermMatrix addRow];
	}
	for(i=c; i<needcols; i++) {
		[thermMatrix addColumn];
	}
	r=needrows;
	c=needcols;

	NSLog(@"Setting up with %d rows and %d columns\n", r, c);

    for(i=0; i<[therms count]; i++) {
		Thermometer *therm=[therms objectAtIndex: i];
        ThermometerCell *tc=[[ThermometerCell alloc] init];
        [tc setTherm: therm];
        [[tc therm] setTag: i];
        NSMenuItem *mi=[[[NSMenuItem alloc] initWithTitle:[tc description]
            action:nil keyEquivalent:@""] autorelease];
        [mi setTag: i];
        [dockMenu addItem: mi];

		// Register for update notifications for this menu
		[[NSNotificationCenter defaultCenter]
        	addObserver:self
        	selector:@selector(updateMenuItem:)
        	name:[NSString stringWithFormat:@"update-%@", [therm name]]
        	object:nil];

        [tc setCImage: ci];
        [tc setFImage: fi];
        [tc setDefaults: defaults];
        // Figure out where to put it
        int rownum=i % ([therms count]/c);
        int colnum=i/c;
        
		NSLog(@"Putting %@ at %dx%d\n", tc, rownum, colnum);
        [thermMatrix putCell:tc atRow:rownum column:colnum];
        [tc release];
    }

    [thermMatrix sizeToCells];
}

-(void)dataUpdated:(id)anObject
{
    NSString *s=[[NSString alloc] initWithFormat: @"Last update:  %@",
        [[NSDate date] description]];
    [status setStringValue: s];
    [s release];
    [thermMatrix setNeedsDisplay: true];
}

-(NSArray *)httpClientInit
{
    // Grab the list.
    NSString *thermsurls=[defaults objectForKey: @"url"];
    NSURL *thermsurl=[[NSURL alloc] initWithString: thermsurls];
	NSLog(@"Initializing list from %@", thermsurl);
    NSString *thermlist=[[NSString alloc] initWithContentsOfURL: thermsurl];
    NSArray *thermarray=[thermlist componentsSeparatedByString:@"\n"];
	NSLog(@"List is (%@) %@", thermlist, thermarray);
    [thermsurl release];
    [thermlist release];

    // Later initialization
    [self performSelector: @selector(update)
        withObject:nil
        afterDelay:0];

	// Schedule the timer for future updates
    [self scheduleTimer];

	return(thermarray);
}

-(NSArray *)lempClientInit
{
	NSString *thermUrlString=[defaults objectForKey: @"url"];
	NSURL *thermUrl=[[NSURL alloc] initWithString: thermUrlString];
	NSNumber *portNum=[thermUrl port];
	int port=8181;
	if(portNum != nil) {
		port=[portNum intValue];
	}
	LempClient *lc=[[LempClient alloc] initWithDelegate:self
		host:[thermUrl host] port:port];
	if(lc == nil) {
		NSLog(@"lempClient failed to initialize!");
	}
	NSArray *thermarray=[lc therms];
	_lempThread=[NSThread detachNewThreadSelector:@selector(readLoop:)
		toTarget:lc withObject:nil];
	return(thermarray);
}

-(void)lempReconnect
{
	NSArray *ta=[self lempClientInit];
	if(ta == nil) {
		NSLog(@"Failed to reconnect, retrying.");
		[NSTimer scheduledTimerWithTimeInterval:60
        	target: self
        	selector: @selector(lempReconnect)
        	userInfo:nil repeats:false];
	} else {
		NSLog(@"Reconnected.");
	}
}

-(void)receiveUpdate:(TempReading *)reading;
{
	[[NSNotificationCenter defaultCenter]
		postNotificationName:[NSString stringWithFormat:@"update-%@",
			[reading name]]
		object:reading];
}

-(void)lempExiting:(LempClient *)lc
{
    NSString *s=[[NSString alloc] initWithFormat:
		@"lemp client failed at:  %@, restarting", [[NSDate date] description]];
    [status setStringValue: s];
	NSLog(@"lemp thread exiting, beginning restart sequence");
	[NSTimer scheduledTimerWithTimeInterval:15
        target: self
        selector: @selector(lempReconnect)
        userInfo:nil repeats:false];
}

-(void)awakeInitialization:(id)ob
{
	// Now that we're up, blast out the thermometer list for all to see
	[[NSNotificationCenter defaultCenter]
		postNotificationName:THERM_LIST
		object:therms];
}

-(void)awakeFromNib
{
    NSLog(@"Starting ThermController.");
    
    // Initialize the defaults
    [self initDefaults];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"therm-c" ofType:@"png"];
    NSImage *ci = [[NSImage alloc] initWithContentsOfFile:path];
    path = [mainBundle pathForResource:@"therm-f" ofType:@"png"];
    NSImage *fi = [[NSImage alloc] initWithContentsOfFile:path];
	
	NSString *thermUrlString=[defaults objectForKey: @"url"];
	NSURL *thermUrl=[[NSURL alloc] initWithString: thermUrlString];
	NSString *scheme=[thermUrl scheme];
	
	NSArray *thermarrayTmp=nil;
	
	if([scheme isEqual: @"http"]) {
		thermarrayTmp=[self httpClientInit];
	} else if([scheme isEqual: @"lemp"]) {
		thermarrayTmp=[self lempClientInit];
	} else {
		NSLog(@"Unhandled scheme:  %@", scheme);
	}

	NSArray *thermarray = 
		[thermarrayTmp
			sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

	// Convert the list of names to a list of Thermometers
    therms=[[NSMutableArray alloc] initWithCapacity: [thermarray count]];
    NSEnumerator *enumerator = [thermarray objectEnumerator];
    NSString *anObject;
    while (anObject = [enumerator nextObject]) {
        if([anObject length] > 0) {
            Thermometer *t=[[Thermometer alloc] initWithName: anObject
                url:[defaults objectForKey: @"url"]];
            [therms addObject: t];
            [t release];
        }
    }

	// get the row sizes and stuff
    int orow, ocol;
    [thermMatrix getNumberOfRows:&orow columns:&ocol];

	// Set the autosave name
	[[self window] setFrameAutosaveName: @"thermWindow"];

	// Create and place the cells
	[self placeTherms: ci fImage: fi];

    int r, c;
    [thermMatrix getNumberOfRows:&r columns:&c];
	NSLog(@"Configuring window for %dx%d from %dx%d", r, c, orow, ocol);
    
	// Set the window size.
    NSRect newdims=[[self window] frame];
    newdims.size.width=318+(143*(c-ocol));
    newdims.size.height=223+(151*(r-orow));
    [[self window] setMinSize: newdims.size];
    [[self window] setMaxSize: newdims.size];
    [[self window] setFrame:newdims display:true];
    

	// what to do when the data is updated
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(dataUpdated:)
        name:DATA_UPDATED
        object:nil];

	// Do post-startup initialization
	[self performSelector: @selector(awakeInitialization:)
		withObject:nil
		afterDelay:0];

	// Release some stuff
	[ci release];
	[fi release];
}

@end
