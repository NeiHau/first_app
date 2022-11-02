import 'package:first_app/page/event_adding_page.dart';
import 'package:first_app/view/calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime now = DateTime.now();
  String? newTask;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: PageController(initialPage: 1500),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      createTask();
                    },
                    child:
                        const Calendar(weekDay: 1)); // 何曜日からはじまるか（月曜日は1,日曜日は7),
              },
              onPageChanged: (value) {
                getNextMonth();
              },
            ),
          ),
        ],
      ),
    );
  }

  getNextMonth() {
    if (now.month == 12) {
      now = DateTime(now.year + 1, 1);
    } else {
      now = DateTime(now.year, now.month + 1);
    }
    return now;
  }

  getPrevMonth() {
    if (now.month == 1) {
      now = DateTime(now.year - 1, 12);
    } else {
      now = DateTime(now.year, now.month - 1);
    }
    return now;
  }

  void createTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AlertDialog(
              title: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy/MM/dd (EEE)', 'ja').format(
                        DateTime(now.year, now.month, now.day),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // （2） 実際に表示するページ(ウィジェット)を指定する
                            builder: (context) => EventAddingPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              content: const SizedBox(
                height: 360,
                width: 400,
                child: Center(
                  child: Text('予定がありません。'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
