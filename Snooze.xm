#import "Snooze.h"
#define SNOOZE_KEY(str) [@"SNOOZE-" stringByAppendingString:str]
#define LOCALIZED_SAVE [[NSBundle mainBundle] localizedStringForKey:@"SAVE" value:@"Save" table:@"Localizable"]
#define LOCALIZED_CANCEL [[NSBundle mainBundle] localizedStringForKey:@"CANCEL" value:@"Cancel" table:@"Localizable"]
#define LOCALIZED_MINUTE(min) [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"1_MINUTE" value:@"%@ Minute" table:@"General"], min]
#define LOCALIZED_MINUTES(min) [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"10_MINUTES" value:@"%@ Minutes" table:@"General"], min]
#define LOCALIZED_SNOOZETIME [NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] localizedStringForKey:@"EDIT_SNOOZE" value:@"Snooze" table:@"Localizable"], [[[NSBundle bundleWithPath:@"/Applications/Preferences.app"] localizedStringForKey:@"TIME" value:@"Time" table:@"Date & Time"] componentsSeparatedByString:@":"][0]]

%hook SBApplication

// When an Alarm is snoozed, check to see if its alarmId has a user-defined snooze
// value (in NSUserDefaults), and if so, immediately replace it before handled.
- (void)systemLocalNotificationAlertShouldSnooze:(id)arg1 {
	%log;

	SBSystemLocalNotificationAlert *alert = (SBSystemLocalNotificationAlert *)arg1;
	if (alert && alert.localNotification.userInfo /* && [Alarm isSnoozeNotification:alert.localNotification] */ ) {
		NSString *alarmId = alert.localNotification.userInfo[@"alarmId"];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSInteger snoozeTime = [defaults integerForKey:SNOOZE_KEY(alarmId)];
		NSInteger original = [defaults integerForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
		NSInteger replacement = snoozeTime ? snoozeTime : 540;

		NSLog(@"[Snooze] Detected alarm (%@) snoozed, replacing override key (%i) with key %i.", alarmId, (int)original, (int)replacement);

		[defaults setInteger:replacement forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	}

	else {
		NSLog(@"[Snooze] Couldn't effect snooze notification: %@", arg1);
	}

	%orig();
}

%end

%hook NSUserDefaults

- (NSInteger)integerForKey:(NSString *)defaultName {
	NSLog(@"[NSUserDefaults integerForKey:%@] %i", defaultName, (int) %orig);
	return %orig();
}

%end

%hook EditAlarmViewController

// Add a row to the edit (or add) Alarm view (in the Clock app).
- (NSInteger)tableView:(UITableView *)arg1 numberOfRowsInSection:(NSInteger)arg2 {
	NSLog(@"[EditAlarmViewController -tableView:%@ numberOfRuowsInSection:%i]", arg1, (int)arg2);
	return arg2 == 0 ? %orig() + 1 : %orig();	// The other section contains "Delete Alarm"
}

// Create a "Snooze Time" cell in the Alarm edit view.
- (UITableViewCell *)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	%log;
	MoreInfoTableViewCell *cell = (MoreInfoTableViewCell *) %orig();
	if (arg2.row > 3) {
		cell._contentString = cell.textLabel.text = LOCALIZED_SNOOZETIME;

		NSString *snoozeTime = LOCALIZED_MINUTES(@"9");
		NSInteger savedSnoozeTime = [[NSUserDefaults standardUserDefaults] integerForKey:SNOOZE_KEY(self.alarm.alarmId)];
		if (savedSnoozeTime) {
			int finalSnoozeTime = (int)(savedSnoozeTime / 60);
			NSString *finalSnoozeString = [NSString stringWithFormat:@"%i", finalSnoozeTime];

			if (finalSnoozeTime > 60) {
				snoozeTime = LOCALIZED_MINUTES(finalSnoozeString);
			}

			else {
				snoozeTime = LOCALIZED_MINUTE(finalSnoozeString);
			}
		}

		cell.detailTextLabel.text = snoozeTime;
	}

	return cell;
}

// Pop a simple UIAlertView if the "Snooze Time" cell is tapped.
- (void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(NSIndexPath *)arg2 {
	%log;
	if (arg2.row > 3) {
		[arg1 deselectRowAtIndexPath:arg2 animated:YES];

		SnoozeAlertViewDelegate *changeSnoozeDelegate = [[SnoozeAlertViewDelegate alloc] init];
		changeSnoozeDelegate.editAlarmViewController = self;

		UIAlertView *changeSnoozeAlert = [[UIAlertView alloc] initWithTitle:LOCALIZED_SNOOZETIME message:nil delegate:changeSnoozeDelegate cancelButtonTitle:LOCALIZED_CANCEL otherButtonTitles:LOCALIZED_SAVE, nil];
		changeSnoozeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

		UITextField *changeSnoozeField = [changeSnoozeAlert textFieldAtIndex:0];
		changeSnoozeField.keyboardType = UIKeyboardTypeNumberPad;
		changeSnoozeField.placeholder = @"e.g. 1, 5, 9, 1337";

		[changeSnoozeAlert show];
		[changeSnoozeAlert release];
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
	NSString *snoozeText = [alertView textFieldAtIndex:0].text;
	NSInteger snoozeTime = [snoozeText integerValue] * 60;
	if (snoozeTime) {
		NSString *snoozeKey = SNOOZE_KEY(controller.alarm.alarmId);
		NSLog(@"[Snooze] Setting snooze interval %i for key: %@", (int)snoozeTime, snoozeKey);
		[[NSUserDefaults standardUserDefaults] setInteger:snoozeTime forKey:snoozeKey];
	}

	else {
		NSLog(@"[Snooze] Couldn't assign snooze interval because %@ is not a valid integer.", snoozeText);
	}

	EditAlarmView *editAlarmView = MSHookIvar<EditAlarmView *>(controller, "_editAlarmView");
	UITableView *table = MSHookIvar<UITableView *>(editAlarmView, "_settingsTable");
	[table reloadData];
}

@end
