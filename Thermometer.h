//
//  Thermometer.h
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATA_UPDATED @"DATA_UPDATED"
#define THERM_LIST @"THERM_LIST"
#define UNIT_CHANGE @"UNIT_CHANGE"
#define RING_BUFFER_SIZE 60

#define CTOF(c) (((9.0/5.0)*c) + 32.0)

@interface Thermometer : NSObject {
    float reading;
    NSString *name;
    int tag;
    
    NSMutableArray *lastReadings;
    float trend;
}

// Initialize this Thermometer
-(id)initWithName:(NSString *)theName;

-(void)setReading: (float)r;
-(float)reading;
-(float)trend;
-(void)setName: (NSString *)n;
-(NSString *)name;

-(NSArray *)lastReadings;

-(int)tag;
-(void)setTag:(int)to;

@end
