import 'package:flutter/material.dart';
import 'package:lets_clock_in/clock_card.dart';
import 'package:lets_clock_in/model/clock.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock In',
      localizationsDelegates: const [
         AppLocalizations.delegate,
         GlobalMaterialLocalizations.delegate,
         GlobalWidgetsLocalizations.delegate,
         GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales:const [
        Locale('en',''),
        Locale('zh','')
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(),
    );
  }
}

List<Clock> clocks = [
  // Clock(course: 'art',number: 1),
  // Clock(course: 'art',number: 2),
  // Clock(course: 'art',number: 3),
  // Clock(course: 'art',number: 4),
  // Clock(course: 'art',number: 5),
  // Clock(course: 'art',number: 6),
  // Clock(course: 'art',number: 7),
  // Clock(course: 'art',number: 8),
  // Clock(course: 'art',number: 9),
  // Clock(course: 'art',number: 10),
];
List<Clock> courses = [];

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String curCours="";
   String addCourse="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCourse(showDef: true);
  }

  loadCourse({bool showDef = false}) async {
    addCourse =AppLocalizations.of(context)!.addcourse;
    List<Clock> allClocks = await Clock.getClocks();
    if (allClocks.isNotEmpty) {
      courses.clear();
      courses.add(
        // ignore: use_build_context_synchronously
        Clock(course:addCourse, icon: Icons.add, number: 0),
      );
      courses.addAll(allClocks);
      if (showDef) {
        if (courses.length > 1) {
          clocks = await Clock.getClocksByCourse(courses[1].course);
          curCours=courses[1].course;
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    addCourse =AppLocalizations.of(context)!.addcourse;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.mycourseclock),
               Text("$curCours ${AppLocalizations.of(context)!.progress}: ${clocks.where((element) => element.isChecked).length}/${clocks.length}"),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width ~/ 160,
        childAspectRatio: 1.0,
        children: [
          for (int i = 0; i < clocks.length; i++)
            ClockCard(
              clock: clocks[i],
              onCheckedChange: () {
                setState(() {});
              },
            ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.lime,
        elevation: 2.0,
        child: ListView.builder(
            itemCount: courses.length,
            itemBuilder: ((context, index) {
              return ListTile(
                  onTap: () async {
                    if (index == 0) {
                      var ret = await showAlert("");
                      if (ret is Clock) {
                        Clock c = ret as Clock;
                        var list = List<Clock>.generate(
                            c.number,
                            (index) =>
                                Clock(course: c.course, number: index + 1));
                        var val = await Clock.insertList(list);
                        clocks = await Clock.getClocksByCourse(c.course);
                          curCours=c.course;
                        loadCourse();
                        print("insert number $val");
                      }
                    } else {
                      clocks =
                          await Clock.getClocksByCourse(courses[index].course);
                            curCours=courses[index].course;
                      setState(() {});
                    }
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  title: Text(courses[index].course),
                  trailing: index == 0
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  var ret =
                                      await showAlert(courses[index].course);
                                  if (ret is Clock) {
                                    Clock c = (ret as Clock);
                                    bool count =
                                        await c.update(courses[index].course);
                                    if (count) {
                                      //Scaffold.of(context).
                                      print("update sucess");
                                      clocks = await Clock.getClocksByCourse(
                                          c.course);
                                           curCours=c.course;
                                      loadCourse();
                                    }
                                  }
                                 // ignore: use_build_context_synchronously
                                 Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.amber,
                                )),
                            IconButton(
                                onPressed: () async {
                                  var ret = await showQuestion();
                                  if (ret!) {
                                    var val = await Clock.delete(
                                        courses[index].course);
                                    if (val > 0) {
                                      loadCourse(showDef: true);
                                    }
                                  }
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                          ],
                        ));
            })),
      ),
    );
  }

  Future<bool?> showQuestion() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:  Text(AppLocalizations.of(context)!.deletewarining),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(AppLocalizations.of(context)!.no)),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(AppLocalizations.of(context)!.yes)),
            ],
          );
        });
  }

  Future<Clock?> showAlert(String? str) {
    TextEditingController controller = TextEditingController(text: str);
    return showDialog<Clock>(
        context: context,
        builder: (context) {
          var child = Column(
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.courseinfor),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.coursename),
                  ),
                  controller: controller,
                ),
              ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(AppLocalizations.of(context)!.coursecount),
            ),
              Expanded(
                child: ListView.builder(
                    itemCount: 500,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Container(
                          color: Colors.grey.shade50,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(index.toString()),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(
                              Clock(course: controller.text, number: index));
                        },
                      );
                    }),
              )
            ],
          );
          return Dialog(
            child: SizedBox(
              width: 80,
              height: 300,
              child: child,
            ),
          );
        });
  }
}


// class ProgressBar extends StatefulWidget {
//   ProgressBar({Key? key,required this.course}) : super(key: key);
//   String course;

//   @override
//   State<ProgressBar> createState() => _ProgressBarState();
// }

// class _ProgressBarState extends State<ProgressBar> {
//   @override
//   Widget build(BuildContext context) {
//     return  Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(widget.title),
//                Text("$curCours Progress: ${clocks.where((element) => element.isChecked).length}/${clocks.length}"),
//           ],
//         ),
//   }
// }
