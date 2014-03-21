#import "Snooze.h"

#define SZADD_AMOUNT 10

static NSArray *sz_alarmsToOverride;

%hook SBClockDataProvider

// Should visually indicate snooze time change, and do the business as you'd expect,
// the only problem is that it doesn't set the timer for the alarm snooze.
- (void)_handleAlarmSnoozedNotification:(NSConcreteNotification *)notification {
	NSDateComponents *add = [[[NSDateComponents alloc] init] autorelease];
	add.second = SZADD_AMOUNT;

	NSDate *snoozeDate = [[NSCalendar currentCalendar] dateByAddingComponents:add toDate:[NSDate date] options:0];

	UIConcreteLocalNotification *snoozeLocal = (UIConcreteLocalNotification *) notification.userInfo[@"AlarmNotification"];
	[snoozeLocal setFireDate:snoozeDate];

	NSString *alarmId = ((UIConcreteLocalNotification  *)notification.userInfo[@"AlarmNotification"]).userInfo[@"alarmId"];
	if (!sz_alarmsToOverride) {
		sz_alarmsToOverride = @[alarmId];
	}

	else {
		sz_alarmsToOverride = [sz_alarmsToOverride arrayByAddingObject:alarmId];
	}

	NSConcreteNotification *snoozeGlobal = [[%c(NSConcreteNotification) alloc] initWithName:notification.name object:notification.object userInfo:@{
		@"AlarmNotification" : snoozeLocal }];

//	NSLog(@"[Snooze] Added %i to current time of %@, to alter %@'s %@ and send %@", (int) add.second, [NSDate date], notification, snoozeLocal, snoozeGlobal);
	%orig(snoozeGlobal);
}

/*

-[<SBClockDataProvider: 0x170a7efc0> _nextAlarmForFeed:32 withNotifications:(
	    "<UIConcreteLocalNotification: 0x1783288e0>{
			fire date = Friday, March 21, 2014 at 12:16:01 AM Eastern Daylight Time,
			time zone = (null),
			repeat interval = 0,
			repeat count = 0,
			next fire date = Friday, March 21, 2014 at 12:16:01 AM Eastern Daylight Time,
			user info = {
				alarmId = \"E6A01559-F7A0-4A16-B016-CE65AC2EB953\";\n
				hour = 0;\n
				lastModified = \"2014-03-21 04:06:55 +0000\";\n
				minute = 7;\n
				repeatDay = \"-1\";\n
				revision = 1;\n
				soundType = 1;\n}}"
	)
]

*/

- (id)_nextAlarmForFeed:(unsigned)feed withNotifications:(NSArray *)notifications {

	NSLog(@"[DEBUG] Welcome to the _nextAlarmForFeed show, kids! Here's our good guy, %@! Here are our arguments: %u, %@...", sz_alarmsToOverride, feed, notifications);

	if (sz_alarmsToOverride) {
		NSLog(@"[DEBUG] We've cleared the first hurdle! Let's see what our good guy has to offer...");
		for(UIConcreteLocalNotification *n in notifications) {
			NSLog(@"[DEBUG] Ah, we're at %@ with %@ in our great big argument, let's see if it's found...", n, n.userInfo[@"alarmId"]);
			if ([sz_alarmsToOverride containsObject:n.userInfo[@"alarmId"]]) {
				NSDateComponents *add = [[[NSDateComponents alloc] init] autorelease];
				add.second = SZADD_AMOUNT;
				add.minute = -9; // Default snooze amount

				NSDate *snoozeDate = [[NSCalendar currentCalendar] dateByAddingComponents:add toDate:[n fireDate] options:0];
				[n setFireDate:snoozeDate];
				NSLog(@"[DEBUG] We're in luck! Our good guy contained it! Let's use %@ to create %@ and make %@!", add, snoozeDate, n);
			}
		}

		NSLog(@"[DEBUG] Out of that craziness. Let's kill off our protagonist, and move on.");
		sz_alarmsToOverride = nil;
	}

	NSLog(@"[DEBUG] See ya! We're leaving with %@.", notifications);
	return %orig(feed, notifications);
}

%end
