#import "Snooze.h"
#define SZADD_AMOUNT 10

%hook NSUserDefaults

- (NSInteger)integerForKey:(NSString *)defaultName {
	if ([defaultName isEqualToString:@"SBLocalNotificationSnoozeIntervalOverride"]) {
		return SZADD_AMOUNT;
	}

	else {
		return %orig();
	}
}

%end
