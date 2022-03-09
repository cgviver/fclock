import 'dart:typed_data';
import 'package:clockapp/models/alarminfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';

import '../alarm_helper.dart';
import '../constansta.dart';
import '../main.dart';
import 'widget/hour_hand.dart';
import 'widget/min_pointer.dart';
import 'widget/outer.dart';
import 'widget/sec_pointer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _alarmTime;
  String? _alarmTimeString;
  final AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  var _enabled = false;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      // print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    bool isPortait = height > width;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.blueGrey[50],
      floatingActionButton: NeumorphicButton(
        padding: const EdgeInsets.all(12.0),
        onPressed: () async {
          var selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (selectedTime != null) {
            final now = DateTime.now();
            var selectedDateTime = DateTime(now.year, now.month, now.day,
                selectedTime.hour, selectedTime.minute);
            setState(() {
              _alarmTime = selectedDateTime;
            });

            onSaveAlarm();
          }
        },
        child: NeumorphicIcon(
          Icons.add,
          size: 30.0,
          style: NeumorphicStyle(color: kprimaryColor),
        ),
      ),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeumorphicSwitch(
              style: NeumorphicSwitchStyle(
                activeThumbColor: kprimaryColor,
                activeTrackColor: kprimaryColor.withOpacity(0.5),
              ),
              value: _enabled,
              onChanged: (bool value) {
                setState(() {
                  _enabled = value;
                });
              },
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: NeumorphicText(
          'Alarm',
          style: NeumorphicStyle(
              color: kprimaryColor,
              shadowLightColor: kprimaryColor.withOpacity(0.5),
              shadowLightColorEmboss: kprimaryColor),
          textStyle: NeumorphicTextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: !_enabled
                    ? AnalogClock()
                    : DigitalClock(isPortait: isPortait, height: height)),
            const SizedBox(
              height: 25.0,
            ),
            FutureBuilder<List<AlarmInfo>>(
                future: _alarms,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data!.map<Widget>((alarm) {
                        var alarmTime =
                            DateFormat('hh:mm aa').format(alarm.alarmDateTime!);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Neumorphic(
                            style: const NeumorphicStyle(
                                border: NeumorphicBorder(
                              color: Colors.white,
                              width: 0.8,
                            )),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListTile(
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat.yMMMMEEEEd()
                                        .format(alarm.alarmDateTime!),
                                    style: TextStyle(
                                        color: kprimaryColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20),
                                  ),
                                ),
                                trailing: InkWell(
                                  onTap: () => deleteAlarm(alarm.id!),
                                  child: NeumorphicIcon(
                                    Icons.delete,
                                    size: 30.0,
                                    style: const NeumorphicStyle(
                                        color: Colors.red),
                                  ),
                                ),
                                title: Text(
                                  alarmTime,
                                  style: TextStyle(
                                      color: kprimaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })
          ],
        ),
      ),
    ));
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo) async {
    const int insistentFlag = 4;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif1', 'alarm_notif',
        channelDescription: 'Channel for Alarm notification',
        icon: 'austinlogo',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('alarmsound'),
        largeIcon: const DrawableResourceAndroidBitmap('austinlogo'),
        additionalFlags: Int32List.fromList(<int>[insistentFlag]));

    var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
        // sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'New Alarm, Tap to close',
        alarmInfo.title,
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  void onSaveAlarm() {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime!.isAfter(DateTime.now())) {
      scheduleAlarmDateTime = _alarmTime!;
    } else {
      scheduleAlarmDateTime = _alarmTime!.add(const Duration(days: 1));
    }

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      title: DateFormat('hh:mm:ss a').format(scheduleAlarmDateTime),
    );
    _alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo);
    // Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }
}

class DigitalClock extends StatelessWidget {
  const DigitalClock({
    Key? key,
    required this.isPortait,
    required this.height,
  }) : super(key: key);

  final bool isPortait;
  final double height;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(
          const Duration(seconds: 1),
        ),
        builder: (context, snapshot) {
          return Container(
            height: isPortait ? height * 0.5 : height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                        border: NeumorphicBorder(
                      color: Colors.white,
                      width: 0.8,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          NeumorphicText(
                              DateFormat('hh:mm:ss a').format(DateTime.now()),
                              style: NeumorphicStyle(
                                  depth: 10.0, color: kprimaryColor),
                              textStyle: NeumorphicTextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 30.0,
                              )),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            DateFormat.yMMMMEEEEd().format(DateTime.now()),
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class AnalogClock extends StatelessWidget {
  const AnalogClock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(
        Duration(seconds: 1),
      ),
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Stack(alignment: Alignment.center, children: [
            AnalogicCircle(),
            SecondPointer(),
            MinutePointer(),
            HourPointer(),
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ]),
        );
      },
    );
  }
}
