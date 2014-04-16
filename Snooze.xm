#import "Snooze.h"

// Macros for custom plist writing. This can be changed at will, as long as the path
// is allowed under mobile permissions (thus the req for NSHomeDirectory).
#define SNOOZE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Snooze"]
#define SNOOZE_PLIST [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Snooze/Alarms.plist"]

// Localized versions of every word displayed to the user. Can be ignored, if needed.
#define LOCALIZED_SAVE [[NSBundle mainBundle] localizedStringForKey:@"SAVE" value:@"Save" table:@"Localizable"]
#define LOCALIZED_CANCEL [[NSBundle mainBundle] localizedStringForKey:@"CANCEL" value:@"Cancel" table:@"Localizable"]
#define LOCALIZED_MINUTE(min) [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"1_MINUTE" value:@"%@ Minute" table:@"General"], min]
#define LOCALIZED_MINUTES(min) [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"10_MINUTES" value:@"%@ Minutes" table:@"General"], min]
#define LOCALIZED_SNOOZETIME [NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] localizedStringForKey:@"EDIT_SNOOZE" value:@"Snooze" table:@"Localizable"], [[[NSBundle bundleWithPath:@"/Applications/Preferences.app"] localizedStringForKey:@"TIME" value:@"Time" table:@"Date & Time"] componentsSeparatedByString:@":"][0]]

// Custom preferences plist writing, in order to prevent NSUserDefaults conflicts
// based on origin process (also, removes the need for prefixing and such).
static NSInteger snoozeOverrideForAlarmId(NSString *alarmId) {
	NSDictionary *alarms = [NSDictionary dictionaryWithContentsOfFile:SNOOZE_PLIST];
	if (!alarms || !alarms[alarmId]) {
		NSLog(@"[Snooze] Couldn't find a snooze override for alarmId: %@", alarmId);
		return 0;
	}

	return [alarms[alarmId] integerValue];
}

static void setSnoozeOverrideForAlarmId(NSInteger override, NSString *alarmId) {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *path = SNOOZE_FOLDER;
	NSError *error; BOOL success;
	if (![manager fileExistsAtPath:path]) {
		success = [manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];

		if (error || !success) {
			NSLog(@"[Snooze] Had trouble writing alarmId (%@) to save path (%@). Success: %@, Error: %@", alarmId, path, success ? @"YES" : @"NO", error);
		}
	}

	NSString *writePath = SNOOZE_PLIST;
	NSDictionary *alarmDict = [NSDictionary dictionaryWithContentsOfFile:writePath];
	if (!alarmDict) {
		alarmDict = @{alarmId : @(override)};
		success = [alarmDict writeToFile:writePath atomically:YES];
	}

	else {
		NSMutableDictionary *alarmMutableDict = [NSMutableDictionary dictionaryWithDictionary:alarmDict];
		[alarmMutableDict setValue:@(override) forKey:alarmId];
		success = [alarmMutableDict writeToFile:writePath atomically:YES];
	}

	NSLog(@"[Snooze] %@ wrote snooze alarm dictionary to %@!", success ? @"Successfully" : @"Sort of", writePath);
}


static void removeSnoozeOverrideForAlarmId(NSString *alarmId) {
	NSMutableDictionary *alarms = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:SNOOZE_PLIST]];
	if (!alarms) {
		return;
	}

	[alarms removeObjectForKey:alarmId];
	BOOL success = [alarms writeToFile:SNOOZE_PLIST atomically:YES];
	NSLog(@"[Snooze] %@ removed %@ from snooze alarm dictionary", success ? @"Successfully" : @"Sort of", alarmId);
}

%hook SBApplication

