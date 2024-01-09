import 'package:flutter/material.dart';

class MyDateUtil {
  //  this returns the formatted time
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  //  this returns the last message time
  static String getLastMessage(
      {required BuildContext context, required String sentTime}) {
    final DateTime sent =
        DateTime.fromMillisecondsSinceEpoch(int.parse(sentTime));

    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return '${sent.day} ${_getMonth(sent)}';
  }

  // this returns the month of the sent time
  static String _getMonth(DateTime sentTime) {
    switch (sentTime.month) {
      case 1:
        return 'Jan';

      case 2:
        return 'Feb';

      case 3:
        return 'Mar';

      case 4:
        return 'Apr';

      case 5:
        return 'May';

      case 6:
        return 'Jun';

      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }

  //  this function is used for getting the user's last active time
  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.parse(lastActive)??-1;

    //  if the time in user document is not available
    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    //  we are formatting time to get the hour and minute 
    String formatedTime = TimeOfDay.fromDateTime(time).format(context);

    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen online at $formatedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yestarday at $formatedTime';
    }

    String month = _getMonth(time);
    return 'last seen on ${time.day} $month on $formatedTime';
  }
}
