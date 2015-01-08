#import "Snooze.h"

/*
 ██████╗ ██████╗ ███╗   ███╗██████╗  █████╗ ████████╗██╗██████╗ ██╗██╗     ██╗████████╗██╗   ██╗
██╔════╝██╔═══██╗████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
██║     ██║   ██║██╔████╔██║██████╔╝███████║   ██║   ██║██████╔╝██║██║     ██║   ██║    ╚████╔╝ 
██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██╔══██║   ██║   ██║██╔══██╗██║██║     ██║   ██║     ╚██╔╝  
╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ██║  ██║   ██║   ██║██████╔╝██║███████╗██║   ██║      ██║   
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚═╝╚═════╝ ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝                                                                                               
*/

// Macros for custom plist writing. This can be changed at will, as long as the path
// is allowed under mobile permissions (thus the req for NSHomeDirectory).
#define SNOOZE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Snooze"]
#define SNOOZE_PLIST [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Snooze/Alarms.plist"]

// iOS 6-safe macros (one for constructor, other for accessing own alarms)
#define MODERN_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define MODERN_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define OBJ_ALARM(obj) ([obj respondsToSelector:@selector(alarm)] ? obj.alarm : MSHookIvar<Alarm *>(obj, "_alarm"))

/*
██╗      ██████╗  ██████╗ █████╗ ██╗     ██╗███████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██║╚══███╔╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
██║     ██║   ██║██║     ███████║██║     ██║  ███╔╝ ███████║   ██║   ██║██║   ██║██╔██╗ ██║
██║     ██║   ██║██║     ██╔══██║██║     ██║ ███╔╝  ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
███████╗╚██████╔╝╚██████╗██║  ██║███████╗██║███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝                                                                                      
*/

// Localized versions of every word displayed to the user. Can be ignored, if needed.
#define LOCALIZED_SAVE [[NSBundle mainBundle] localizedStringForKey:@"SAVE" value:@"Save" table:@"Localizable"]
#define LOCALIZED_CANCEL [[NSBundle mainBundle] localizedStringForKey:@"CANCEL" value:@"Cancel" table:@"Localizable"]
#define LOCALIZED_MINUTE(min) [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"1_MINUTE" value:@"%@ Minute" table:@"General"], min]
#define LOCALIZED_MINUTES(min) [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"10_MINUTES" value:@"%@ Minutes" table:@"General"], min]
#define LOCALIZED_SNOOZETIME [NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] localizedStringForKey:@"EDIT_SNOOZE" value:@"Snooze" table:@"Localizable"], [[[NSBundle bundleWithPath:@"/Applications/Preferences.app"] localizedStringForKey:@"TIME" value:@"Time" table:@"Date & Time"] componentsSeparatedByString:@":"][0]]

/*
██████╗ ██████╗ ███████╗███████╗███████╗██████╗ ███████╗███╗   ██╗ ██████╗███████╗███████╗
██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝████╗  ██║██╔════╝██╔════╝██╔════╝
██████╔╝██████╔╝█████╗  █████╗  █████╗  ██████╔╝█████╗  ██╔██╗ ██║██║     █████╗  ███████╗
██╔═══╝ ██╔══██╗██╔══╝  ██╔══╝  ██╔══╝  ██╔══██╗██╔══╝  ██║╚██╗██║██║     ██╔══╝  ╚════██║
██║     ██║  ██║███████╗██║     ███████╗██║  ██║███████╗██║ ╚████║╚██████╗███████╗███████║
╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚══════╝
*/

// Custom preferences plist writing, in order to prevent NSUserDefaults conflicts
// based on origin process (also, removes the need for prefixing and such).
static NSInteger snoozeOverrideForAlarmId(NSString *alarmId) {
	NSDictionary *alarms = [NSDictionary dictionaryWithContentsOfFile:SNOOZE_PLIST];
	if (!alarms || !alarms[alarmId]) {
		SZLOG(@"Couldn't find a snooze override for alarmId: %@", alarmId);
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
			SZLOG(@"Had trouble writing alarmId (%@) to save path (%@). Success: %@, Error: %@", alarmId, path, success ? @"YES" : @"NO", error);
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

	SZLOG(@"%@ wrote snooze alarm dictionary to %@!", success ? @"Successfully" : @"Sort of", writePath);
}

static void removeSnoozeOverrideForAlarmId(NSString *alarmId) {
	NSMutableDictionary *alarms = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:SNOOZE_PLIST]];
	if (alarms) {
		[alarms removeObjectForKey:alarmId];
		BOOL success = [alarms writeToFile:SNOOZE_PLIST atomically:YES];
		SZLOG(@"%@ removed %@ from snooze alarm dictionary", success ? @"Successfully" : @"Sort of", alarmId);
	}
}

