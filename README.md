Snooze
=======================

Configurable snooze times.


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

-[<SBClockDataProvider: 0x1708710c0> _handleAlarmSnoozedNotification:NSConcreteNotification 0x170a43450
{
	name = SBApplicationClockAlarmSnoozedNotification;
	userInfo = {
		AlarmNotification = <UIConcreteLocalNotification: 0x17012c620>{
			fire date = Thursday, March 20, 2014 at 11:17:12 PM Eastern Daylight Time,
			time zone = (null),
			repeat interval = 0,
			repeat count = 0,
			next fire date = Thursday, March 20, 2014 at 11:17:12 PM Eastern Daylight Time,
			user info = {
				alarmId = "9D663886-D567-4DA0-A130-D1B7315FBF19";
				hour = 23;
				lastModified = "2014-03-21 03:07:34 +0000";
				minute = 8;
				repeatDay = "-1";
				revision = 1;
				soundType = 1;
			}
		};
	}
}
]

[Snooze] Added 10
		to current time of 2014-03-21 03:22:01 +0000,

		to alter NSConcreteNotification 0x178c5a7c0 {
				name = SBApplicationClockAlarmSnoozedNotification; userInfo = {
				AlarmNotification = "<UIConcreteLocalNotification: 0x178134a00>{
					fire date = Thursday, March 20, 2014 at 11:22:11 PM Eastern Daylight Time,
					time zone = (null),
					repeat interval = 0,
					repeat count = 0,
					next fire date = Thursday, March 20, 2014 at 11:22:11 PM Eastern Daylight Time,
					user info = {
						alarmId = "49EB1B0B-63EA-46E7-99E2-F1AB6769F476";
						hour = 23;
						lastModified = "2014-03-21 03:21:25 +0000";
						minute = 22;
						repeatDay = "-1";
						revision = 1;
						soundType = 1;
					}
				};
			}
		}'s

		<UIConcreteLocalNotification: 0x178134a00>{
			fire date = Thursday, March 20, 2014 at 11:22:11 PM Eastern Daylight Time,
			time zone = (null),
			repeat interval = 0,
			repeat count = 0,
			next fire date = Thursday, March 20, 2014 at 11:22:11 PM Eastern Daylight Time,
			user info = {
				alarmId = "49EB1B0B-63EA-46E7-99E2-F1AB6769F476";
				hour = 23;
				lastModified = "2014-03-21 03:21:25 +0000";
				minute = 22;
				repeatDay = "-1";
				revision = 1;
				soundType = 1;
			}
		}

		and send NSConcreteNotification 0x178e4f000 {
			name = SBApplicationClockAlarmSnoozedNotification;
			userInfo = {
				AlarmNotification = <UIConcreteLocalNotification: 0x178134a00>{
					fire date = Thursday, March 20, 2014 at 11:22:11 PM Eastern Daylight Time,
					time zone = (null),
					repeat interval = 0,
					repeat count = 0,
					next fire date = Thursday, March 20, 2014 at 11:22:11 PM Eastern Daylight Time,
					user info = {
						alarmId = "49EB1B0B-63EA-46E7-99E2-F1AB6769F476\";
						hour = 23;
						lastModified = "2014-03-21 03:21:25 +0000";
						minute = 22;
						repeatDay = "-1";
						revision = 1;
						soundType = 1;
					}
				};
			}
		}

void __cdecl -[SBClockDataProvider _handlePossibleAlarmNotificationUpdate:](struct SBClockDataProvider *self, SEL a2, id a3)
{
    struct SBClockDataProvider *v3; // r4@1

    v3 = self;
    objc_msgSend(self, "_scheduledNotifications", a3);
    j__objc_msgSend(v3, "_publishAlarmsWithScheduledNotifications:");
}

/* %hook PCPersistentTimer

SpringBoard[30169]: [Snooze] Overriding preset time interval 9.999883 to be personalized 1395372853.630588...

- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5 {
	if( sz_overrideInterval != 0.0) {
		NSLog(@"[Snooze] Overriding preset time interval %f to be personalized %f...", arg1, sz_overrideInterval);
		double snoozeInterval = sz_overrideInterval;
		sz_overrideInterval = 0.0;
		return %orig(snoozeInterval, arg2, arg3, arg4, arg5);
	}

	else {
		return %orig();
	}
}

%end*/


