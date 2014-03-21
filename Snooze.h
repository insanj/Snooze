
@interface PCPersistentTimer : NSObject {
	BOOL _disableSystemWaking;
	double _fireTime;
	unsigned int _guidancePriority;
	double _minimumEarlyFireProportion;
	SEL _selector;
	NSString *_serviceIdentifier;
	// PCSimpleTimer *_simpleTimer;
	double _startTime;
	id _target;
	BOOL _triggerOnGMTChange;
	id _userInfo;
}

@property BOOL disableSystemWaking;
@property(readonly) double fireTime;
@property(readonly) NSString * loggingIdentifier;
@property double minimumEarlyFireProportion;

+ (double)_currentGuidanceTime;
+ (void)_updateTime:(double)arg1 forGuidancePriority:(unsigned int)arg2;
+ (double)currentMachTimeInterval;
+ (id)lastSystemWakeDate;

- (double)_earlyFireTime;
- (void)_fireTimerFired;
- (id)_initWithAbsoluteTime:(double)arg1 serviceIdentifier:(id)arg2 guidancePriority:(unsigned int)arg3 target:(id)arg4 selector:(SEL)arg5 userInfo:(id)arg6 triggerOnGMTChange:(BOOL)arg7;
- (double)_nextForcedAlignmentAbsoluteTime;
- (void)_updateTimers;
- (void)cutPowerMonitorBatteryConnectedStateDidChange:(id)arg1;
- (void)dealloc;
- (id)debugDescription;
- (BOOL)disableSystemWaking;
- (double)fireTime;
- (BOOL)firingIsImminent;
- (id)initWithFireDate:(id)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 guidancePriority:(unsigned int)arg3 target:(id)arg4 selector:(SEL)arg5 userInfo:(id)arg6;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (void)interfaceManagerInternetReachabilityChanged:(id)arg1;
- (void)interfaceManagerWWANInterfaceChangedPowerState:(id)arg1;
- (void)interfaceManagerWWANInterfaceStatusChanged:(id)arg1;
- (void)invalidate;
- (BOOL)isValid;
- (id)loggingIdentifier;
- (double)minimumEarlyFireProportion;
- (void)scheduleInRunLoop:(id)arg1 inMode:(id)arg2;
- (void)scheduleInRunLoop:(id)arg1;
- (void)setDisableSystemWaking:(BOOL)arg1;
- (void)setMinimumEarlyFireProportion:(double)arg1;
- (id)userInfo;

@end


@interface UIConcreteLocalNotification : NSObject
- (id)alertAction;
- (id)alertBody;
- (id)alertLaunchImage;
- (BOOL)allowSnooze;
- (int)applicationIconBadgeNumber;
- (void)clearNonSystemProperties;
- (int)compareFireDates:(id)arg1;
- (id)copyWithZone:(NSZone *)arg1;
- (id)customLockSliderLabel;
- (void)dealloc;
- (id)description;
- (void)encodeWithCoder:(id)arg1;
- (id)fireDate;
- (BOOL)fireNotificationsWhenAppRunning;
- (id)firedNotificationName;
- (BOOL)hasAction;
- (unsigned int)hash;
- (BOOL)hideAlertTitle;
- (id)init;
- (id)initWithCoder:(id)arg1;
- (BOOL)interruptAudioAndLockDevice;
- (BOOL)isEqual:(id)arg1;
- (BOOL)isSystemAlert;
- (BOOL)isValid;
- (id)nextFireDateAfterDate:(id)arg1 localTimeZone:(id)arg2;
- (id)nextFireDateForLastFireDate:(id)arg1;
- (int)remainingRepeatCount;
- (id)repeatCalendar;
- (unsigned int)repeatInterval;
- (BOOL)resumeApplicationInBackground;
- (void)setAlertAction:(id)arg1;
- (void)setAlertBody:(id)arg1;
- (void)setAlertLaunchImage:(id)arg1;
- (void)setAllowSnooze:(BOOL)arg1;
- (void)setApplicationIconBadgeNumber:(int)arg1;
- (void)setCustomLockSliderLabel:(id)arg1;
- (void)setFireDate:(id)arg1;
- (void)setFireNotificationsWhenAppRunning:(BOOL)arg1;
- (void)setFiredNotificationName:(id)arg1;
- (void)setHasAction:(BOOL)arg1;
- (void)setHideAlertTitle:(BOOL)arg1;
- (void)setInterruptAudioAndLockDevice:(BOOL)arg1;
- (void)setIsSystemAlert:(BOOL)arg1;
- (void)setRemainingRepeatCount:(int)arg1;
- (void)setRepeatCalendar:(id)arg1;
- (void)setRepeatInterval:(unsigned int)arg1;
- (void)setResumeApplicationInBackground:(BOOL)arg1;
- (void)setShowAlarmStatusBarItem:(BOOL)arg1;
- (void)setSnoozedNotificationName:(id)arg1;
- (void)setSoundName:(id)arg1;
- (void)setSoundType:(int)arg1;
- (void)setTimeZone:(id)arg1;
- (void)setTotalRepeatCount:(int)arg1;
- (void)setUserInfo:(id)arg1;
- (BOOL)showAlarmStatusBarItem;
- (id)snoozedNotificationName;
- (id)soundName;
- (int)soundType;
- (id)timeZone;
- (int)totalRepeatCount;
- (id)userInfo;
@end

@interface Alarm : NSObject
+ (BOOL)isSnoozeNotification:(UIConcreteLocalNotification *)arg1;
@end
