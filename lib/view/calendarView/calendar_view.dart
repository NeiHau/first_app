import 'package:first_app/view/calendarView/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime now = DateTime.now();
  late final PageController calendarController;
  int initialPage = 0;
  final DateTime firstDay = DateTime(1970, 1, 1);

  @override
  void initState() {
    initialPage = _getInitialPageCount(firstDay, now);
    calendarController = PageController(initialPage: initialPage);
    super.initState();
  }

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
              controller: calendarController,
              itemBuilder: (context, index) {
                return Calendar(calendarController: calendarController);
              },
              onPageChanged: (value) {
                ref.read(foucusedDayProvider.notifier).update((state) {
                  final distance = initialPage - value;
                  return DateTime(now.year, now.month - distance);
                });
                // print(ref.read(foucusedDayProvider.notifier).state);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 現在表示されている月から指定されている最初の年月まで、どのくらいの月数があるのかを計算する際に用いる。
  int _getInitialPageCount(DateTime first, DateTime now) {
    final firstCount = first.year * 12 + first.month;
    final nowCount = now.year * 12 + now.month;
    return nowCount - firstCount;
  }
}
