//
//  TempSource.m
//  Thermometer
//
//  Created by Dustin Sallings on 2005/2/9.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "TempSource.h"
#import "Thermometer.h"

@implementation TempSource

-(void)dealloc
{
	[therms release];
	[url release];
	[super dealloc];
}

-(id)initWithURL:(NSURL *)u
{
	id rv=[self init];
	url=[u retain];
	return(rv);
}

-(NSString *)description
{
	return([NSString stringWithFormat:@"<%@ url:%@>",
		NSStringFromClass([self class]), url]);
}

-(NSArray *)therms
{
	return(therms);
}

-(Thermometer *)getNamedThermometer:(NSString *)name;
{
	Thermometer *t=[[Thermometer alloc] initWithName: name];
	[t autorelease];
	return(t);
}

-(void)initThermsFromNames:(NSArray *)names
{
	NSArray *thermarray = 
		[names
			sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

	NSMutableArray *tmpTherms=[[NSMutableArray alloc]
		initWithCapacity: [names count]];
	NSEnumerator *e = [thermarray objectEnumerator];
	NSString *ob=nil;
	while(ob=[e nextObject]) {
		if([ob length] > 0) {
			[tmpTherms addObject: [self getNamedThermometer: ob]];
		}
	}
	therms=[[NSArray alloc] initWithArray: tmpTherms];
	[tmpTherms release];
	NSLog(@"Initialized therms to %@", therms);
}

-(void)notifyReading:(TempReading *)reading
{
	[[NSNotificationCenter defaultCenter]
		postNotificationName:[NSString stringWithFormat:@"update-%@",
			[reading name]]
		object:reading];
}

@end
