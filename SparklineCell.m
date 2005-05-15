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
// SparkData
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// SparklineCell
// ------------------------------------------------------------------------

@implementation SparklineCell

-(id)init
{
	id rv=[super init];
	return(rv);
}

-(void)plotVals:(NSArray *)vals inRect:(NSRect)rect
	min:(float)minVal max:(float)maxVal
{
	float pixdiff=rect.size.width/((float)[vals count]-1.0);
	if(pixdiff > 1) {
		pixdiff=1;
	}
	NSEnumerator *enumerator = [vals objectEnumerator];
	id object=nil;
	float x=0;
	NSBezierPath *path=[NSBezierPath bezierPath];
	while(object = [enumerator nextObject]) {
		float v=[object floatValue];
		float newx=rect.origin.x + x;
		float rangeDiff=(maxVal - minVal);
		float valPercent=(maxVal - v)/rangeDiff;
		float newy=rect.origin.y+
			rect.size.height-((valPercent*(float)rect.size.height));
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
				v, minVal, maxVal, op, newx, newy,
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
		// NSLog(@"Drawing sparks");
	/*
		NSLog(@"Drawing %@ in %.0f,%.0f at %.0fx%.0f", self,
			cellFrame.origin.x, cellFrame.origin.y,
			cellFrame.size.width, cellFrame.size.height);
	*/

		id data=[self objectValue];

		float firstValue=[[data objectAtIndex:0] floatValue];
		float min=firstValue;
		float max=firstValue;
		NSEnumerator *e=[data reverseObjectEnumerator];
		// Figure out the min and max
		id num=nil;
		while((num = [e nextObject]) != nil) {
			// NSLog(@"Dealing with %@", num);

			if(num != nil) {
				float val=[num floatValue];
				if(val > max) {
					// NSLog(@"New max is %lld", val);
					max=val;
				}
				if(val < min) {
					// NSLog(@"New min is %lld", val);
					min=val;
				}
			}
		}

		// Plot the vals
		[self plotVals:[self objectValue] inRect:cellFrame min:min max:max];
	}

	[pool release];
}

-(void)setObjectValue:(id)val
{
	[super setObjectValue:val];
}

@end
