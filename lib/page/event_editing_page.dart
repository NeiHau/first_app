import 'package:first_app/model/db/todo_item_data.dart';
import 'package:first_app/model/freezed/event.dart';
import 'package:first_app/state_notifier/add_event_state_notifier.dart';
import 'package:first_app/view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../view/calendar_event_list.dart';

final startDayProvider = StateProvider((ref) => DateTime.now());
final finishDayProvider = StateProvider((ref) => DateTime.now());

class EventEditingPage extends ConsumerStatefulWidget {
  EventEditingPage({this.event, super.key});

  final Event? event;
  CalendarEventList calendarEventList = const CalendarEventList();

  @override
  ConsumerState<EventEditingPage> createState() => EventEditingPageState();
}

class EventEditingPageState extends ConsumerState<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  late FocusNode addTaskFocusNode;
  bool isAllDay = false;
  Event temp = Event();

  @override
  void initState() {
    super.initState();

    if (widget.event == null) {
      startDate = DateTime.now();
      endDate = DateTime.now().add(const Duration(hours: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = ref.watch(todoDatabaseProvider.notifier);
    List<TodoItemData> todoItems = todoProvider.state.todoItems;

    final TodoItemData args =
        ModalRoute.of(context)?.settings.arguments as TodoItemData;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Center(
          child: Text('予定の編集'),
        ),
        leading: const CloseButton(),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildTitle(args),
              sizedBox(),
              selectShujitsuStartDay(args),
              buildDescription(args),
              sizedBox(),
              deleteSchedule(todoItems, todoProvider),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions() => [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
            child: const Text('保存'),
          ),
        )
      ];

  Widget buildTitle(TodoItemData data) => Card(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 5, 5),
          child: TextFormField(
            initialValue: data.title,
            onChanged: (value) {
              temp = temp.copyWith(title: value);
            },
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: UnderlineInputBorder(),
              hintText: 'タイトルを入力してください',
            ),
          ),
        ),
      );

  Card selectShujitsuStartDay(TodoItemData data) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: const Text('終日'),
            trailing: createSwitch(0),
          ),
          ListTile(
            title: const Text('開始'),
            trailing: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: Text(isAllDay
                  ? DateFormat('yyyy-MM-dd').format(startDate)
                  : DateFormat('yyyy-MM-dd HH:mm').format(startDate)),
              onPressed: () {
                cupertinoDatePicker(CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    setState(() {
                      startDate = value;
                    });
                  },
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minuteInterval: 15,
                  initialDateTime: DateTime(
                    data.startDate!.year,
                    data.startDate!.month,
                    data.startDate!.day,
                    data.startDate!.hour,
                    //startDate.minute,
                  ),
                ));
              },
            ),
          ),
          ListTile(
            title: const Text('終了'),
            trailing: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: Text(isAllDay
                  ? DateFormat('yyyy-MM-dd').format(startDate)
                  : DateFormat('yyyy-MM-dd HH:mm').format(startDate)),
              onPressed: () {
                cupertinoDatePicker(CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    setState(() {
                      startDate = value;
                    });
                  },
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minuteInterval: 15,
                  initialDateTime: DateTime(
                    data.endDate!.year,
                    data.endDate!.month,
                    data.endDate!.day,
                    data.endDate!.hour,
                    //startDate.minute,
                  ),
                ));
              },
            ),
          )
        ],
      ),
    );
  }

  Switch createSwitch(int index) {
    return Switch(
      value: isAllDay,
      onChanged: (value) {
        setState(() {
          isAllDay = value;
        });
      },
    );
  }

  Widget buildDescription(TodoItemData data) {
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 5, 5),
        child: TextFormField(
          initialValue: data.description,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            border: UnderlineInputBorder(),
            hintText: '入力してください',
          ),
          maxLines: 8,
        ),
      ),
    );
  }

  Widget deleteSchedule(
      List<TodoItemData> todoItemList, TodoDatabaseNotifier db) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        backgroundColor: Colors.white,
        fixedSize: const Size(450, 50), //(横、高さ)
      ),
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  child: const Text('編集を破棄'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text("予定の削除"),
                          content: const Text('本当にこの日の予定を削除しますか？'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "キャンセル",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // db.deleteData();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CalendarPage()));
                              },
                              child: const Text('削除'),
                            ),
                          ],
                        );
                      },
                    ),
                  },
                ),
                CupertinoActionSheetAction(
                  child: const Text('キャンセル'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                  },
                ),
              ],
            );
          },
        );
      },
      child: const Text('この予定を削除'),
    );
  }

  Future<void> cupertinoDatePicker(Widget child) async {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => Container(
              height: 280,
              padding: const EdgeInsets.only(top: 6),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('キャンセル')),
                        TextButton(
                            onPressed: () {
                              final isEndTimeBefore =
                                  startDate.isBefore(startDate);
                              final isEqual =
                                  startDate.microsecondsSinceEpoch ==
                                      startDate.millisecondsSinceEpoch;

                              if (isAllDay) {
                                if (isEndTimeBefore || isEqual) {
                                  setState(() {
                                    startDate = startDate;
                                  });
                                }
                              } else {
                                if (isEndTimeBefore || isEqual) {
                                  setState(() {
                                    startDate =
                                        startDate.add(const Duration(hours: 1));
                                  });
                                }
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('完了'))
                      ],
                    ),
                  ),
                  Expanded(child: SafeArea(top: false, child: child)),
                ],
              ),
            ));
  }

  Widget sizedBox() {
    return const SizedBox(
      height: 25,
      width: 10,
    );
  }
}

/*
for (TodoItemData item in todoItemList) {
                                  db.deleteData(item);
                                }

*/
