import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';

class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  static AppStrings of(BuildContext context, WidgetRef ref) {
    return AppStrings(ref.watch(appLocaleProvider));
  }

  static AppStrings fromLocale(AppLocale locale) {
    return AppStrings(locale);
  }

  bool get isChinese => locale == AppLocale.zh;

  String get planLibrary => isChinese ? '计划库' : 'Plan Library';
  String get builtIn => isChinese ? '内置' : 'Built-in';
  String get custom => isChinese ? '自定义' : 'Custom';
  String get active => isChinese ? '当前' : 'Active';
  String get current => isChinese ? '当前计划' : 'Current';
  String get switchPlan => isChinese ? '切换' : 'Switch';
  String get edit => isChinese ? '编辑' : 'Edit';
  String get newPlan => isChinese ? '新建计划' : 'New Plan';
  String workoutsCount(int count) =>
      isChinese ? '$count 次训练日' : '$count workouts';
  String exercisesCount(int count) =>
      isChinese ? '$count 个动作' : '$count exercises';
  String activeInstancesCount(int count) =>
      isChinese ? '$count 个进行中实例' : '$count active instance(s)';
  String get setTrainingMaxes => isChinese ? '设置训练最大值' : 'Set Training Maxes';
  String get startPlan => isChinese ? '开始计划' : 'Start Plan';
  String get cancel => isChinese ? '取消' : 'Cancel';
  String get enterValidMax => isChinese ? '请输入有效重量' : 'Enter a valid max';
  String get todayWorkout => isChinese ? '今日训练' : 'TODAY\'S WORKOUT';
  String get sharePlan => isChinese ? '分享计划' : 'Share plan';
  String get resume => isChinese ? '继续训练' : 'Resume';
  String get start => isChinese ? '开始训练' : 'Start';
  String mins(int minutes) => isChinese ? '$minutes 分钟' : '$minutes mins';
  String dayMinutes(String dayLabel, int minutes) =>
      isChinese ? '$dayLabel · $minutes 分钟' : '$dayLabel • $minutes mins';
  String exercisesLabel(int count) =>
      isChinese ? '$count 个动作' : '$count exercises';
  String get rotation => isChinese ? '轮换' : 'Rotation';
  String get leadLift => isChinese ? '主项' : 'Lead Lift';
  String get goodMorning => isChinese ? '早上好，' : 'Good morning,';
  String get atAGlance => isChinese ? '概览' : 'AT A GLANCE';
  String get activity => isChinese ? '活动' : 'ACTIVITY';
  String get insights => isChinese ? '洞察' : 'Insights';
  String get insightsSubtitle =>
      isChinese ? '训练分析会显示在这里。' : 'Progress analytics will live here.';
  String get progressAnalytics => isChinese ? '进步分析' : 'Progress Analytics';
  String get analyticsEmptyTitle =>
      isChinese ? '还没有足够的训练记录' : 'Not enough training history yet';
  String get analyticsEmptySubtitle => isChinese
      ? '完成几次训练后，这里会显示动作 1RM、PR 和训练趋势。'
      : 'Finish a few workouts and this screen will show exercise 1RM, PRs, and trends.';
  String get formula => isChinese ? '公式' : 'Formula';
  String get estimatedOneRepMax => isChinese ? '预估 1RM' : 'Estimated 1RM';
  String get actualOneRepMax => isChinese ? '真实 1RM' : 'Actual 1RM';
  String get noActualOneRepMax => isChinese ? '暂无真实 1RM' : 'No actual 1RM yet';
  String get recentChange => isChinese ? '最近变化' : 'Recent change';
  String get recentVolume => isChinese ? '近30天吨位' : '30-day volume';
  String get trainingDays => isChinese ? '训练天数' : 'Training days';
  String get workoutsCompleted => isChinese ? '完成训练' : 'Workouts done';
  String get highlightLift => isChinese ? '进步最快动作' : 'Top improving lift';
  String get allExercises => isChinese ? '全部动作' : 'All exercises';
  String get exerciseDetails => isChinese ? '动作详情' : 'Exercise details';
  String get bestEstimatedOneRepMax =>
      isChinese ? '历史最高预估 1RM' : 'Best estimated 1RM';
  String get bestActualOneRepMax =>
      isChinese ? '历史最高真实 1RM' : 'Best actual 1RM';
  String get bestSet => isChinese ? '最佳组' : 'Best set';
  String get personalRecords => isChinese ? 'PR 记录' : 'Personal records';
  String get stagnating => isChinese ? '停滞中' : 'Stagnating';
  String get activeFormula => isChinese ? '当前公式' : 'Active formula';
  String get encounterCount => isChinese ? '记录次数' : 'Sessions logged';
  String get lastSeen => isChinese ? '最近训练' : 'Last trained';
  String get estimatedTrend => isChinese ? '预估 1RM 趋势' : 'Estimated 1RM trend';
  String get actualTrend => isChinese ? '真实 1RM 记录' : 'Actual 1RM history';
  String noRecentChangeLabel() => isChinese ? '暂无变化样本' : 'No recent delta';
  String kilograms(double value) =>
      isChinese ? '${value.toStringAsFixed(1)} 公斤' : '${value.toStringAsFixed(1)} kg';
  String plusMinusKilograms(double value) {
    final prefix = value > 0 ? '+' : '';
    return isChinese
        ? '$prefix${value.toStringAsFixed(1)} 公斤'
        : '$prefix${value.toStringAsFixed(1)} kg';
  }
  String sessionsLogged(int count) =>
      isChinese ? '$count 次记录' : '$count sessions';
  String daysAgo(int days) =>
      isChinese ? '$days 天前' : '$days day${days == 1 ? '' : 's'} ago';
  String get profile => isChinese ? '我的' : 'Profile';
  String get settings => isChinese ? '设置' : 'Settings';
  String get language => isChinese ? '语言' : 'Language';
  String get languageSubtitle =>
      isChinese ? '切换应用界面和内置计划语言' : 'Switch app and built-in plan language';
  String get chinese => '中文';
  String get english => 'English';
  String get shareTrainingPlan => isChinese ? '分享训练计划' : 'SHARE TRAINING PLAN';
  String get qrContainsPlan => isChinese
      ? '这个二维码包含完整计划 JSON 的压缩分享内容。'
      : 'This QR code contains the full plan JSON in a compressed share format.';
  String payloadSize(int length) =>
      isChinese ? '载荷长度：$length 字符' : 'Payload size: $length chars';
  String get scanPlanQr => isChinese ? '扫描计划二维码' : 'SCAN A PLAN QR';
  String importedTemplate(String name) => isChinese
      ? '已将 $name 导入到本地模板。'
      : 'Imported $name to local templates.';
  String get invalidPlanQr =>
      isChinese ? '无效的训练计划二维码。' : 'Invalid training plan QR code.';
  String get noActiveWorkoutSession =>
      isChinese ? '当前没有进行中的训练。' : 'No active workout session.';
  String get workoutSaved =>
      isChinese ? '训练已保存，已载入下一次训练。' : 'Workout saved. Next day loaded.';
  String get saving => isChinese ? '保存中...' : 'Saving...';
  String get concludeWorkout =>
      isChinese ? '完成本次训练' : 'Conclude Workout';
  String get noActivePlan =>
      isChinese ? '当前没有激活的训练计划，请先去计划库开始。' : 'No active training plan instance. Open Plan Library to start one.';
}
