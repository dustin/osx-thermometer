//
//  ThermController.h
//  Thermometer
//
//  Created by Dustin Sallings on Sat Mar 22 2003.
//  Copyright (c) 2003 SPY internetworking. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "ThermometerCell.h"
#import "PreferenceController.h"
#import "TempReading.h"

@interface ThermController : NSWindowController {
    IBOutlet NSMatrix *thermMatrix;
    IBOutlet NSTextField *status;
    IBOutlet NSMenu *dockMenu;
    
    NSMutableArray *therms;
    NSTimer *updater;
    
    NSUserDefaults *defaults;
	
	NSThread *_lempThread;
}

-(void)update;
-(IBAction)update:(id)sender;
-(IBAction)launchPreferences:(id)sender;

-(void)receiveUpdate:(TempReading *)r;

-(IBAction)setCelsius:(id)sender;
-(IBAction)setFarenheit:(id)sender;

@end
