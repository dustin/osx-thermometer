//
//  LempSource.m
//  Thermometer
//
//  Created by Dustin Sallings on 2005/2/9.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "LempSource.h"
#import "LempClient.h"

@implementation LempSource

-(id)initWithURL:(NSURL *)u
{
	id rv=[super initWithURL:u];
	NSArray *names=[self initThermList];
	if(names == nil) {
		[rv release];
		rv=nil;
	} else {
		[self initThermsFromNames:names];
	}
	return(rv);
}

-(NSArray *)initThermList
{
	NSNumber *portNum=[url port];
	int port=8181;
	if(portNum != nil) {
		port=[portNum intValue];
	}
	LempClient *lc=[[LempClient alloc] initWithDelegate:self
		host:[url host] port:port];
	NSArray *rv=nil;
	if(lc == nil) {
		NSLog(@"lempClient failed to initialize");
	} else {
		rv=[lc therms];
		[NSThread detachNewThreadSelector:@selector(readLoop:)
			toTarget:lc withObject:nil];
	}
	return(rv);
}

-(void)lempReconnect
{           
	NSArray *ta=[self initThermList];
	if(ta == nil) {
		NSLog(@"Failed to reconnect, retrying.");
		[NSTimer scheduledTimerWithTimeInterval:60
			target: self
			selector: @selector(lempReconnect)
			userInfo:nil repeats:false];
	} else {
		NSLog(@"Reconnected");
	}
}

-(void)receiveUpdate:(TempReading *)reading;
{
	[self notifyReading:reading];
}

-(void)lempExiting:(LempClient *)lc
{
	/*
	NSString *s=[[NSString alloc] initWithFormat:
		@"lemp client failed at:  %@, restarting", [[NSDate date] description]];
	[status setStringValue: s];
	[s release];
	*/
	NSLog(@"lemp thread exiting, beginning restart sequence");
	[NSTimer scheduledTimerWithTimeInterval:15
		target: self
		selector: @selector(lempReconnect)
		userInfo:nil repeats:false];
}

@end
