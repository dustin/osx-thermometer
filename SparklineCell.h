//
//  SparklineCell.h
//  VisualStatWatch
//
//  Created by Dustin Sallings on 2005/5/5.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SparklineDatum : NSObject {
	long timestamp;
	NSNumber *value;
}

-(id)initWithTimestamp:(long)ts value:(NSNumber *)v;
-(long)timestamp;
-(NSNumber *)value;

@end

@interface SparklineCell : NSCell {

	// This will remember the frame of the cell that is being tracked
	NSRect trackingCell;
	NSView *trackingView;
	BOOL displaying;

	double minValue;
	double maxValue;

}

@end
