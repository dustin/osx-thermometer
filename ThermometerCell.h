//
//  ThermometerCell.h
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Thermometer.h"

@interface ThermometerCell : NSButtonCell
{
    BOOL celsius;
    
    NSImage *cImage;
    NSImage *fImage;
    Thermometer *therm;
    BOOL _showTrend;

	NSUserDefaults *defaults;
}

-(void)setCImage: (NSImage *)to;
-(void)setFImage: (NSImage *)to;
-(void)setTherm: (Thermometer *)t;
-(id)therm;

-(void)newReading:(float)r;


@end
