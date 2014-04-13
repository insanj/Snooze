#import <UIKit/UIKit.h>

@interface Alarm : NSObject
@property(readonly) NSString *alarmId;
@end

@interface EditAlarmViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

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

@interface EditAlarmSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (void)textValueChanged:(id)arg1;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (unsigned int)maskForRow:(long long)arg1;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (void)ringtonePicker:(id)arg1 selectedMediaItemWithIdentifier:(id)arg2;
- (void)ringtonePicker:(id)arg1 selectedRingtoneWithIdentifier:(id)arg2;
- (void)_keyboardWillHide:(id)arg1;
- (void)_keyboardWillShow:(id)arg1;
- (void)_dismiss;
- (void)viewDidUnload;
- (void)viewDidAppear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;
- (void)applicationWillSuspend;
- (void)loadView;
- (void)addDefaultSongsIfNeeded;
- (void)dealloc;
- (id)initWithSetting:(long long)arg1 editController:(id)arg2;

@end

@interface MoreInfoTableViewCell : UITableViewCell

@property(retain, nonatomic) NSString *_contentString;

@end

@interface CenteredCellUITableView : UITableView

@property(nonatomic) CGRect keyboardFrame;

@end
