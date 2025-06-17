// import 'dart:io';
// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// import 'tables/todo_table.dart';
// import 'tables/weather_table.dart';
// import 'tables/settings_table.dart';
// import 'dao/todo_dao.dart';
// import 'dao/weather_dao.dart';
// import 'dao/settings_dao.dart';

// part 'database.g.dart';

// /// 应用主数据库
// /// 使用Drift ORM提供类型安全的数据库操作
// @DriftDatabase(
//   tables: [
//     TodoTable,
//     WeatherCacheTable, 
//     SettingsTable,
//   ],
//   daos: [
//     TodoDao,
//     WeatherDao,
//     SettingsDao,
//   ],
// )
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;

//   @override
//   MigrationStrategy get migration {
//     return MigrationStrategy(
//       onCreate: (Migrator m) async {
//         await m.createAll();
//       },
//       onUpgrade: (Migrator m, int from, int to) async {
//         // 未来版本升级时的迁移逻辑
//       },
//     );
//   }
// }

// /// 打开数据库连接
// /// 支持不同平台的数据库路径配置
// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     // 确保在移动平台上有sqlite3
//     if (Platform.isAndroid) {
//       await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
//     }

//     // 设置数据库文件路径
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'precious_life.db'));
    
//     // 在桌面平台，额外加载sqlite3
//     if (Platform.isWindows || Platform.isLinux) {
//       final cachebase = (await getTemporaryDirectory()).path;
//       sqlite3.tempDirectory = cachebase;
//     }

//     return NativeDatabase.createInBackground(file);
//   });
// } 