// Some nice trickery to guarantee localization support (, vs .)
static NSString * snoozeLocalizedNumber(NSNumber *number) {
	int minutesInt = ([number floatValue] / 60.0) * 100;
	NSNumber *back = @(minutesInt / 100.0);

	return [back descriptionWithLocale:[NSLocale currentLocale]];
}

/*
 █████╗ ██╗     ███████╗██████╗ ████████╗██╗   ██╗██╗███████╗██╗    ██╗
██╔══██╗██║     ██╔════╝██╔══██╗╚══██╔══╝██║   ██║██║██╔════╝██║    ██║
███████║██║     █████╗  ██████╔╝   ██║   ██║   ██║██║█████╗  ██║ █╗ ██║
██╔══██║██║     ██╔══╝  ██╔══██╗   ██║   ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║
██║  ██║███████╗███████╗██║  ██║   ██║    ╚████╔╝ ██║███████╗╚███╔███╔╝
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝     ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ 
*/

@implementation SnoozeAlertViewDelegate

// After the "Snooze Time" UIAlertView is dismissed, set its user-entered time to
// the Alarm (via NSUserDefaults) that the parent edit Alarm view spawned from.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		NSString *alertViewText = [alertView textFieldAtIndex:0].text;
		NSNumber *snoozeTime = @([self scanStringForCGFloat:alertViewText] * 60.0);

		if ([snoozeTime boolValue]) {
			NSString *snoozeKey = self.alarmId;
			SZLOG(@"Setting snooze interval %@ for key: %@", snoozeTime, snoozeKey);
			setSnoozeOverrideForAlarmId([snoozeTime integerValue], snoozeKey);

			NSString *snoozeString = snoozeLocalizedNumber(snoozeTime);
			self.textLabel.text =  [snoozeString isEqualToString:@"1"] ? LOCALIZED_MINUTE(snoozeString) : LOCALIZED_MINUTES(snoozeString);
		}

		else {
			SZLOG(@"Couldn't assign snooze interval because %@ is not a valid float", alertViewText);
			// This would be nice, but I promised breakthrough localization support... :p
			// UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Looks like Snooze had a problem saving your requested value. Make sure it's a valid floating point number, without any unfamiliar characters, and try again!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			// [errorAlert show];
			// [errorAlert release];
		}

		// If -reloadData is called, a really weird issue where all alarms become midnight
		// and are frequently unremovable/unturnoffable occurs. Don't ask me why..
		//  EditAlarmView *editAlarmView = MSHookIvar<EditAlarmView *>(controller, "_editAlarmView");
		//  UITableView *table = MSHookIvar<UITableView *>(editAlarmView, "_settingsTable");
		//  [table reloadData];
	}
}

// Prevents issues with localizations that use "," instead of "."
// NSScanner -scanXXX avoidance method to let the compiler choose the correct scan method
// for the current architecture. Derived from StackOverflow response from martin-r (2013).
- (CGFloat)scanStringForCGFloat:(NSString *)string {
 	NSScanner *scanner = [NSScanner localizedScannerWithString:string];
	CGFloat value;

	// This return isn't very useful, as "value" will already be representative by being zero/non-zero.
 	BOOL success = _Generic(value, double:[scanner scanDouble:(double *)&value], float:[scanner scanFloat:(float *)&value]);
 	return success ? value : 0;
}

@end

/*
███╗   ███╗ ██████╗ ██████╗ ███████╗██████╗ ███╗   ██╗     █████╗
████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║    ██╔══██╗
██╔████╔██║██║   ██║██║  ██║█████╗  ██████╔╝██╔██╗ ██║    ╚█████╔╝
██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║╚██╗██║    ██╔══██╗
██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║  ██║██║ ╚████║    ╚█████╔╝
╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝     ╚════╝
*/

%group Modern8 // (iOS 8)

%hook SBApplication

