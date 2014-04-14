#import "Snooze.h"
#define SNOOZE_KEY(str) [@"SNOOZE-" stringByAppendingString:str]

%hook Alarm

- (void)handleAlarmFired:(id)arg1 {
	Alarm *firing = (Alarm *) arg1;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger snoozeTime = [defaults integerForKey:SNOOZE_KEY(firing.alarmId)];
	NSInteger original = [defaults integerForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	NSInteger replacement = snoozeTime ? snoozeTime : 540;

	NSLog(@"[Snooze] Detected alarm (%@) fired, replacing override key (%i) with key %i.", firing, (int)original, (int)replacement);

	[defaults setInteger:replacement forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	%orig();
}

%end

// It could be more intelligent to -setIntegerForKey: in SpringBoard...
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

- (NSInteger)tableView:(UITableView *)arg1 numberOfRowsInSection:(NSInteger)arg2 {
	return %orig() + 1;
}

- (UITableViewCell *)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MoreInfoTableViewCell *cell = (MoreInfoTableViewCell *) %orig();
	if (arg2.row > 3) {
		cell._contentString = @"Snooze Time";
		cell.textLabel.text = @"Snooze Time";

		NSString *snoozeTime = @"9 Minutes";
		NSInteger savedSnoozeTime = [[NSUserDefaults standardUserDefaults] integerForKey:SNOOZE_KEY(self.alarm.alarmId)];
		if (savedSnoozeTime) {
			snoozeTime = [NSString stringWithFormat:@"%i Minutes", (int)(savedSnoozeTime / 60)];
		}

		cell.detailTextLabel.text = snoozeTime;
	}

	return cell;
}

- (void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(NSIndexPath *)arg2 {
	if (arg2.row > 3) {
		[arg1 deselectRowAtIndexPath:arg2 animated:YES];

		SnoozeAlertViewDelegate *changeSnoozeDelegate = [[SnoozeAlertViewDelegate alloc] init];
		changeSnoozeDelegate.editAlarmViewController = self;

		UIAlertView *changeSnoozeAlert = [[UIAlertView alloc] initWithTitle:@"Snooze Time" message:nil delegate:changeSnoozeDelegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
		changeSnoozeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

		UITextField *changeSnoozeField = [changeSnoozeAlert textFieldAtIndex:0];
		changeSnoozeField.keyboardType = UIKeyboardTypeNumberPad;

		[changeSnoozeAlert show];
	}

	else {
		%orig();
	}
}

%end

@implementation SnoozeAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	EditAlarmViewController *controller = self.editAlarmViewController;
	[[NSUserDefaults standardUserDefaults] setInteger:([[alertView textFieldAtIndex:0].text integerValue] * 60) forKey:SNOOZE_KEY(controller.alarm.alarmId)];

	EditAlarmView *editAlarmView = MSHookIvar<EditAlarmView *>(controller, "_editAlarmView");
	UITableView *table = MSHookIvar<UITableView *>(editAlarmView, "_settingsTable");
	[table reloadData];
}

@end
