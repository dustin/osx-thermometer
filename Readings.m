// arch-tag: ACD5D879-7A7E-11D9-9C8D-000A957659CC
#import "Readings.h"
#import "Thermometer.h"
#import "TempReading.h"

@implementation Readings

-(void)awakeFromNib
{
	therms=[[NSArray alloc] initWithObjects: nil];
	dateFormat=[[NSDateFormatter alloc] initWithDateFormat:@"%A, %H:%M:%S"
		allowNaturalLanguage:TRUE];
	
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
	BOOL rv=FALSE;
	if([item isKindOfClass: [Thermometer class]]) {
		rv=TRUE;
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
		rv=[NSString stringWithFormat: @"%.2f", [item reading]];
	} else {
		if([item isKindOfClass: [Thermometer class]]) {
			rv=[item name];
		} else {
			rv=[dateFormat stringForObjectValue: [item readingTimestamp]];
		}
	}
	return(rv);
}

@end