// When an Alarm is snoozed, check to see if its alarmId has a user-defined snooze
// value (in NSUserDefaults), and if so, immediately replace it before handled.
- (void)scheduleSnoozeNotificationForLocalNotification:(UILocalNotification *)localNotification {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (localNotification.userInfo /* && [Alarm isSnoozeNotification:localNotification] */ ) {
		NSString *alarmId = localNotification.userInfo[@"alarmId"];
		NSInteger snoozeTime = snoozeOverrideForAlarmId(alarmId);
		NSInteger original = [defaults integerForKey:@"SBLocalNotificationSnoozeIntervalOverride"];

		SZLOG(@"Detected alarm (%@) snoozed, replacing override key (%i) with key %i.", alarmId, (int)original, (int)snoozeTime);
		[defaults setInteger:snoozeTime forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	}

	else {
		SZLOG(@"Couldn't effect snooze notification: %@", arg1);
	}

	%orig();
	[defaults removeObjectForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
}

%end

%end // %group Modern8

/*
███╗   ███╗ ██████╗ ██████╗ ███████╗██████╗ ███╗   ██╗    ███████╗
████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║    ╚════██║
██╔████╔██║██║   ██║██║  ██║█████╗  ██████╔╝██╔██╗ ██║        ██╔╝
██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║╚██╗██║       ██╔╝
██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║  ██║██║ ╚████║       ██║
╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝       ╚═╝
*/

%group Modern7 // (iOS 7)

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

		SZLOG(@"Detected alarm (%@) snoozed, replacing override key (%i) with key %i.", alarmId, (int)original, (int)snoozeTime);
		[defaults setInteger:snoozeTime forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	}

	else {
		SZLOG(@"Couldn't effect snooze notification: %@", arg1);
	}

	%orig();
	[defaults removeObjectForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
}

%end

%end // %group Modern7

/*
 █████╗ ███╗   ██╗ ██████╗██╗███████╗███╗   ██╗████████╗
██╔══██╗████╗  ██║██╔════╝██║██╔════╝████╗  ██║╚══██╔══╝
███████║██╔██╗ ██║██║     ██║█████╗  ██╔██╗ ██║   ██║   
██╔══██║██║╚██╗██║██║     ██║██╔══╝  ██║╚██╗██║   ██║   
██║  ██║██║ ╚████║╚██████╗██║███████╗██║ ╚████║   ██║   
╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   
*/

%group Ancient // (iOS 6)

%hook SBApplication

// Works, and is called in iOS 6, but it doesn't look like our magic Override key has the
// same effect. thekirbylover's idea, where the key was used for Apple in-house testing so
// developers didn't have to wait for the 9-minute snooze time, seems like it could have
// been the brain-child of the iOS 7 MobileTimer team. This will need to be adjusted for the
// functioning implementation (for now it's all visual).
- (void)systemLocalNotificationAlertShouldSnooze:(id)systemLocalNotificationAlert forApplication:(id)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SBSystemLocalNotificationAlert *alert = (SBSystemLocalNotificationAlert *) systemLocalNotificationAlert;
	UILocalNotification *localNotification = [application getPendingLocalNotification];

	if (alert && localNotification.userInfo /* && [Alarm isSnoozeNotification:alert.localNotification] */ ) {
		NSString *alarmId = localNotification.userInfo[@"alarmId"];
		NSInteger snoozeTime = snoozeOverrideForAlarmId(alarmId);
		NSInteger original = [defaults integerForKey:@"SBLocalNotificationSnoozeIntervalOverride"];

		SZLOG(@"Detected alarm (%@) snoozed, replacing override key (%i) with key %i.", alarmId, (int)original, (int)snoozeTime);
		[defaults setInteger:snoozeTime forKey:@"SBLocalNotificationSnoozeIntervalOverride"];
	}

	else {
		SZLOG(@"Couldn't effect snooze notification: %@ for application: %@", systemLocalNotificationAlert, application);
	}

	%orig();

	[defaults removeObjectForKey:@"SBLocalNotificationSnoozeIntervalOverride"];
}

%end

%end // %group Ancient

/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗ 
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝ 
*/

%group Shared

%hook EditAlarmViewController

// Add a row to the edit (or add) Alarm view (in the Clock app).
- (NSInteger)tableView:(UITableView *)arg1 numberOfRowsInSection:(NSInteger)arg2 {
	return arg2 == 0 ? %orig() + 1 : %orig();	// The other section contains "Delete Alarm"
}

// Create a "Snooze Time" cell in the Alarm edit view.
- (UITableViewCell *)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MoreInfoTableViewCell *cell = (MoreInfoTableViewCell *) %orig();
	if (arg2.section == 0 && arg2.row == [self tableView:arg1 numberOfRowsInSection:arg2.section]-1) {
		cell.textLabel.text = LOCALIZED_SNOOZETIME;

		NSString *snoozeTime;
		NSInteger savedSnoozeTime = snoozeOverrideForAlarmId(OBJ_ALARM(self).alarmId);
		if (savedSnoozeTime) {
			NSString *finalSnoozeString = snoozeLocalizedNumber(@(savedSnoozeTime));
			snoozeTime = [finalSnoozeString isEqualToString:@"1"] ? LOCALIZED_MINUTE(finalSnoozeString) : LOCALIZED_MINUTES(finalSnoozeString);
		}

		else {
			snoozeTime = LOCALIZED_MINUTES([@(9.0) descriptionWithLocale:[NSLocale currentLocale]]);
		}

		cell.detailTextLabel.text = snoozeTime;
	}

	return cell;
}

