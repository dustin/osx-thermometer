//
//  TempReading.h
//  Thermometer
// arch-tag: 8794A7F8-A4AE-11D8-8B79-000A957659CC
//
//  Created by Dustin Sallings on Thu May 13 2004.
//  Copyright (c) 2004 Dustin Sallings. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TempReading : NSObject {

	NSString *_name;
	NSDate *_ts;
	float _reading;

}

-(id)initWithName:(NSString *)n reading:(float)r;

-(NSString *)name;
-(NSDate *)readingTimestamp;
-(float)reading;
-(float)floatValue;

@end
