//
//  LempSource.h
//  Thermometer
//
//  Created by Dustin Sallings on 2005/2/9.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TempSource.h"

@interface LempSource : TempSource {

}

-(NSArray *)initThermList;
-(void)receiveUpdate:(TempReading *)r;

@end