// When an Alarm is snoozed, check to see if its alarmId has a user-defined snooze
// value (in NSUserDefaults), and if so, immediately replace it before handled.
- (void)systemLocalNotificationAlertShouldSnooze:(id)arg1 {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SBSystemLocalNotificationAlert *alert = (SBSystemLocalNotificationAlert *)arg1;
	if (alert && alert.localNotification.userInfo /* && [Alarm isSnoozeNotification:alert.localNotification] */ ) {
		NSString *alarmId = alert.localNotification.userInfo[@"alarmId"];
		NSInteger snoozeTime = snoozeOverrideForAlarmId(alarmId);
		NSInteger original = [defaults integerForKey:@"SBLocalNotificationSnoozeIntervalOverride"];

		NSLog(@"[Snooze] Detected alarm (%@) snoozed, replacing override key (%i) with key %i.", alarmId, (int)original, (int)snoozeTime);

		[defaults setInteger:snoozeTime forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	}

	else {
		NSLog(@"[Snooze] Couldn't effect snooze notification: %@", arg1);
	}

	%orig();

	// Although I hoped the below comment was true, it appears this isn't a fix...
	// If this remains unremoved, a really weird issue where all alarms become
	// midnight and unremovable/unturnoffable occurs. Don't ask me why...
	[defaults removeObjectForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
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
	return arg2 == 0 ? %orig() + 1 : %orig();	// The other section contains "Delete Alarm"
}

// Create a "Snooze Time" cell in the Alarm edit view.
- (UITableViewCell *)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MoreInfoTableViewCell *cell = (MoreInfoTableViewCell *) %orig();
	if (arg2.row > 3) {
		cell._contentString = cell.textLabel.text = LOCALIZED_SNOOZETIME;

		NSString *snoozeTime = LOCALIZED_MINUTES(@"9");
		NSInteger savedSnoozeTime = snoozeOverrideForAlarmId(self.alarm.alarmId);
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
	if (arg2.row > 3) {
		[arg1 deselectRowAtIndexPath:arg2 animated:YES];

		SnoozeAlertViewDelegate *changeSnoozeDelegate = [[SnoozeAlertViewDelegate alloc] init];
		changeSnoozeDelegate.editAlarmViewController = self;

		UIAlertView *changeSnoozeAlert = [[UIAlertView alloc] initWithTitle:LOCALIZED_SNOOZETIME message:nil delegate:changeSnoozeDelegate cancelButtonTitle:LOCALIZED_CANCEL otherButtonTitles:LOCALIZED_SAVE, nil];
		changeSnoozeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

		UITextField *changeSnoozeField = [changeSnoozeAlert textFieldAtIndex:0];
		changeSnoozeField.keyboardType = UIKeyboardTypeDecimalPad;
		changeSnoozeField.placeholder = @"e.g. 1, 5, 9, 1337";

		[changeSnoozeAlert show];
		[changeSnoozeAlert release];
	}

	else {
		%orig();
	}
}

%end

%hook AlarmViewController

// Clean up preferences if Alarm is removed (only case when it should be!)
- (void)tableView:(UITableView *)arg1 commitEditingStyle:(UITableViewCellEditingStyle)arg2 forRowAtIndexPath:(NSIndexPath *)arg3 {
	if (arg2 == UITableViewCellEditingStyleDelete) {
		// For some reason, this ivar is only set after the user has somehow edited
		// an Alarm while the current MobileTimer instance was active.
		Alarm *editedAlarm = MSHookIvar<Alarm *>(self, "_alarmToEdit");

		if (editedAlarm) {
			NSLog(@"[Snooze] Detected deletion of alarm cell, time for easy plist cleaning...");
			removeSnoozeOverrideForAlarmId(editedAlarm.alarmId);
		}

		else {
			NSLog(@"[Snooze] Detected deletion of alarm cell, but there's nothing we can do...");
		}
	}

	%orig();
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
		NSString *snoozeKey = controller.alarm.alarmId;
		NSLog(@"[Snooze] Setting snooze interval %i for key: %@", (int)snoozeTime, snoozeKey);
		setSnoozeOverrideForAlarmId(snoozeTime, snoozeKey);
	}

	else {
		NSLog(@"[Snooze] Couldn't assign snooze interval because %@ is not a valid integer.", snoozeText);
	}

//	EditAlarmView *editAlarmView = MSHookIvar<EditAlarmView *>(controller, "_editAlarmView");
//	UITableView *table = MSHookIvar<UITableView *>(editAlarmView, "_settingsTable");
//	[table reloadData];
}

@end
