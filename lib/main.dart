import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:todo_list/services/database_service.dart';

import 'models/task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Todo App Demo',
          theme: ThemeData(
            textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
              bodyMedium: GoogleFonts.poppins(textStyle: textTheme.bodyMedium),
            ),
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  int taskCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Initial load
  }

  // run when add/delete new task for task count update
  void _loadTasks() async {
    final tasks = await DatabaseService.instance.getTasks();
    setState(() {
      taskCount = tasks.length;
    });
  }

  String? _task = null;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: floatingButton(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopSection(),
              Divider(color: Colors.black87),
              TaskListSection(),
            ],
          ),
        ),
      ),
    );
  }
  

  // this section show list of task that mad by user 
  FutureBuilder<List<Task>> TaskListSection() {
    return FutureBuilder(
              future: _databaseService.getTasks(),
              builder: (context, snapshot) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = snapshot.data![index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        selectedTileColor:
                            task.status == 1 ? Colors.blue[70] : Colors.white,
                        selectedColor:
                            task.status == 1 ? Colors.blue[70] : Colors.white,
                        tileColor:
                            task.status == 1 ? Colors.blue[70] : Colors.white,
                        leading: Checkbox(
                          value: task.status == 1,
                          onChanged: (value) {
                            // check data update in database
                            _databaseService.updateTaskStatus(
                              task.id,
                              value == true ? 1 : 0,
                            );

                            setState(() {
                            });
                          },
                        ),
                        title: Text(
                          task.content,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        trailing: InkWell(
                          onTap: () {
                            _databaseService.deleteTask(task.id);
                            _loadTasks();
                            setState(() {});
                          },
                          child: Icon(Icons.delete),
                        ),
                      ),
                    );
                  },
                );
              },
            );
  }

  Container TopSection() {
    String getDayWithSuffix(int day) {
      if (day >= 11 && day <= 13) {
        return '${day}th';
      }
      switch (day % 10) {
        case 1:
          return '${day}st';
        case 2:
          return '${day}nd';
        case 3:
          return '${day}rd';
        default:
          return '${day}th';
      }
    }

    final now = DateTime.now();
    final dayWithSuffix = getDayWithSuffix(now.day);

    return Container(
      height: 70.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white70),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${DateFormat('EEEE').format(DateTime.now())}, ",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: dayWithSuffix,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 25,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        subtitle: Text(
          DateFormat('MMMM').format(DateTime.now()).toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        trailing: Text(
          "$taskCount Task",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // add new task section 
  FloatingActionButton floatingButton(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40), // set your desired radius here
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text("Add Task"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _task = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Write Task",
                      ),
                    ),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        if (_task == null || _task == "") return;
                        _databaseService.addTask(_task!);
                        _loadTasks();
                        setState(() {
                          _task = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.blueAccent,
    );
  }
}
