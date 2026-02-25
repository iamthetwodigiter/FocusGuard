import 'package:focusguard/core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/achievements/models/achievement.dart';
import '../../features/session_history/models/focus_session.dart';
import '../../features/statistics/models/blocked_app_stat.dart';
import '../../features/website_blocking/models/website_info.dart';

class HiveService {
  static Future<void> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);

    // Open Boxes
    await Hive.openBox(AppConstants.appSettingsBox);
    await Hive.openBox(AppConstants.blockedAppsBox);
    await Hive.openBox<FocusSession>(AppConstants.sessionsBox);
    await Hive.openBox<Achievement>(AppConstants.achievementsBox);
    await Hive.openBox<WebsiteInfo>(AppConstants.websitesBox);
    await Hive.openBox<BlockedAppStat>(AppConstants.blockedAppStatsBox);
  }

  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  static Future<void> close() async {
    await Hive.close();
  }
}