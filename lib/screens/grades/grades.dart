import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:vegasistent/screens/grades/widgets/grade-widget.dart';
import 'package:vegasistent/services/ea-query.dart';
import 'package:vegasistent/utils/prefs.dart';

class Grades extends StatefulWidget {
  @override
  _GradesState createState() => _GradesState();
}

List grades = [];

class _GradesState extends State<Grades> {

  @override
  void initState() {
    void getGrades() async {
      Tuple3 token = await getPrefToken();
      var subjects = await getData('https://www.easistent.com/m/grades', token);
      var dec = json.decode(subjects);

      grades.clear();
      for (var subject in dec['items']) {
        var subjectData = json.decode(await getData('https://www.easistent.com/m/grades/classes/${subject['id']}', token));
        for (var semester in subjectData['semesters']) {
          for (var grade in semester['grades']) {
            grades.add({
              'grade': grade,
              'semester': semester,
              'subject': subject
            });
          }
        }
      }
      setState(() {});
    }
    getGrades();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          var grade = grades[index];

          return Card(
            elevation: 8,
            child: GradeWidget(
              subject: grade['subject']['name'],
              shortSubject: grade['subject']['short_name'],
              grade: int.parse(grade['grade']['value']),
              date: DateTime.parse(grade['grade']['date']),
              teacher: grade['grade']['inserted_by']['name'],
              average: double.parse(grade['subject']['average_grade'].toString().replaceAll(',', '.')),
            )
          );
        },
    );
  }
}