/* pre snooze

with already snoozing or something
-[<SBClockDataProvider: 0x17867a500> _publishAlarmsWithScheduledNotifications:(
		<UIConcreteLocalNotification: 0x170325fa0>{
			fire date = Thursday, March 20, 2014 at 11:48:02 PM Eastern Daylight Time,
			time zone = (null),
			repeat interval = 0,
			repeat count = 0,
			next fire date = Thursday, March 20, 2014 at 11:48:02 PM Eastern Daylight Time,
			user info = {
				alarmId = "E1F654D9-4957-4D25-8AA9-4FEBFCF9437E"
				hour = 23;
				lastModified = "2014-03-21 03:38:07 +0000";
				minute = 39;
				repeatDay = "-1";
				revision = 1;
				soundType = 1;
			}
		}
	)
]

without anything
[<SBClockDataProvider: 0x17867a500> _publishAlarmsWithScheduledNotifications:(
	)]


*/

/* post snooze

with already snoozing or something
-[<SBClockDataProvider: 0x17867a500> _publishAlarmsWithScheduledNotifications:(
		<UIConcreteLocalNotification: 0x1701302c0>{
			fire date = Thursday, March 20, 2014 at 11:48:02 PM Eastern Daylight Time
			time zone = (null)
			repeat interval = 0
			repeat count = 0
			next fire date = Thursday, March 20, 2014 at 11:48:02 PM Eastern Daylight Time,
			user info = {
				alarmId = "E1F654D9-4957-4D25-8AA9-4FEBFCF9437E";
				hour = 23;
				lastModified = "2014-03-21 03:38:07 +0000";
				minute = 39;
				repeatDay = "-1";
				revision = 1;
				soundType = 1;
			}
		},

		<UIConcreteLocalNotification: 0x17012eb00>{
			fire date = Thursday, March 20, 2014 at 11:52:19 PM Eastern Daylight Time
			time zone = (null)
			repeat interval = 0
			repeat count = 0
			next fire date = Thursday, March 20, 2014 at 11:52:19 PM Eastern Daylight Time
			user info = {
				alarmId = "33B0B623-4900-4B13-A7D3-53349ABD5614";
				hour = 23;
				lastModified = "2014-03-21 03:33:34 +0000";
				minute = 34;
				repeatDay = ""-1";
				revision = 1;soundType = 1;
			}
		}
	)
]

without anything (set for 11:59, log 8 seconds later)
-[<SBClockDataProvider: 0x17867a500> _publishAlarmsWithScheduledNotifications:(
		<UIConcreteLocalNotification: 0x170322300>{
			fire date = Friday, March 21, 2014 at 12:08:08 AM Eastern Daylight Time,
			time zone = (null),
			repeat interval = 0,
			repeat count = 0,
			next fire date = Friday, March 21, 2014 at 12:08:08 AM Eastern Daylight Time,
			user info = {
				alarmId = "54D017B7-7ED8-468C-A23B-F0495CC85EC9";
				hour = 23;
				lastModified = "2014-03-21 03:58:15 +0000";
				minute = 59;
				repeatDay = \"-1\";
				revision = 1;
				soundType = 1;
			}
		}"
	)
]
--- last message repeated 1 time ---

*/


---------------------------------------
[Creative Commons Attribution-NonCommercial 3.0 United States License](http://creativecommons.org/licenses/by-nc/3.0/us/) as of 2014:

	Creative Commons Attribution-NonCommercial 3.0 United States License
	Please visit above link for full license.
	Human-readable summary of your abilities has been transcribed below.

	You are free to:
	Share — copy and redistribute the material in any medium or format
	Adapt — remix, transform, and build upon the material
	The licensor cannot revoke these freedoms as long as you follow the license terms.

	Under the following terms:
	Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
	NonCommercial — You may not use the material for commercial purposes.
	No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

	Notices:
	You do not have to comply with the license for elements of the material in the public domain or where your use is permitted by an applicable exception or limitation.
	No warranties are given. The license may not give you all of the permissions necessary for your intended use. For example, other rights such as publicity, privacy, or moral rights may limit how you use the material.
