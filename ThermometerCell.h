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
}

-(id)initWithUnits:(NSString *)u;

-(void)setCImage: (NSImage *)to;
-(void)setFImage: (NSImage *)to;
-(void)setTherm: (Thermometer *)t;
-(void)setUnits:(NSString *)to;
-(id)therm;

-(void)newReading:(float)r;

@end
