//
//  TempReading.m
//  Thermometer
// arch-tag: 88C57957-A4AE-11D8-8537-000A957659CC
//
//  Created by Dustin Sallings on Thu May 13 2004.
//  Copyright (c) 2004 Dustin Sallings. All rights reserved.
//

#import "TempReading.h"


@implementation TempReading

-(id)initWithName:(NSString *)n reading:(float)r
{
	self = [super init];
	
	_name=n;
	[_name retain];
	_reading=r;
	_ts=[[NSDate alloc] init];
	
	return self;
}

-(NSString *)description
{
	return([NSString stringWithFormat: @"<TempReading %@ = %.2f>", _name, _reading]);
}

-(NSString *)name
{
	return(_name);
}

-(NSDate *)readingTimestamp
{
	return(_ts);
}

-(float)reading
{
	return(_reading);
}

-(float)floatValue
{
	return(_reading);
}

-(void)dealloc
{
	[_ts release];
	[_name release];
	[super dealloc];
}

@end
