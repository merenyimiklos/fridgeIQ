import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fridgeiq/app.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.settingsBoxName);
  runApp(const ProviderScope(child: FridgeIQApp()));
}
