//
//  HttpSource.h
//  Thermometer
//
//  Created by Dustin Sallings on 2005/2/9.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TempSource.h"

@interface HttpSource : TempSource {

	NSTimer *updater;

}

-(NSArray *)initThermList;

-(void)scheduleTimer;
-(void)update;
@end
