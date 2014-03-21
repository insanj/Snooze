#import "Snooze.h"

// %hook Alarm

/*
+[<Alarm: 0x199679bf8> isSnoozeNotification:<UIConcreteLocalNotification: 0x178134dc0>
	{
		fire date = Thursday, March 20, 2014 at 10:16:02 PM Eastern Daylight Time,
		time zone = (null),
		repeat interval = 0,
		repeat count = 0,
		next fire date = Thursday, March 20, 2014 at 10:16:02 PM Eastern Daylight Time,
		user info = {
			    alarmId = "C4D933A4-0987-4DE2-91E0-51344EFB39B8";
			    hour = 22;
			    lastModified = "2014-03-21 02:06:17 +0000";
			    minute = 7;
			    repeatDay = "-1";
			    revision = 1;
			    soundType = 1;
		}
	}
 ]


*/
/*
+ (BOOL)isSnoozeNotification:(UIConcreteLocalNotification *)arg1 {
	UIConcreteLocalNotification *notification = arg1;

	NSDateComponents *add = [[[NSDateComponents alloc] init] autorelease];
    add.second = 5;

	NSDate *snoozeDate = [[NSCalendar currentCalendar] dateByAddingComponents:add toDate:[NSDate date] options:0];
	[arg1 setFireDate:snoozeDate];

	NSLog(@"[Snooze] Added %i to current time of %@, to alter %@ and send %@", (int) add.second, [NSDate date], arg1.fireDate, notification);
	return %orig(notification);
}

%end
*/

%hook SBClockDataProvider

// SBApplicationClockAlarmSnoozedNotification
/*
void __cdecl -[SBClockDataProvider _handleAlarmSnoozedNotification:](struct SBClockDataProvider *self, SEL a2, id a3)
{
    struct SBClockDataProvider *v3; // r10@1
    void *v4; // r0@1
    void *v5; // r6@1
    void *v6; // r5@1
    void *v7; // r8@1
    void *v8; // r0@1
    void *v9; // r6@1
    int v10; // r1@1
    int v11; // r11@1
    void *v12; // r0@1
    void *v13; // r0@1
    void *v18; // r4@1
    void *v21; // r0@1

    v3 = self;
    v4 = objc_msgSend(a3, "userInfo");
    v5 = objc_msgSend(v4, "objectForKey:", CFSTR("AlarmNotification"));
    v6 = objc_msgSend(v3, "_bulletinRequestForSnoozedAlarm:", v5);
    objc_msgSend(v3->_dataProviderProxy, "addBulletin:forDestinations:", v6, 4);
    v7 = objc_msgSend(&OBJC_CLASS___PCPersistentTimer, "alloc");
    v8 = objc_msgSend(v5, "fireDate");
    v9 = objc_msgSend(v8, "timeIntervalSinceNow");
    v11 = v10;
    v12 = objc_msgSend(v6, "publisherBulletinID");
    v13 = objc_msgSend(
              v7,
              "initWithTimeInterval:serviceIdentifier:target:selector:userInfo:",
              v9,
              v11,
              CFSTR("com.apple.mobiletimer"),
              v3,
              "_snoozedAlarmRefired:",
              v12);
    __asm { VMOV.F64        D16, #1.0 }
    v18 = v13;
    __asm { VMOV            R2, R3, D16 }
    objc_msgSend(v13, "setMinimumEarlyFireProportion:", _R2);
    v21 = objc_msgSend(&OBJC_CLASS___NSRunLoop, "currentRunLoop");
    objc_msgSend(v18, "scheduleInRunLoop:", v21);
    j__objc_msgSend(v18, "release");
}
*/

- (void)_handleAlarmSnoozedNotification:(id)notification {
	%log;
	%orig();
}


%end


//- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
