/* LogController */
// arch-tag: A6CC309E-7A7E-11D9-9E6E-000A957659CC

#import <AppKit/AppKit.h>

@interface LogController : NSWindowController
{
    IBOutlet id outline;
}

-(void)setUnits:(NSString *)to;

@end
