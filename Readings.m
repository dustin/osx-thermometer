// arch-tag: ACD5D879-7A7E-11D9-9C8D-000A957659CC
#import "Readings.h"
#import "Thermometer.h"
#import "TempReading.h"

@implementation Readings

-(void)awakeFromNib
{
	therms=[[NSArray alloc] initWithObjects: nil];
	dateFormat=[[NSDateFormatter alloc] initWithDateFormat:@"%A, %H:%M:%S"
		allowNaturalLanguage:YES];

	// Get the default units
	NSString *ustring=[[NSUserDefaults standardUserDefaults]
		objectForKey:@"units"];
	[self setUnits: ustring];

	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(gotThermometerList:)
        name:THERM_LIST
        object:nil];

	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(dataUpdated:)
        name:DATA_UPDATED
        object:nil];

	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(unitChanged:)
        name:UNIT_CHANGE
        object:nil];
}

-(void)setUnits:(NSString *)to
{
	if([to isEqual:@"c"]) {
		celsius=YES;
	} else {
		celsius=NO;
	}
}

-(void)unitChanged:(id)ob
{
	[self setUnits:[ob object]];
}

-(void)gotThermometerList:(id)notification
{
	// NSLog(@"Got a thermometer list:  %@", notification);
	[therms release];
	therms=[notification object];
	[therms retain];
	NSLog(@"Got my thermometers:  %@", therms);
}

-(void)dataUpdated:(id)anObject
{   
	// NSLog(@"Data was updated");
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	id rv=nil;
	if(item == nil) {
		rv=[therms objectAtIndex: index];
	} else {
		// NSLog(@"Getting reading at index %d", index);
		rv=[[item lastReadings] objectAtIndex: index];
	}
	return(rv);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	BOOL rv=NO;
	if([item isKindOfClass: [Thermometer class]]) {
		rv=YES;
	}
	return(rv);
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	int rv=0;
	if(item == nil) {
		rv=[therms count];
	} else if([item isKindOfClass: [Thermometer class]]) {
		rv=[[item lastReadings] count];
	}
	return(rv);
}

- (id)outlineView:(NSOutlineView *)outlineView
	objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	// NSLog(@"Asking for object value of %@ of item %@", [tableColumn identifier], item);
	id rv=nil;
	if([@"reading" isEqual:[tableColumn identifier]]) {
		float reading=[item reading];
		if(!celsius) {
			reading=CTOF(reading);
		}
		rv=[NSString stringWithFormat: @"%.2f", reading];
	} else if([@"graph" isEqual:[tableColumn identifier]]) {
		NSLog(@"Getting data for graph at %@", [item name]);
		if([item isKindOfClass: [Thermometer class]]) {
			rv=[item lastReadings];
		}
	} else {
		if([item isKindOfClass: [Thermometer class]]) {
			NSString *label=[NSString stringWithFormat: @"%@ (%d)",
				[item name], [[item lastReadings] count]];
			rv=label;
		} else {
			rv=[dateFormat stringForObjectValue: [item readingTimestamp]];
		}
	}
	return(rv);
}

@end
