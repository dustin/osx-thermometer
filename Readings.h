/* Readings */
// arch-tag: AB418A5E-7A7E-11D9-AE7D-000A957659CC

#import <AppKit/AppKit.h>

@interface Readings : NSObject {
	NSArray *therms;
	NSDateFormatter *dateFormat;
	BOOL celsius;
}

-(void)setUnits:(NSString *)to;

@end
