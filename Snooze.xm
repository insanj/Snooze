#import "Snooze.h"

// It could be more intelligent to -setIntegerForKey: in SpringBoard...
%hook NSUserDefaults

- (NSInteger)integerForKey:(NSString *)defaultName {
	if ([defaultName isEqualToString:@"SBLocalNotificationSnoozeIntervalOverride"]) {
		NSInteger snoozeInterval = %orig(@"SZSnoozeInterval");
		return snoozeInterval ? snoozeInterval : %orig(defaultName);
	}

	else {
		return %orig();
	}
}

%end

%hook EditAlarmViewController

- (NSInteger)tableView:(UITableView *)arg1 numberOfRowsInSection:(NSInteger)arg2 {
	return %orig() + 1;
}

- (UITableViewCell *)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MoreInfoTableViewCell *cell = (MoreInfoTableViewCell *) %orig();
	if (arg2.row > 3) {
		cell._contentString = @"Snooze Time";
		cell.textLabel.text = @"Snooze Time";

		NSString *snoozeTime = @"9 Minutes";
		NSInteger savedSnoozeTime = [[NSUserDefaults standardUserDefaults] integerForKey:self.alarm.alarmId];
		if (savedSnoozeTime) {
			snoozeTime = [NSString stringWithFormat:@"%i Minutes", (int)savedSnoozeTime];
		}

		cell.detailTextLabel.text = snoozeTime;
	}

	return cell;
}

- (void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(NSIndexPath *)arg2 {
	if (arg2.row > 3) {
		[arg1 deselectRowAtIndexPath:arg2 animated:YES];
	}

	else {
		%orig();
	}
}

- (void)startEditingSetting:(long long)arg1 {
	%log;
	%orig();
}


%end
