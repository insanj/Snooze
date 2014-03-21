#import "Snooze.h"
#define SZADD_AMOUNT 10

%hook SBClockDataProvider

// Should visually indicate snooze time change, and do the business as you'd expect,
// the only problem is that it doesn't set the timer for the alarm snooze.
- (void)_handleAlarmSnoozedNotification:(NSConcreteNotification *)notification {
	NSDateComponents *snoozeAdd = [[[NSDateComponents alloc] init] autorelease];
	snoozeAdd.second = SZADD_AMOUNT;

	NSDate *snoozeDate = [[NSCalendar currentCalendar] dateByAddingComponents:snoozeAdd toDate:[NSDate date] options:0];

	UIConcreteLocalNotification *snoozeLocal = (UIConcreteLocalNotification *) notification.userInfo[@"AlarmNotification"];
	[snoozeLocal setFireDate:snoozeDate];

	NSConcreteNotification *snoozeGlobal = [[%c(NSConcreteNotification) alloc] initWithName:notification.name object:notification.object userInfo:@{
		@"AlarmNotification" : snoozeLocal }];

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
	NSDateComponents *snoozeSwapper = [[[NSDateComponents alloc] init] autorelease];
	snoozeSwapper.minute = -9; // Default snooze amount
	snoozeSwapper.second = SZADD_AMOUNT;

	NSLog(@"[DEBUG] Oh boy do we have a show for you (%u, %@)!", feed, notifications);
	for(UIConcreteLocalNotification *n in notifications) {
		NSLog(@"[DEBUG] So, we're cycling past %@, and we have to check if his %@ is all up on %@. Think so?", n, n.fireDate, snoozeSwapper);

	//if ([(NSDate *)n.fireDate compare:systemSnoozeDate] == NSOrderedSame) {
	//	int snoozeDifference = ([(NSDate *)n.fireDate timeIntervalSinceNow] - [systemSnoozeDate timeIntervalSinceNow]);

	//	NSLog(@"[DEBUG] Oh wait, what?! Doing something funky... is %lu really good?", (long)snoozeDifference);
	//	if (snoozeDifference == 0 || snoozeDifference > 10) {
			[n setFireDate:[[NSCalendar currentCalendar] dateByAddingComponents:snoozeSwapper toDate:n.fireDate options:0]];
	//	}
	}

	NSLog(@"[DEBUG] Bye for now, folks! We're leaving with %@.", notifications);
	return %orig(feed, notifications);
}

%end
