//
//  LempClient.m
//  Thermometer
// arch-tag: 855E9B81-A4AE-11D8-B81D-000A957659CC
//
//  Created by Dustin Sallings on Wed May 12 2004.
//  Copyright (c) 2004 Dustin Sallings. All rights reserved.
//

#import "LempClient.h"
#import "TempReading.h"

@implementation LempClient

static int
initSocket(const char *host, int port)
{
    struct hostent *hp;
    int     success, i, flag;
    register int s = -1;
    struct linger l;
    struct sockaddr_in sin;

    if (host == NULL || port == 0)
        return (-1);

    if ((hp = gethostbyname(host)) == NULL) {
#ifdef HAVE_HERROR
        herror("gethostbyname");
#else
        fprintf(stderr, "Error looking up %s\n", host);
#endif
        return (-1);
    }
    success = 0;

    /* of course, replace that 1 with the max number of con attempts */
    for (i = 0; i < 1; i++) {
        if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
            perror("socket");
            return (-1);
        }
        sin.sin_family = AF_INET;
        sin.sin_port = htons(port);
        memcpy(&sin.sin_addr, hp->h_addr, hp->h_length);

        l.l_onoff = 1;
        l.l_linger = 60;
        setsockopt(s, SOL_SOCKET, SO_LINGER, (char *) &l, sizeof(l));

        flag = 1;
        if (connect(s, (struct sockaddr *) &sin, sizeof(sin)) < 0) {
            sleep(1);
        } else {
            success = 1;
            break;
        }
    }

    if (!success)
        s = -1;

    return (s);
}

-(NSString *)readLine
{
	char buf[120];
	id rv=nil;
	if(fgets(buf, sizeof(buf), _file) != NULL) {
		rv=[[NSString stringWithCString:buf length:strlen(buf)]
			stringByTrimmingCharactersInSet:
				[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	return(rv);
}

-(void)initTherms
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	NSLog(@"Initializing thermometers");
	NSMutableArray *a=[[NSMutableArray alloc] initWithCapacity:16];
	
	NSString *line=[self readLine];
	while(line != nil && [line hasPrefix: @"221"]) {
		NSArray *parts=[line componentsSeparatedByString: @"\t"];
		NSString *name=[parts objectAtIndex: 1];
		NSLog(@"Got therm ``%@''", name);
		[a addObject: name];
		line=[self readLine];
	}
	
	_therms=[NSArray arrayWithArray: (NSArray *)a];
	[_therms retain];
	
	[a release];
	[pool release];
}

-(id)initWithDelegate:(id)d host:(NSString *)hostname port:(int)portnum;
{
	self=[super init];
	
	_fd=initSocket([hostname cString], portnum);
	if (_fd >= 0) {
		_file=fdopen(_fd, "r");
		NSString *firstLine=[self readLine];
		if([firstLine hasPrefix: @"220"]) {
			[self initTherms];
			_delegate=d;
		} else {
			NSLog(@"Error in first line of lemp protocol:  %@", firstLine);
			[self release];
			return nil;
		}
	} else {
		[self release];
		return nil;
	}
	
	return self;
}

-(NSArray *)therms
{
	return(_therms);
}

-(void)readLoop:(id)nothing
{
	BOOL going=YES;
	while(going) {
		NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
		NSString *str=[self readLine];
		// NSLog(@"Loop read %@", str);
		
		if(str == nil) {
			going=NO;
			NSLog(@"LEMP client exiting...");
		} else if([str hasPrefix: @"200"] || [str hasPrefix: @"223"]) {
			NSArray *parts=[str componentsSeparatedByString: @"\t"];
			NSString *name=[parts objectAtIndex: 1];
			float reading=[[parts objectAtIndex: 2] floatValue];
			// NSLog(@"Got reading from %@:  %.2f", name, reading);
			TempReading *tr=[[TempReading alloc]
				initWithName:name reading:reading];
			[tr autorelease];
			[_delegate performSelectorOnMainThread:@selector(receiveUpdate:)
				withObject:tr waitUntilDone:NO];
		}

		[pool release];
	}
	// Let the listener know we're exiting
	[_delegate performSelectorOnMainThread:@selector(lempExiting:)
		withObject:self waitUntilDone:NO];
}

@end
