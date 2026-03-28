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
  String get progressAnalyticsSubtitle => isChinese
      ? '按动作查看预估 1RM、真实 1RM、PR 与停滞情况。'
      : 'Track estimated 1RM, actual 1RM, PRs, and stagnation by exercise.';
  String get strengthTrajectory => isChinese ? '力量轨迹' : 'Strength Trajectory';
  String get strengthTrajectorySubtitle => isChinese
      ? '先给出总体节奏，再下钻到单动作的预估 1RM、真实 1RM、PR 与停滞。减少重复黑块，强化阅读节奏。'
      : 'Start with overall momentum, then drill into per-lift estimated 1RM, actual 1RM, PRs, and stagnation.';
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
  String kilograms(double value) => isChinese
      ? '${value.toStringAsFixed(1)} 公斤'
      : '${value.toStringAsFixed(1)} kg';
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
  String get advancedAnalytics => isChinese ? '趋势与分析' : 'Trends & Analytics';
  String get advancedAnalyticsSubtitle => isChinese
      ? '从训练一致性和负荷分布里查看长期节奏。'
      : 'Review long-term rhythm through consistency and training load.';
  String get consistencyByWeek => isChinese ? '按周' : 'Week';
  String get consistencyByMonth => isChinese ? '按月' : 'Month';
  String get consistencyByPlan => isChinese ? '从计划开始' : 'From Plan Start';
  String get trainingConsistency =>
      isChinese ? '训练一致性' : 'Training Consistency';
  String get consistencyHint => isChinese
      ? '点击有记录的日期可查看当天训练内容。'
      : 'Tap a recorded day to inspect that day\'s training log.';
  String get noConsistencyRecords =>
      isChinese ? '这个时间范围还没有训练记录。' : 'No training records for this range yet.';
  String consistencySessions(int count) =>
      isChinese ? '$count 次训练' : '$count session${count == 1 ? '' : 's'}';
  String get muscleTrainingLoad =>
      isChinese ? '肌群训练负荷（每周组数）' : 'Muscle Training Load (Sets/Week)';
  String get anatomicalLoadMap => isChinese ? '解剖负荷图' : 'ANATOMICAL LOAD MAP';
  String get anatomicalLoadPlaceholder => isChinese
      ? '更高分辨率的肌群激活叠加图会在后续版本中推出。'
      : 'High-resolution muscle activation overlay\ncoming in a future update.';
  String get recordedWorkoutDetails =>
      isChinese ? '训练记录详情' : 'Workout Record Details';
  String recordedDayTitle(DateTime date) => isChinese
      ? '${date.year}年${date.month}月${date.day}日'
      : '${date.month}/${date.day}/${date.year}';
  String get workoutSummaryLabel => isChinese ? '训练概览' : 'Workout Summary';
  String setSummary(int sets, double volume) => isChinese
      ? '$sets 组 · ${volume.toStringAsFixed(1)} 公斤吨位'
      : '$sets sets · ${volume.toStringAsFixed(1)} kg volume';
  String get completedSets => isChinese ? '已完成组数' : 'Completed sets';
  String get noWorkoutRecordsForDay => isChinese
      ? '当天没有可展示的训练记录。'
      : 'No workout records available for that day.';
  String get sessionHistory => isChinese ? '训练历史' : 'SESSION HISTORY';
  String e1rmLabel(double value) => isChinese
      ? '预估 1RM：${value.toStringAsFixed(1)} 公斤'
      : 'E1RM: ${value.toStringAsFixed(1)} kg';
  String get change30d => isChinese ? '30天变化' : '30D CHANGE';
  String get gaining => isChinese ? '提升中' : 'Gaining';
  String get totalLogged => isChinese ? '累计记录' : 'Total logged';
  String get strengthTrendsOverlay =>
      isChinese ? '力量趋势叠加' : 'Strength Trends Overlay';
  String get profile => isChinese ? '我的' : 'Profile';
  String get settings => isChinese ? '设置' : 'Settings';
  String get account => isChinese ? '账户' : 'Account';
  String get accountSubtitle => isChinese
      ? '登录后即可在设备间同步你的计划、训练记录和进度数据'
      : 'Sign in to sync your plans, workouts, and progress across devices';
  String get signedOut => isChinese ? '未登录' : 'Signed out';
  String get signedIn => isChinese ? '已登录' : 'Signed in';
  String get signedInNoEmail => isChinese ? '已登录账户' : 'Signed-in account';
  String get signIn => isChinese ? '登录' : 'Sign In';
  String get createAccount => isChinese ? '创建账户' : 'Create Account';
  String get signOut => isChinese ? '退出登录' : 'Sign Out';
  String get email => isChinese ? '邮箱' : 'Email';
  String get password => isChinese ? '密码' : 'Password';
  String get manageAccount => isChinese ? '管理账户' : 'Manage Account';
  String get syncReady =>
      isChinese ? '已登录，等待开始同步。' : 'Signed in and ready to sync.';
  String get syncHydrating =>
      isChinese ? '正在载入此账户的云端数据...' : 'Loading this account\'s cloud data...';
  String get syncInProgress =>
      isChinese ? '正在同步最新更改...' : 'Syncing your latest changes...';
  String get syncComplete => isChinese ? '云端数据已同步。' : 'Cloud data is synced.';
  String get syncRetryNeeded =>
      isChinese ? '同步未完成，请重试。' : 'Sync did not complete. Retry is needed.';
  String get syncNow => isChinese ? '立即同步' : 'Sync Now';
  String get retrySync => isChinese ? '重试同步' : 'Retry Sync';
  String get supabaseUnavailable =>
      isChinese ? 'Supabase 尚未配置' : 'Supabase Not Configured';
  String get supabaseUnavailableHint => isChinese
      ? '请先通过 dart-define 提供 SUPABASE_URL 和 SUPABASE_ANON_KEY；Debug 模式下会优先尝试连接本地 Supabase 开发环境。'
      : 'Provide SUPABASE_URL and SUPABASE_ANON_KEY via dart-define first; debug builds will also try the local Supabase dev stack.';
  String get workingState => isChinese ? '处理中...' : 'Working...';
  String get language => isChinese ? '语言' : 'Language';
  String get languageSubtitle =>
      isChinese ? '切换应用界面和内置计划语言' : 'Switch app and built-in plan language';
  String get chinese => '中文';
  String get english => 'English';
  String get trainingSetGuide => isChinese ? '训练组类型指南' : 'Training Set Guide';
  String get trainingSetGuideSubtitle => isChinese
      ? '查看 AMRAP、Top Set、Backoff Set 等组类型说明'
      : 'Review AMRAP, top set, backoff set, and other set types';
  String get openGuide => isChinese ? '查看指南' : 'Open Guide';
  String get templateEditor => isChinese ? '计划编辑' : 'Template Editor';
  String get scheduleMode => isChinese ? '计划模式' : 'Schedule Mode';
  String get linearPlan => isChinese ? '线性计划' : 'Linear Plan';
  String get periodizedPlan => isChinese ? '周期计划' : 'Periodized Plan';
  String get weekDaySlot => isChinese ? '周/天槽位' : 'Week/Day Slot';
  String get setType => isChinese ? '组类型' : 'Set Type';
  String get loadUnit => isChinese ? '单位' : 'Load Unit';
  String get templateName => isChinese ? '计划名称' : 'Template Name';
  String get workoutName => isChinese ? '训练日名称' : 'Workout Name';
  String get dayLabel => isChinese ? '日标签' : 'Day Label';
  String get minutes => isChinese ? '分钟' : 'Minutes';
  String get movementId => isChinese ? '动作 ID' : 'Movement Id';
  String get tier => isChinese ? '层级' : 'Tier';
  String get restSeconds => isChinese ? '休息（秒）' : 'Rest (sec)';
  String get startWeight => isChinese ? '起始重量' : 'Start Weight';
  String get stageName => isChinese ? '阶段名称' : 'Stage Name';
  String get sets => isChinese ? '训练组' : 'Sets';
  String get progression => isChinese ? '进展规则' : 'Progression';
  String get onSuccess => isChinese ? '成功后' : 'On Success';
  String get onFailure => isChinese ? '失败后' : 'On Failure';
  String get role => isChinese ? '角色' : 'Role';
  String get reps => isChinese ? '次数' : 'Reps';
  String get intensity => isChinese ? '强度' : 'Intensity';
  String get warmup => isChinese ? '热身组' : 'Warmup';
  String get working => isChinese ? '工作组' : 'Working';
  String get addWorkout => isChinese ? '新增训练日' : 'Add Workout';
  String get addExercise => isChinese ? '新增动作' : 'Add Exercise';
  String get addStage => isChinese ? '新增阶段' : 'Add Stage';
  String get addSet => isChinese ? '新增训练组' : 'Add Set';
  String get save => isChinese ? '保存' : 'Save';
  String get share => isChinese ? '分享' : 'Share';
  String get composition => isChinese ? '身体构成' : 'COMPOSITION';
  String get bodyMetrics => isChinese ? '身体指标' : 'Body Metrics';
  String get bodyMetricsSubtitle => isChinese
      ? '在杠铃之外，持续记录你的身体变化。'
      : 'Track your physical transformation beyond the barbell.';
  String get currentSnapshot => isChinese ? '当前快照' : 'CURRENT SNAPSHOT';
  String get measurementLog => isChinese ? '测量记录' : 'MEASUREMENT LOG';
  String get progressSurface => isChinese ? '进展主视图' : 'Progress Surface';
  String get weightProgression => isChinese ? '体重趋势' : 'Weight Progression';
  String get bodyFat => isChinese ? '体脂' : 'BODY FAT';
  String get waist => isChinese ? '腰围' : 'WAIST';
  String get recordFirstCheckIn =>
      isChinese ? '记录你的第一次身体检查' : 'Record your first check-in';
  String get noWeightTrendYet =>
      isChinese ? '暂时还没有体重趋势' : 'Weight trend not available yet';
  String get bodyMetricsHeroEmptyBody => isChinese
      ? '先记录体重、体脂、腰围或备注，让这个页面从空白占位变成真正的进展仪表盘。'
      : 'Start with weight, body fat, waist, or a quick note so this page can become a progress dashboard instead of an empty shell.';
  String get bodyMetricsHeroPartialBody => isChinese
      ? '你已经保存了部分测量，但还没有体重趋势。补充一次更完整的记录后，这里会显示主要进展视图。'
      : 'You have measurements saved, but no weight trend yet. Add a fuller check-in to unlock the primary progress view.';
  String get addFirstMeasurement =>
      isChinese ? '添加第一次测量' : 'Add first measurement';
  String get addCompleteMeasurement =>
      isChinese ? '添加完整测量' : 'Add complete measurement';
  String get heroAreaIntentionalHint => isChinese
      ? '即使趋势数据还不存在，这个主区域也应该保持明确而有意义。'
      : 'This hero area stays intentional even before trend data exists.';
  String latestWeightOn(double weight, String dateLabel) => isChinese
      ? '最新：${weight.toStringAsFixed(1)} 公斤 · $dateLabel'
      : 'Latest: ${weight.toStringAsFixed(1)} kg on $dateLabel';
  String latestWeightDelta(double weight, String deltaLabel) => isChinese
      ? '最新：${weight.toStringAsFixed(1)} 公斤（$deltaLabel）'
      : 'Latest: ${weight.toStringAsFixed(1)} kg ($deltaLabel)';
  String get completeMetricsHint => isChinese
      ? '继续补充体脂和腰围，获得更完整的身体快照。'
      : 'Keep going to complete body fat and waist for a fuller snapshot.';
  String get weightTrendAnchorHint => isChinese
      ? '最新体重趋势会作为这个身体构成页面的主线索。'
      : 'Your latest body-weight trend anchors the rest of this composition view.';
  String get noBodyMeasurementsYet =>
      isChinese ? '还没有身体测量记录' : 'No body measurements yet';
  String get latestCheckInIncomplete =>
      isChinese ? '你最近一次记录还不完整' : 'Your latest check-in is incomplete';
  String get emptyMeasurementsCallout => isChinese
      ? '先添加第一次测量，这里就会开始形成趋势和当前快照。'
      : 'Add your first measurement to start building trend context and a current snapshot.';
  String get partialMeasurementsCallout => isChinese
      ? '你已经记录了一部分数据，但关键指标还不完整。补充一次测量后，这页会提供更好的对比信息。'
      : 'You have data recorded, but some key metrics are still missing. Add another measurement to complete your snapshot and unlock better comparisons.';
  String get addMeasurement => isChinese ? '添加测量' : 'Add measurement';
  String get completeLatestSnapshot =>
      isChinese ? '补完整最新快照' : 'Complete latest snapshot';
  String get noRecordedEntries => isChinese ? '暂无已记录条目' : 'No recorded entries';
  String latestEntry(DateTime timestamp) => isChinese
      ? '最近记录：${longDate(timestamp)}'
      : 'Latest entry: ${longDate(timestamp)}';

  String get comparisonNotAvailableYet =>
      isChinese ? '暂时还没有可比较的上一条记录。' : 'Comparison not available yet.';
  String get addThisMetricNextCheckIn =>
      isChinese ? '下一次记录时补上这个指标。' : 'Add this metric in your next check-in.';
  String get notYetRecorded => isChinese ? '尚未记录' : 'Not yet recorded';
  String bodyMetricChangeVsPrevious(double delta, String unit) {
    final prefix = delta > 0 ? '+' : '';
    return isChinese
        ? '相较上一条可比较记录：$prefix${delta.toStringAsFixed(1)} $unit'
        : 'Change vs previous comparable entry: $prefix${delta.toStringAsFixed(1)} $unit';
  }

  String get bodyMeasurementLogEmpty => isChinese
      ? '保存第一条身体记录后，测量日志会显示在这里。'
      : 'Your measurement log will appear here once you save a check-in.';
  String get addMeasurementTitle => isChinese ? '添加身体测量' : 'Add Measurement';
  String get weightKgLabel => isChinese ? '体重（kg）' : 'Weight (kg)';
  String get bodyFatLabel => isChinese ? '体脂（%）' : 'Body fat (%)';
  String get waistCmLabel => isChinese ? '腰围（cm）' : 'Waist (cm)';
  String get noteOptional => isChinese ? '备注（可选）' : 'Note (optional)';
  String get deleteMeasurement => isChinese ? '删除测量记录' : 'Delete measurement';
  String get waistSuffix => isChinese ? '腰围' : 'waist';
  String shortMonthDay(DateTime date) => isChinese
      ? '${date.month}月${date.day}日'
      : '${_englishMonthShort(date.month)} ${date.day}';
  String longDate(DateTime date) => isChinese
      ? '${date.year}年${date.month}月${date.day}日'
      : '${_englishMonthShort(date.month)} ${date.day}, ${date.year}';
  String weekdayName(DateTime date) =>
      isChinese ? _chineseWeekday(date.weekday) : _englishWeekday(date.weekday);
  String get topSet => isChinese ? '顶组' : 'Top Set';
  String get straightSet => isChinese ? '直组' : 'Straight Set';
  String get backoffSet => isChinese ? '回退组' : 'Backoff Set';
  String get amrapSet => isChinese ? 'AMRAP 组' : 'AMRAP Set';
  String get percent1rm => isChinese ? '1RM 百分比' : '%1RM';
  String get cableStack => isChinese ? '龙门架片数' : 'Cable Stack';
  String get shareTrainingPlan => isChinese ? '分享训练计划' : 'SHARE TRAINING PLAN';
  String get qrContainsPlan => isChinese
      ? '这个二维码包含完整计划 JSON 的压缩分享内容。'
      : 'This QR code contains the full plan JSON in a compressed share format.';
  String payloadSize(int length) =>
      isChinese ? '载荷长度：$length 字符' : 'Payload size: $length chars';
  String get scanPlanQr => isChinese ? '扫描计划二维码' : 'SCAN A PLAN QR';
  String importedTemplate(String name) =>
      isChinese ? '已将 $name 导入到本地模板。' : 'Imported $name to local templates.';
  String get invalidPlanQr =>
      isChinese ? '无效的训练计划二维码。' : 'Invalid training plan QR code.';
  String get noActiveWorkoutSession =>
      isChinese ? '当前没有进行中的训练。' : 'No active workout session.';
  String get workoutSaved =>
      isChinese ? '训练已保存，已载入下一次训练。' : 'Workout saved. Next day loaded.';
  String get saving => isChinese ? '保存中...' : 'Saving...';
  String get concludeWorkout => isChinese ? '完成本次训练' : 'Conclude Workout';
  String get noActivePlan => isChinese
      ? '当前没有激活的训练计划，请先去计划库开始。'
      : 'No active training plan instance. Open Plan Library to start one.';

  String _englishMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _englishWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _chineseWeekday(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }
}
