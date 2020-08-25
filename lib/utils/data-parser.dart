
import 'dart:convert';

import 'package:html/parser.dart';
import 'package:vegasistent/models/token.dart';
import 'package:vegasistent/services/ea-query.dart';
import 'package:vegasistent/utils/functions.dart';
import 'package:vegasistent/utils/prefs.dart';

Future getChild() async {
  return json.decode(await getData('https://www.easistent.com/m/me/child', await getPrefToken()));
}

Future<List> getTimetable(DateTime startDate, DateTime endDate) async {

  Token token = await getPrefToken();
  List days = [];

  var timetableData = json.decode(await getData('https://www.easistent.com/m/timetable/weekly?from=${toDashDate(startDate)}&to=${toDashDate(endDate)}', token));
  
  List timetable = timetableData['time_table'];
  List schoolHourEvents = timetableData['school_hour_events'];

  schoolHourEvents.sort((a, b) {
    DateTime dateA = DateTime.parse(a['time']['date']);
    DateTime dateB = DateTime.parse(b['time']['date']);
    return dateA.compareTo(dateB);
  });

  for (var lesson in schoolHourEvents) {
    lesson['time']['from'] = timetable.firstWhere((e) => lesson['time']['from_id'] == e['id'])['time']['from'];
    lesson['time']['to'] = timetable.firstWhere((e) => lesson['time']['to_id'] == e['id'])['time']['to'];
  }

  for (var i = 0; i < endDate.difference(startDate).inDays + 1; i++) {
    List day = schoolHourEvents.where((lesson) {
      return lesson['time']['date'] == toDashDate(startDate.add(new Duration(days: i)));
    }).toList();
    days.add(day);
  }

  return days;
}

Future getHours() async {

}

Future<JsonCodec> getFutureEvaluations() async {
  return json.decode(await getData('https://www.easistent.com/m/evaluations?filter=future', await getPrefToken()))['items'];
}

Future<JsonCodec> getPastEvaluations() async {
  return json.decode(await getData('https://www.easistent.com/m/evaluations?filter=past', await getPrefToken()))['items'];
}

Future<List> getHomework() async {
  
  Token token = await getPrefToken();
  List homeworkList = [];
  
  var subjects = json.decode(await getData('https://www.easistent.com/m/homework', token))['items'];

  for (var subject in subjects) {
    var homeworks = json.decode(await getData('https://www.easistent.com/m/homework/classes/${subject['class_id']}', token))['items'];
    for (var homework in homeworks) {
      var detail = json.decode(await getData('https://www.easistent.com/m/homework/${homework['id']}', token));
      homeworkList.add(detail);
    }
  }
  return homeworkList;
}

Future<Iterable> getPAI() async {
  return json.decode(await getData('https://www.easistent.com/m/praises_and_improvements', await getPrefToken()))['items'];
}

Future<String> getProfilePictureURL() async {
  var document = parse(await getData('https://www.easistent.com/webapp#/calendar', await getPrefToken()));
  String url = document.getElementsByClassName('circle-small').first.attributes['src'];
  return 'https://www.easistent.com' + url;
}

Future getMessages() async {
  var document = parse(await getData('https://www.easistent.com/sporocila', await getPrefToken()));
  print(document.getElementsByClassName('obvestila-seznam-aktivno-prebrano'));
}