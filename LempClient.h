//
//  LempClient.h
//  Thermometer
// arch-tag: 84079E0C-A4AE-11D8-B6C3-000A957659CC
//
//  Created by Dustin Sallings on Wed May 12 2004.
//  Copyright (c) 2004 Dustin Sallings. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <syslog.h>
#include <netinet/tcp.h>

@interface LempClient : NSObject {

	FILE *_file;
	int _fd;

	NSArray *_therms;
	
	id _delegate;

}

-(id)initWithDelegate:(id)listener host:(NSString *)hostname port:(int)portnum;

-(NSArray *)therms;

-(void)readLoop:(id)nothing;

@end
