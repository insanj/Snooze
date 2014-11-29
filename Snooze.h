#import <UIKit/UIKit.h>
#import "substrate.h"

#ifdef DEBUG
    #define SZLOG(fmt, ...) NSLog((@"[Snooze] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define SZLOG(fmt, ...) 
#endif

// Called right before snooze takes effect
@interface SBApplication
- (void)systemLocalNotificationAlertShouldSnooze:(id)notif;
- (id)getPendingLocalNotification; // iOS 6
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
    Alarm *_alarm; // iOS 6...
}

@property(readonly, nonatomic) Alarm *alarm; // iOS 7

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

// Sshh...
@interface EditAlarmViewController (Snooze)
- (void)snooze_textFieldDidChange:(UITextField *)textField;
@end

// Custom UIAlertViewDelegate used for convenient Snooze Time setting
@interface SnoozeAlertViewDelegate : NSObject <UIAlertViewDelegate>
@property(nonatomic, retain) NSString *alarmId;
@property(nonatomic, retain) UILabel *textLabel;
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
- (void)reloadState;

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