// Pop a simple UIAlertView if the "Snooze Time" cell is tapped.
- (void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(NSIndexPath *)arg2 {
	if (arg2.section == 0 && arg2.row == [self tableView:arg1 numberOfRowsInSection:arg2.section]-1) {
		[arg1 deselectRowAtIndexPath:arg2 animated:YES];

		SnoozeAlertViewDelegate *changeSnoozeDelegate = [[SnoozeAlertViewDelegate alloc] init];
		changeSnoozeDelegate.textLabel = [arg1 cellForRowAtIndexPath:arg2].detailTextLabel;
		changeSnoozeDelegate.alarmId = OBJ_ALARM(self).alarmId;

		UIAlertView *changeSnoozeAlert = [[UIAlertView alloc] initWithTitle:LOCALIZED_SNOOZETIME message:nil delegate:changeSnoozeDelegate cancelButtonTitle:LOCALIZED_CANCEL otherButtonTitles:LOCALIZED_SAVE, nil];
		changeSnoozeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

		UITextField *changeSnoozeField = [changeSnoozeAlert textFieldAtIndex:0];
		changeSnoozeField.keyboardType = UIKeyboardTypeDecimalPad;
		changeSnoozeField.placeholder = [NSString stringWithFormat:@"e.g. %@, 10, 1337 (%@)", [@(0.5) descriptionWithLocale:[NSLocale currentLocale]], [LOCALIZED_MINUTES(0.0) componentsSeparatedByString:@" "][1]];
		[changeSnoozeField addTarget:self action:@selector(snooze_textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

		[changeSnoozeAlert show];
		[changeSnoozeAlert release];

	}

	else {
		%orig();
	}
}

%new - (void)snooze_textFieldDidChange:(UITextField *)textField {
	UIView *deprivedView = [textField viewWithTag:9001];
    if ([textField.text floatValue] > 9000.0) {
		if (!deprivedView) {
			UIImage *deprivedImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Snooze/deprivation@2x.png"];

			CGRect inset = textField.frame;
			inset.size.width = 20.0;
			inset.size.height -= 5.0;
			inset.origin.x = textField.frame.size.width - inset.size.width - 2.5;
			inset.origin.y += 2.5;

			UIImageView *deprivedImageView = [[UIImageView alloc] initWithFrame:inset];
			deprivedImageView.image = deprivedImage;
			deprivedImageView.contentMode = UIViewContentModeScaleAspectFill;
			deprivedImageView.tag = 9001;

			[textField addSubview:deprivedImageView];
		}

		// CGRect textRect = [textField.text boundingRectWithSize:textField.frame.size options:NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : textField.font } context:nil];
		// inset.origin.x = textRect.size.width + 10.0;

		if (textField.text.length > 27) {
			deprivedView.alpha = 0.5;
		}

		else {
			deprivedView.alpha = 1.0;
		}
    }

    else if (deprivedView) {
		[deprivedView removeFromSuperview];
		deprivedView = nil;
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
			SZLOG(@"Detected deletion of alarm cell, time for easy plist cleaning...");
			removeSnoozeOverrideForAlarmId(editedAlarm.alarmId);
		}

		else {
			SZLOG(@"Detected deletion of alarm cell, but there's nothing we can do...");
		}
	}

	%orig();
}

%end

%end // %group Shared

/*
 ██████╗████████╗ ██████╗ ██████╗ 
██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
██║        ██║   ██║   ██║██████╔╝
██║        ██║   ██║   ██║██╔══██╗
╚██████╗   ██║   ╚██████╔╝██║  ██║
 ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
*/                               

%ctor {
	%init(Shared);
	if (MODERN_IOS8) {
		%init(Modern8);
	}

	else if (MODERN_IOS7) {
		%init(Modern7);
	}

	else {
		%init(Ancient);
	}
}
