// arch-tag: A99AED00-7A7E-11D9-AF1E-000A957659CC
#import "LogController.h"
#import "Thermometer.h"

@implementation LogController

-(void)awakeFromNib
{
	NSLog(@"LogController awoke from nib.");
	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(dataUpdated:)
        name:DATA_UPDATED
        object:nil];
    [[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(unitChange:)
		name:UNIT_CHANGE
		object:nil];

	[self setUnits:[[NSUserDefaults standardUserDefaults] objectForKey:@"units"]];
}

-(void)setUnits:(NSString *)to
{
	NSTableColumn *col=[outline tableColumnWithIdentifier: @"reading"];
	NSString *newLabel=[[NSString alloc] initWithFormat:@"Reading (%@)", to];
	[[col headerCell] setStringValue: newLabel];
	[newLabel release];
}

-(void)dataUpdated:(id)anObject
{   
	[outline reloadData];
}

-(void)unitChange:(id)anObject
{
	// Update the log reading header to indicate the units
	NSString *u=[anObject object];
	[self setUnits: u];

	// And reload the data
	[outline reloadData];
}

@end
