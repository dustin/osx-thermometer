//
//  ThermController.m
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import "ThermController.h"
#import "TempSource.h"
#import "LempSource.h"
#import "HttpSource.h"

@implementation ThermController

-(IBAction)launchPreferences:(id)sender
{
	if(prefController == nil) {
    	prefController=[[PreferenceController alloc]
			initWithWindowNibName: @"Preferences"];
	}
	[prefController showWindow: sender];
}

-(void)setUnits:(NSString *)to
{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:to forKey: @"units"];
	[[NSNotificationCenter defaultCenter]
		postNotificationName:UNIT_CHANGE
		object:to];
    [thermMatrix setNeedsDisplay: YES];
}

-(IBAction)setCelsius:(id)sender
{
	[self setUnits:@"c"];
}

-(IBAction)setFarenheit:(id)sender
{
	[self setUnits:@"f"];
}

// Updates from the UI
-(IBAction)update:(id)sender
{
	NSLog(@"Need to update, but no direct way to do this yet");
    // [self update];
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
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
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
    NSEnumerator *enumerator = [[tempSrc therms] objectEnumerator];
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
	NSArray *therms=[tempSrc therms];
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
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    for(i=0; i<[therms count]; i++) {
		Thermometer *therm=[therms objectAtIndex: i];
        ThermometerCell *tc=[[ThermometerCell alloc]
			initWithUnits:[defaults objectForKey:@"units"]];
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
    [thermMatrix setNeedsDisplay: YES];
}

-(void)awakeInitialization:(id)ob
{
	// Now that we're up, blast out the thermometer list for all to see
	[[NSNotificationCenter defaultCenter]
		postNotificationName:THERM_LIST
		object:[tempSrc therms]];
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

	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSString *thermUrlString=[defaults objectForKey: @"url"];
	NSURL *thermUrl=[[NSURL alloc] initWithString: thermUrlString];
	NSString *scheme=[thermUrl scheme];
	
	if([scheme isEqual: @"lemp"]) {
		tempSrc=[[LempSource alloc] initWithURL: thermUrl];
	} else if([scheme isEqual: @"http"]) {
		tempSrc=[[HttpSource alloc] initWithURL: thermUrl];
	} else {
		NSLog(@"Unhandled scheme:  %@", scheme);
		NSRunAlertPanel(@"Unhandled Scheme",
			[NSString stringWithFormat: @"Unhandled scheme:  %@", scheme],
			@"OK", nil, nil);
		[NSApp terminate: self];
	}
	NSLog(@"Initialized source:  %@", tempSrc);

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

	/* Slight different size calculation needed for gnustep vs. cocoa */
#ifdef GNUSTEP
	newdims.size.height=20+(151*(r-0));
	newdims.size.width=0+(143*(c-1));
#else
    newdims.size.width=318+(143*(c-ocol));
    newdims.size.height=223+(151*(r-orow));
#endif

    [[self window] setMinSize: newdims.size];
    [[self window] setMaxSize: newdims.size];
    [[self window] setFrame:newdims display:YES];
    

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
