// arch-tag: A99AED00-7A7E-11D9-AF1E-000A957659CC
#import "LogController.h"
#import "Thermometer.h"

@implementation LogController

-(void)awakeFromNib
{
	NSLog(@"LogController awoke from nib.");
#ifdef GNUSTEP
	// Bug in gorm prevents me from making these connections
	[outline setDelegate: readings];
	[outline setDataSource: readings];
#endif
	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(dataUpdated:)
        name:DATA_UPDATED
        object:nil];
}

-(void)dataUpdated:(id)anObject
{   
	[outline reloadData];
}



@end
