#import <UIKit/UIKit.h>

// Called right before snooze takes effect
@interface SBApplication
- (void)systemLocalNotificationAlertShouldSnooze:(id)notif;
@end

// The snooze alert, with particular Alarm information
@interface SBSystemLocalNotificationAlert
@property(readonly, assign, nonatomic) UILocalNotification *localNotification;
@end

// Alarm object, that holds the unique identifier used for key storing
@interface Alarm : NSObject
@property(readonly) NSString *alarmId;
+ (BOOL)isSnoozeNotification:(id)arg1;
@end

// The modal view that has the timePicker and settings information for
// Alarms being edited or created
@interface EditAlarmView : UIView {
    UITableView *_settingsTable;
    UIDatePicker *_timePicker;
}

@property(readonly, nonatomic) UIDatePicker *timePicker;
@property(readonly, nonatomic) UITableView *settingsTable;

- (id)initWithFrame:(CGRect)arg1;
@end

// The ViewController for EditAlarmViews, which handles the tableViews
@interface EditAlarmViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    EditAlarmView *_editAlarmView;
}

@property(readonly, nonatomic) Alarm *alarm;

+ (CGSize)desiredContentSize;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (NSInteger)tableView:(id)arg1 numberOfRowsInSection:(NSInteger)arg2;
- (NSInteger)numberOfSectionsInTableView:(id)arg1;
- (void)viewDidUnload;
- (void)viewWillAppear:(BOOL)arg1;
- (void)loadView;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)arg1;
- (void)handleSuspend;
- (void)handlePickerChanged;
- (void)startEditingSetting:(long long)arg1;
- (void)_snoozeControlChanged:(id)arg1;
- (void)_doneButtonClicked:(id)arg1;
- (void)_cancelButtonClicked:(id)arg1;
- (void)saveAlarmOnlyIfEdited:(BOOL)arg1;
- (void)markAsEdited;
- (void)dealloc;
- (id)initWithAlarm:(id)arg1;
@end

// Custom UIAlertViewDelegate used for convenient Snooze Time setting
@interface SnoozeAlertViewDelegate : NSObject <UIAlertViewDelegate>
@property(nonatomic, retain) EditAlarmViewController *editAlarmViewController;
@end

// The subview that's pushed when alerting basic settings (label, repeat, etc)
@interface CenteredCellUITableView : UITableView
@property(nonatomic) CGRect keyboardFrame;
@end


// Particular UITableViewCell used in the CenteredCell tableView (used for Labels)
@interface MoreInfoTableViewCell : UITableViewCell
@property(retain, nonatomic) NSString *_contentString;
@end

// The following method isn't called reliably when snoozing, among others (weirdly):
@interface AlarmManager : NSObject
+ (id)sharedManager;
- (void)loadAlarms;
- (void)handleNotificationSnoozed:(id)arg1;
- (void)removeAlarm:(id)arg1;
- (id)lastModified;
@end

@interface AlarmViewController : UITableViewController  {
    Alarm *_alarmToEdit;
}

- (void)didEditAlarm:(id)arg1;
- (void)alarmDidUpdate:(id)arg1;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (void)tableView:(id)arg1 commitEditingStyle:(long long)arg2 forRowAtIndexPath:(id)arg3;

// From protocol: EditAlarmViewControllerDelegate
- (void)didDeleteAlarm:(Alarm *)arg1;
@end

@protocol AlarmActiveDelegate
- (void)activeChangedForAlarm:(Alarm *)arg1 active:(_Bool)arg2;
@end


@interface AlarmTableViewCell : UITableViewCell {
    id <AlarmActiveDelegate> _alarmActiveDelegate;
}
@end



/* A nice custom log function for when there's too much syslog spam to wade through:

static void snoozeLog(NSString *logText) {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *logPath = @"/var/log/snoozelog";
	if (![manager fileExistsAtPath:logPath]) {
		[manager createFileAtPath:logPath contents:[logText dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
	}

	else {
		NSError *logError;
		NSString *logAppendedText = [NSString stringWithContentsOfFile:logPath encoding:NSASCIIStringEncoding error:&logError];
		[[logAppendedText stringByAppendingString:@"\nstr"]]
	}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error

}

*/
