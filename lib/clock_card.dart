import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:lets_clock_in/model/clock.dart';

// ignore: must_be_immutable
class ClockCard extends StatefulWidget {
  ClockCard({Key? key, required this.clock, this.onCheckedChange})
      : super(key: key);
  Clock clock;
  VoidCallback? onCheckedChange;
  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  Color? _backColor;
  Color? _fontColor;
  void getRandomColor() {
    _backColor = Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
        Random().nextInt(255), 0.4);
    _fontColor = Color.fromRGBO((255 - _backColor!.red),
        255 - _backColor!.green, 255 - _backColor!.blue, 0.6);
  }

  @override
  Widget build(BuildContext context) {
    getRandomColor();
    return Card(
        color: widget.clock.isChecked ? Colors.grey : _backColor,
        child: Stack(
          children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInCirc,
                // switchOutCurve: Curves.bounceOut,
                child: widget.clock.isChecked
                    ? Stack(
                        children: [
                          Opacity(
                            opacity: 0.6,
                            child: Align(
                              alignment: Alignment.center,
                              child: Icon(
                                widget.clock.icon,
                                size: 80,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                               const SizedBox(height: 20,),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      widget.clock.number.toString(),
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.deepPurple.shade400),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: (() async{
                                      var date=await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().add(const Duration(days: -120)), lastDate: DateTime.now().add(const Duration(days: 30)));
                                      if(date!=null)
                                      {
                                        widget.clock.dateTime=date;
                                        setState(() {
                                          
                                        });
                                      }
                                    }),
                                    child: Text(
                                  formatDate(widget.clock.dateTime!, [
                                    mm,
                                    '/',
                                    dd,
                                    '/',
                                    yy,
                                    ' ',
                                    HH,
                                    ':',
                                    nn,
                                    ':',
                                    ss
                                  ]),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.clock.number.toString(),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _fontColor),
                        ),
                      )),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                      onTap: (() {
                        onChecked(true, Icons.star);
                      }),
                      child: Icon(
                        Icons.star,
                        color: Colors.lime.shade400,
                      )),
                  InkWell(
                      onTap: (() {
                        onChecked(true, Icons.sentiment_very_satisfied);
                      }),
                      child: Icon(
                        Icons.sentiment_very_satisfied,
                        size: 20,
                        color: Colors.lime.shade400,
                      )),
                  InkWell(
                      onTap: (() {
                        onChecked(true, Icons.face);
                      }),
                      child: Icon(
                        Icons.face,
                        size: 20,
                        color: Colors.lime.shade400,
                      )),
                  InkWell(
                      onTap: (() {
                        onChecked(true, Icons.fingerprint);
                      }),
                      child: Icon(
                        Icons.fingerprint,
                        size: 20,
                        color: Colors.lime.shade400,
                      )),
                       InkWell(
                      onTap: (() {
                        onChecked(false, null);
                      }),
                      child: Icon(
                        Icons.cleaning_services,
                        size: 20,
                        color: Colors.green.shade400,
                      )),
                ],
              ),
            )
          ],
        ));
  }

  void onChecked(bool isChecked, IconData? data) {
    if (widget.clock.isChecked != isChecked) {
      widget.clock.dateTime = DateTime.now();
    }
    widget.clock.isChecked = isChecked;
    widget.clock.icon = data;
    widget.onCheckedChange?.call();
    setState(() {});
  }
  
}
