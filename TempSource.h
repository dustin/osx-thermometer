//
//  TempSource.h
//  Thermometer
//
//  Created by Dustin Sallings on 2005/2/9.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TempReading.h"
#import "Thermometer.h"

@interface TempSource : NSObject {
	NSArray *therms;
	NSURL *url;
}

-(id)initWithURL:(NSURL *)u;

-(NSArray *)therms;
-(Thermometer *)getNamedThermometer:(NSString *)name;
-(void)initThermsFromNames:(NSArray *)names;

-(void)notifyReading:(TempReading *)reading;

@end
