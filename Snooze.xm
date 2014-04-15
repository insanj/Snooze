#import "Snooze.h"
#define SNOOZE_KEY(str) [@"SNOOZE-" stringByAppendingString:str]

%hook SBApplication

- (void)systemLocalNotificationAlertShouldSnooze:(id)notif {
	%log;
	%orig();
}

%end

/*
- (void)_handleAlarmSnoozedNotification:(id)notification {
	%log;
	%orig();
}

%end
*/
/*
// When an Alarm is snoozed, check to see if its alarmId has a user-defined snooze
// value (in NSUserDefaults), and if so, immediately replace it before handled.
- (void)handleAlarmFired:(id)arg1 {
	%log;
	%orig();
}

- (void)handleNotificationSnoozed:(id)arg1 notifyDelegate:(BOOL)arg2 {
	%log;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger snoozeTime = [defaults integerForKey:SNOOZE_KEY(self.alarmId)];
	NSInteger original = [defaults integerForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	NSInteger replacement = snoozeTime ? snoozeTime : 540;

	NSLog(@"[Snooze] Detected alarm (%@) snoozed, replacing override key (%i) with key %i.", self, (int)original, (int)replacement);

	[defaults setInteger:replacement forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SBApplicationClockLocalNotificationsUpdated" object:nil userInfo:nil];
	%orig();
}

%end

%hook AlarmManager

- (void)handleNotificationSnoozed:(id)arg1 {
	%log;
	%orig();
}

%end*/


%hook NSUserDefaults

- (NSInteger)integerForKey:(NSString *)defaultName {
	NSLog(@"[NSUserDefaults integerForKey:%@] %i", defaultName, (int) %orig);
	return %orig();

	/*if ([defaultName isEqualToString:@"SBLocalNotificationSnoozeIntervalOverride"]) {
		NSInteger snoozeInterval = %orig(@"SZSnoozeInterval");
		return snoozeInterval ? snoozeInterval : %orig(defaultName);
	}

	else {
		return %orig();
	}*/
}

%end

%hook EditAlarmViewController

// Add a row to the edit (or add) Alarm view (in the Clock app).
- (NSInteger)tableView:(UITableView *)arg1 numberOfRowsInSection:(NSInteger)arg2 {
	return arg2 == 0 ? %orig() + 1 : %orig();	// The other section contains "Delete Alarm"
}

// Create a "Snooze Time" cell in the Alarm edit view.
- (UITableViewCell *)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MoreInfoTableViewCell *cell = (MoreInfoTableViewCell *) %orig();
	if (arg2.row > 3) {
		cell._contentString = @"Snooze Time";
		cell.textLabel.text = @"Snooze Time";

		NSString *snoozeTime = @"9 Minutes";
		NSInteger savedSnoozeTime = [[NSUserDefaults standardUserDefaults] integerForKey:SNOOZE_KEY(self.alarm.alarmId)];
		if (savedSnoozeTime) {
			int finalSnoozeTime = (int)(savedSnoozeTime / 60);
			snoozeTime = [NSString stringWithFormat:@"%i Minute%@", finalSnoozeTime, finalSnoozeTime > 60 ? @"s" : @""];
		}

		cell.detailTextLabel.text = snoozeTime;
	}

	return cell;
}

// Pop a simple UIAlertView if the "Snooze Time" cell is tapped.
- (void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(NSIndexPath *)arg2 {
	if (arg2.row > 3) {
		[arg1 deselectRowAtIndexPath:arg2 animated:YES];

		SnoozeAlertViewDelegate *changeSnoozeDelegate = [[SnoozeAlertViewDelegate alloc] init];
		changeSnoozeDelegate.editAlarmViewController = self;

		UIAlertView *changeSnoozeAlert = [[UIAlertView alloc] initWithTitle:@"Snooze Time" message:nil delegate:changeSnoozeDelegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
		changeSnoozeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

		UITextField *changeSnoozeField = [changeSnoozeAlert textFieldAtIndex:0];
		changeSnoozeField.keyboardType = UIKeyboardTypeNumberPad;
		changeSnoozeField.placeholder = @"e.g. 1, 5, 9, 1337";

		[changeSnoozeAlert show];
	}

	else {
		%orig();
	}
}

%end

@implementation SnoozeAlertViewDelegate

// After the "Snooze Time" UIAlertView is dismissed, set its user-entered time to
// the Alarm (via NSUserDefaults) that the parent edit Alarm view spawned from.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	EditAlarmViewController *controller = self.editAlarmViewController;
	[[NSUserDefaults standardUserDefaults] setInteger:([[alertView textFieldAtIndex:0].text integerValue] * 60) forKey:SNOOZE_KEY(controller.alarm.alarmId)];

	EditAlarmView *editAlarmView = MSHookIvar<EditAlarmView *>(controller, "_editAlarmView");
	UITableView *table = MSHookIvar<UITableView *>(editAlarmView, "_settingsTable");
	[table reloadData];
}

@end
