import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:first_app/model/freezed/event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'todo_item_data.g.dart';

class TodoItem extends Table {
  TextColumn get id => text()();

  TextColumn get title =>
      text().withDefault(const Constant('')).withLength(min: 1)();

  TextColumn get description => text().withDefault(const Constant(''))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();

  BoolColumn get shujitsuBool => boolean().withDefault(const Constant(false))();

  // primaryKeyをここで宣言。
  // これがないとMyDatabaseクラスの'updateTodo'メソッドでエラーが起きる。
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TodoItem])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 全てのデータ取得
  Future<List<TodoItemData>> readAllTodoData() => select(todoItem).get();

  // 追加
  Future writeTodo(TodoItemCompanion data) => into(todoItem).insert(data);

  // 更新
  Future updateTodo(TodoItemData data) => update(todoItem).replace(data);

  // 削除
  Future deleteTodo(Event data) =>
      (delete(todoItem)..where((it) => it.id.equals(data.id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}