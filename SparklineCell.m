//
//  SparklineCell.m
//  VisualStatWatch
//
//  Created by Dustin Sallings on 2005/5/5.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "SparklineCell.h"

#include <time.h>

#define MAX_READINGS 100

// ------------------------------------------------------------------------
// SparklineDatum
// ------------------------------------------------------------------------

@implementation SparklineDatum

-(id)initWithTimestamp:(long)ts value:(NSNumber *)v
{
	id rv=[super init];
	timestamp=ts;
	if(v == nil) {
		value=[NSNumber numberWithInt: 0];
	} else {
		value=[v retain];
	}
	return(rv);
}

-(long)timestamp
{
	return(timestamp);
}

-(NSNumber *)value
{
	return(value);
}

-(NSString *)description
{
	return([NSString stringWithFormat: @"{SparklineDatum ts=%ld %@}",
		timestamp, value]);
}

@end

// ------------------------------------------------------------------------
// SparklineCell
// ------------------------------------------------------------------------

@implementation SparklineCell

-(id)init
{
	id rv=[super init];
	return(rv);
}

// Translate an absolute NSPoint to a tracking point.
-(NSPoint)translatePoint:(NSPoint)p
{
	return(NSMakePoint(p.x - trackingCell.origin.x,
		p.y - trackingCell.origin.y));
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame
	ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	trackingCell=cellFrame;
	trackingView=controlView;
	displaying=NO;

	NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];

	[super trackMouse:theEvent inRect:cellFrame ofView:controlView
		untilMouseUp:untilMouseUp];
	return(YES);
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	NSPoint translatedPoint=[self translatePoint: startPoint];
	BOOL defaultRv=[super startTrackingAt:startPoint inView:controlView];
	return(YES);
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint
	inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	[super stopTracking:lastPoint at:stopPoint
		inView:controlView mouseIsUp:flag];
	// NSLog(@"Stopped tracking");
	NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];
	[helpManager removeContextHelpForObject:trackingView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint
  	inView:(NSView *)controlView
{
	NSPoint translatedPoint=[self translatePoint: currentPoint];

	id vals=[self objectValue];
	double pixdiff=trackingCell.size.width/((double)[vals count]-1.0);
	if(pixdiff > 1) {
		pixdiff=1;
	}
	// Calulate the array offset as a function of the X offset and the pixdiff
	int offset=(int)(translatedPoint.x * pixdiff);

	// Figure out where we want the help
	NSWindow *mainWindow=[trackingView window];
	NSRect windowPos=[mainWindow frame];
	NSPoint relHelpPoint=NSMakePoint(currentPoint.x-24, currentPoint.y+25);
	NSPoint helpPoint=NSMakePoint(
		windowPos.origin.x + relHelpPoint.x,
		(windowPos.origin.y + windowPos.size.height)
			- (trackingCell.size.height + relHelpPoint.y));

	if([vals count] > offset) {
		SparklineDatum *datum=[vals objectAtIndex: offset];
		NSDate *when=[NSDate dateWithTimeIntervalSince1970: [datum timestamp]];
		NSString *msg=[NSString stringWithFormat: @"%@ at %@",
			[datum value], when];

		NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];
		[helpManager setContextHelp:[[[NSAttributedString alloc]
			initWithString:msg] autorelease] forObject:trackingView];
		displaying=YES;
	}

	if(displaying) {
		NSHelpManager *helpManager = [NSHelpManager sharedHelpManager];
		[helpManager showContextHelpForObject:trackingView
			locationHint:helpPoint];
	}

	BOOL defaultRv=[super continueTracking:lastPoint at:currentPoint
		inView:controlView];
	return(YES);
}

-(void)plotVals:(NSArray *)vals inRect:(NSRect)rect
{
	double pixdiff=rect.size.width/((double)[vals count]-1.0);
	if(pixdiff > 1) {
		pixdiff=1;
	}
	NSEnumerator *enumerator = [vals objectEnumerator];
	id object=nil;
	double x=0;
	NSBezierPath *path=[NSBezierPath bezierPath];
	while(object = [enumerator nextObject]) {
		double v=[[object value] doubleValue];
		double newx=rect.origin.x + x;
		double rangeDiff=(maxValue - minValue);
		double valPercent=(maxValue - v)/rangeDiff;
		double newy=rect.origin.y+(valPercent*(double)rect.size.height);

		if(newy > rect.origin.y + rect.size.height) {
			NSLog(@"newy exceeded maximum value (was %.2f)", newy);
			newy=rect.origin.y + rect.size.height;
		}
		if(newy < rect.origin.y) {
			NSLog(@"newy fell below minimum value (was %.2f)", newy);
			newy=rect.origin.y;
		}

		NSPoint p=NSMakePoint(newx, newy);
		if(x < rect.origin.x + rect.size.width) {
			NSString *op=nil;

			if(x == 0) {
				op=@"move";
				[path moveToPoint: p];
			} else {
				op=@"line";
				[path lineToPoint: p];
			}
			/*
			NSLog(@"\t%.2f(%.2f:%.2f) %@ to %.0fx%.0f in %.0f,%.0f - %.0f,%.0f",
				v, minValue, maxValue, op, newx, newy,
				rect.origin.x, rect.origin.y,
				rect.origin.x + rect.size.width,
					rect.origin.y + rect.size.height);
			*/
		}
		x+=pixdiff;
	}
	[path stroke];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];

	[[NSColor blackColor] set];

	if([self objectValue] != nil && [[self objectValue] count] > 1) {
		// Plot the vals
		[self plotVals:[self objectValue] inRect:cellFrame];
	}

	[pool release];
}

-(void)setObjectValue:(id)val
{
	[super setObjectValue:val];

	if([val count] > 0) {
		double firstValue=[[[val objectAtIndex:0] value] doubleValue];
		minValue=firstValue;
		maxValue=firstValue;
		NSEnumerator *e=[val reverseObjectEnumerator];
		// Figure out the min and max
		id datum=nil;
		while((datum = [e nextObject]) != nil) {
			// NSLog(@"Dealing with %@", num);
	
			if(datum != nil) {
				double val=[[datum value] doubleValue];
				if(val > maxValue) {
					// NSLog(@"New max is %lld", val);
					maxValue=val;
				}
				if(val < minValue) {
					// NSLog(@"New min is %lld", val);
					minValue=val;
				}
			}
		} // Flipping through data
	} // hasValues
}

@end
