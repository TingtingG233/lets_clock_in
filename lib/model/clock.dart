import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lets_clock_in/model/database_manager.dart';

class Clock{
  String course;
  int number;
  DateTime? dateTime;
  bool isChecked;
  IconData? icon;
  Clock({required this.course,required this.number,this.isChecked=false,this.dateTime,this.icon});
  Map<String,dynamic> toMap()
  {
    return{
      'course':course,
      'number':number,
      'datetime':dateTime,
      'is_checked':isChecked,
      'icon_date':jsonEncode(icon)
    };
  }
  Future<bool> update(String oldCours) async {
    var db = await DatabaseManager.getDatebase();
    try {
      await db.transaction((txn) async {
        var list = await txn.query('clock',
            orderBy: 'number', where: 'course=?', whereArgs: [oldCours]);
        if (list.length != number) {
          if (list.length > number) {
            txn.delete('clock',
                where: 'number>? and course=?', whereArgs: [number, oldCours]);
          } else {
            int baseNum = number - list.length;
            int start=list.length+1;
            var vals = List<Clock>.generate(baseNum,
                (index) => Clock(course: course, number: index +start));
            for (var e in vals) {
              txn.insert('clock', e.toMap());
            }
          }
        }
        txn.rawUpdate(
            "update clock set course='$course' where course='$oldCours'");
      });
    } catch (e) {
      print(e.toString());
      return false;
    } finally {
      DatabaseManager.closeDb(db);
    }
    // int ret = await db.update('clock', toMap());
    return true;
  }
  static Future<int> delete(String name) async {
    var db = await DatabaseManager.getDatebase();
    var ret = db.delete('clock', where: 'course=?', whereArgs: [name]);
    DatabaseManager.closeDb(db);
    return ret;
  }
  Future<int> insert() async {
    var db = await DatabaseManager.getDatebase();
    int ret = await db.insert('clock', toMap());
    DatabaseManager.closeDb(db);
    return ret;
  }
  static Future<bool> insertList(List<Clock> list) async {
    var db = await DatabaseManager.getDatebase();
    try {
      await db.transaction((txn) async {
        for (var element in list) {
          await txn.insert('clock', element.toMap());
        }
      });
    } catch (e) {
      print("${e.toString()}");
    }
    DatabaseManager.closeDb(db);
    return true;
  }
  static Future<List<Clock>> getClocks() async {
    var db = await DatabaseManager.getDatebase();
    List<Map<String, dynamic>> maps =
        await db.query('clock', groupBy: 'course', orderBy: 'number');
    var list = List.generate(
        maps.length,
        (i) => Clock(
            course: maps[i]['course'],
            number: maps[i]['number'],
            dateTime: maps[i]['datetime'],
            isChecked:  (maps[i]['is_checked'] as int)==1,
            icon: jsonDecode(maps[i]['icon_date'])));
    DatabaseManager.closeDb(db);
    return list;
  }
  static Future<List<Clock>> getClocksByCourse(String cname) async {
    var db = await DatabaseManager.getDatebase();
    List<Map<String, dynamic>> maps = await db.query('clock',
        where: 'course=?', whereArgs: [cname], orderBy: 'number');
    var list = List.generate(
        maps.length,
        (i) => Clock(
            course: maps[i]['course'],
            number: maps[i]['number'],
            dateTime: maps[i]['datetime'],
            isChecked: (maps[i]['is_checked'] as int)==1,
            icon: jsonDecode(maps[i]['icon_date'])));
    DatabaseManager.closeDb(db);
    return list;
  }

}