//
//  ThermometerCell.m
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import "ThermometerCell.h"

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

@implementation ThermometerCell

-(id)initWithUnits:(NSString *)u
{
    id rv=[super init];

	[self setUnits:u];

    [self setImagePosition: NSImageAbove];
    [self setHighlightsBy: NSNoCellMask];
    [self setShowsStateBy: NSNoCellMask];
    [self setBezelStyle: NSShadowlessSquareBezelStyle];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(unitChanged:)
		name:UNIT_CHANGE
		object:nil];

    return(rv);
}

-(void)unitChanged:(id)ob
{
	[self setUnits:[ob object]];
}

-(void)setTherm: (Thermometer *)t
{
    therm=t;
    [therm retain];
    [self setTitle: [therm name]];
}

-(id)therm
{
    return(therm);
}

- (void)dealloc
{
    [cImage release];
    [fImage release];
    [therm release];
    [super dealloc];
}

-(float)reading
{
    float rv=[therm reading];
    if(!celsius) {
        rv=CTOF(rv);
    }
    return(rv);
}

-(void)setCImage: (NSImage *)to
{
    cImage=[to retain];
	if(celsius) {
		[self setImage: cImage];
	}
}

-(void)setFImage: (NSImage *)to
{
    fImage=[to retain];
	if(!celsius) {
		[self setImage: fImage];
	}
}

-(void)setUnits:(NSString *)u
{
	// NSLog(@"Units set to %@", u);
    if([u isEqualToString: @"c"]) {
        celsius=TRUE;
        [self setImage: cImage];
    } else {
        celsius=FALSE;
        [self setImage: fImage];
    }
}

/* Draw the actual arm of the thermometer here. */
- (void)drawArm:(NSRect)bounds
{
    float x2, y2;
    int trans=-90;
    float rad, angle;
    int over=bounds.origin.x + (bounds.size.width/2);
#ifdef GNUSTEP
	over-=1;
    int up=bounds.origin.y + 66; // This is where the dot is
#else
    int up=bounds.origin.y + 69; // This is where the dot is
#endif
    
    angle=([self reading] * 1.8);
    // NSLog(@"Calculated angle:  %.2f", angle);
    angle+=trans;
    rad=((angle/360)* 2 * 3.1415926535897932);
    x2=sin(rad)*39;
    y2=-1-(cos(rad)*39); // weird conversion to get it to display: -1-
    x2+=over;
    y2+=up;
    
    NSPoint p1=NSMakePoint(over, up);
    NSPoint p2=NSMakePoint(x2, y2);
    [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
}

-(NSString *)description
{
    NSString *rv = [NSString stringWithFormat: @"%@ %.2f", [therm name],
        [self reading]];
        
    return(rv);
}

// Delegate stuff indicating a new reading
-(void)newReading:(float)r
{
    // NSLog(@"Received delegate notification of new reading:  %.2f", r);
    // [self setNeedsDisplay: TRUE];
}

//
// Draw
//

/* Draw the underling thermometer, then some lines over it */
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Get an autorelease pool here
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [super drawInteriorWithFrame: cellFrame inView: controlView];
    // Draw the reading
    NSString *readingStr = [[NSString alloc] initWithFormat: @"%.2f",
        [self reading]];
    NSMutableDictionary * attribs = [NSMutableDictionary dictionary];

    // Get the text attributes.
    [attribs setObject:[NSFont fontWithName:@"Times" size:12]
                forKey:NSFontAttributeName];
    [attribs setObject:[NSColor blackColor]
                forKey:NSForegroundColorAttributeName];
    
    // Find out the size of the text, and draw it.
    NSSize wordSize=[readingStr sizeWithAttributes: attribs];
    NSPoint p=NSMakePoint(
        cellFrame.origin.x + ((cellFrame.size.width/2) - (wordSize.width/2)),
        cellFrame.origin.y + (cellFrame.size.height/2));
    [readingStr drawAtPoint:p withAttributes:attribs];
    [readingStr release];
    
    // Draw the change indicator
    NSString *fmt=nil;
    if([therm trend] > 0) {
        fmt=@"+%.2f";
    } else if([therm trend] < 0) {
        fmt=@"%.2f";
    } else {
        fmt=@"";
    }
    readingStr=[[NSString alloc] initWithFormat: fmt, [therm trend]];
	NSFont *lfont=[NSFont fontWithName:@"Fixed" size:9];
	if(lfont != nil) {
    	[attribs setObject:lfont forKey:NSFontAttributeName];
	}
    wordSize=[readingStr sizeWithAttributes: attribs];
    p=NSMakePoint(
        cellFrame.origin.x + ((cellFrame.size.width/2) - (wordSize.width/2)),
        cellFrame.origin.y + ((cellFrame.size.height/2)
								- (wordSize.height + 15)));
    [readingStr drawAtPoint:p withAttributes:attribs];
    [readingStr release];
    
    // Now tell it to draw the arm.
    [self drawArm: cellFrame];
	[pool release];
}

@end
