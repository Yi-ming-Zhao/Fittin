import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/one_rep_max.dart';
import 'package:fittin_v2/src/domain/starting_load_estimator.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart'
    show FittinPaletteId;

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

  String get navToday => isChinese ? '今天' : 'TODAY';
  String get navPlans => isChinese ? '计划' : 'PLANS';
  String get navPr => isChinese ? '力量' : 'PR';
  String get navBody => isChinese ? '身体' : 'BODY';
  String get navMe => isChinese ? '我的' : 'ME';

  String get planLibrary => isChinese ? '计划库' : 'Plan Library';
  String get trainingPlans => isChinese ? '训练计划' : 'Training plans';
  String get trainingPlansSubtitle => isChinese
      ? '在同一处查看内置模板、自定义计划与当前运行实例。'
      : 'Review built-in templates, custom plans, and active instances in one place.';
  String get builtIn => isChinese ? '内置' : 'Built-in';
  String get custom => isChinese ? '自定义' : 'Custom';
  String get all => isChinese ? '全部' : 'All';
  String get active => isChinese ? '当前' : 'Active';
  String get current => isChinese ? '当前计划' : 'Current';
  String get currentlyActive => isChinese ? '当前运行中' : 'CURRENTLY ACTIVE';
  String get switchPlan => isChinese ? '切换' : 'Switch';
  String get edit => isChinese ? '编辑' : 'Edit';
  String get delete => isChinese ? '删除' : 'Delete';
  String get newPlan => isChinese ? '新建计划' : 'New Plan';
  String workoutsCount(int count) =>
      isChinese ? '$count 次训练日' : '$count workouts';
  String exercisesCount(int count) =>
      isChinese ? '$count 个动作' : '$count exercises';
  String activeInstancesCount(int count) =>
      isChinese ? '$count 个进行中实例' : '$count active instance(s)';
  String get workoutsStat => isChinese ? '训练日' : 'Workouts';
  String get exercisesStat => isChinese ? '动作' : 'Exercises';
  String get runningStat => isChinese ? '运行实例' : 'Running';
  String get weeklyStructure => isChinese ? '每周结构' : 'Weekly structure';
  String workoutStructureSummary(int exercises, int minutes) => isChinese
      ? '$exercises 个动作 · $minutes 分钟'
      : '$exercises exercises · $minutes min';
  String get noPlansForFilter =>
      isChinese ? '这个分类里还没有计划。' : 'No plans in this category yet.';
  String progressionStages(int count) =>
      isChinese ? '$count 个编排阶段' : '$count authored stages';
  String progressionIntensityRange(double lower, double upper) => isChinese
      ? '工作组强度 ${lower.toStringAsFixed(0)}%–${upper.toStringAsFixed(0)}%'
      : 'Working intensity ${lower.toStringAsFixed(0)}%–${upper.toStringAsFixed(0)}%';
  String get progressionSummary => isChinese
      ? '训练时会按计划原始阶段与规则显示准确组数、次数和重量。'
      : 'Sessions use the plan-authored stages and rules for exact sets, reps, and loads.';
  String get setTrainingMaxes => isChinese ? '设置训练最大值' : 'Set Training Maxes';
  String get trainingMaxSetupDescription => isChinese
      ? '请输入主项训练最大值；缺失的辅助动作重量会在下一步提供可编辑的保守建议。'
      : 'Enter the main-lift training maxes. Missing accessory loads can be reviewed and edited in the next step.';
  String get startPlan => isChinese ? '开始计划' : 'Start Plan';
  String get reviewStartingLoads =>
      isChinese ? '确认起始重量' : 'Review starting loads';
  String get reviewStartingLoadsDescription => isChinese
      ? '计划或训练最大值已经指定的重量不会改变。以下仅为缺失负重的保守建议，请在开始前确认或编辑。'
      : 'Plan-authored and training-max loads stay unchanged. These are conservative suggestions only for missing loads; confirm or edit them before starting.';
  String get confirmAndStart => isChinese ? '确认并开始' : 'Confirm & start';
  String get confirmedLoad => isChinese ? '确认重量' : 'Confirmed load';
  String get enterManually => isChinese ? '手动输入' : 'Enter manually';
  String get enterValidLoad => isChinese ? '请输入有效重量' : 'Enter a valid load';
  String startingLoadSourceLabel(
    StartingLoadSource source, {
    int? observedReps,
    String sourceExerciseName = '',
  }) {
    return switch (source) {
      StartingLoadSource.sameExerciseObservedRm =>
        isChinese
            ? '来源：同动作 ${observedReps ?? '—'}RM 记录'
            : 'Source: same-exercise ${observedReps ?? '—'}RM record',
      StartingLoadSource.sameExerciseActualOneRepMax =>
        isChinese ? '来源：同动作最重单次' : 'Source: same-exercise best single',
      StartingLoadSource.sameExerciseEstimatedOneRepMax =>
        isChinese ? '来源：同动作预估 1RM' : 'Source: same-exercise estimated 1RM',
      StartingLoadSource.anchorRatio =>
        isChinese
            ? '来源：$sourceExerciseName 记录 × 动作比例'
            : 'Source: $sourceExerciseName profile × exercise ratio',
      StartingLoadSource.existingWeight =>
        isChinese ? '来源：计划已有重量' : 'Source: existing plan load',
      StartingLoadSource.unavailable =>
        isChinese
            ? '没有可靠的自动建议，请手动填写'
            : 'No defensible automatic estimate; enter a load manually',
    };
  }

  String startingLoadWarning(StartingLoadWarningCode warning) {
    return switch (warning) {
      StartingLoadWarningCode.editableSuggestion =>
        isChinese ? '建议可编辑' : 'Editable suggestion',
      StartingLoadWarningCode.lowConfidence =>
        isChinese ? '低置信度，请保守确认' : 'Low confidence; review conservatively',
      StartingLoadWarningCode.formulaBasedConversion =>
        isChinese ? '包含公式换算' : 'Includes formula conversion',
      StartingLoadWarningCode.estimatedOneRepMaxSource =>
        isChinese
            ? '基于预估 1RM，而非单次记录'
            : 'Based on estimated 1RM, not a recorded single',
      StartingLoadWarningCode.catalogRatioPrior =>
        isChinese ? '使用动作库默认比例' : 'Uses the catalog ratio prior',
      StartingLoadWarningCode.ratioRangeIsNotGuarantee =>
        isChinese ? '比例是建议范围，不是保证值' : 'The ratio is guidance, not a guarantee',
      StartingLoadWarningCode.equipmentCalibrationRequired =>
        isChinese ? '需要在同一器械上校准' : 'Requires calibration on the same equipment',
      StartingLoadWarningCode.equipmentSpecificLoad =>
        isChinese ? '器械刻度不可跨设备比较' : 'Machine-stack loads are not portable',
      StartingLoadWarningCode.bodyweightLoadUnsupported =>
        isChinese ? '自重动作不自动换算公斤数' : 'Bodyweight is not converted to kilograms',
      StartingLoadWarningCode.bandResistanceUnsupported =>
        isChinese
            ? '弹力带阻力不自动换算公斤数'
            : 'Band resistance is not converted to kilograms',
      StartingLoadWarningCode.selectionSlotUnsupported =>
        isChinese ? '请先选择具体动作' : 'Choose a specific exercise first',
      StartingLoadWarningCode.customExerciseMetadataMissing =>
        isChinese
            ? '自定义动作缺少器械元数据'
            : 'Custom exercise equipment metadata is unavailable',
      StartingLoadWarningCode.invalidTarget =>
        isChinese ? '目标次数无效' : 'Invalid repetition target',
      StartingLoadWarningCode.targetRepsOutsideFormulaRange =>
        isChinese
            ? '目标次数超出可靠公式范围'
            : 'Target reps exceed the supported formula range',
      StartingLoadWarningCode.noSameExerciseData =>
        isChinese ? '没有同动作历史记录' : 'No same-exercise history',
      StartingLoadWarningCode.noAnchorData =>
        isChinese ? '没有可用的主项锚点记录' : 'No usable main-lift anchor',
      StartingLoadWarningCode.fractionalRirRoundedUp =>
        isChinese ? '小数 RIR 已向上取整' : 'Fractional RIR was rounded up',
      StartingLoadWarningCode.roundedBelowMinimum =>
        isChinese
            ? '建议低于最小加重单位'
            : 'Suggestion fell below the minimum increment',
      StartingLoadWarningCode.catalogVersionMismatch =>
        isChinese ? '动作库版本已变化，请重新确认' : 'Catalog version changed; review again',
    };
  }

  String get cancel => isChinese ? '取消' : 'Cancel';
  String get enterValidMax => isChinese ? '请输入有效重量' : 'Enter a valid max';
  String get todayWorkout => isChinese ? '今日训练' : 'TODAY\'S WORKOUT';
  String get sharePlan => isChinese ? '分享计划' : 'Share plan';
  String get resume => isChinese ? '继续训练' : 'Resume';
  String get start => isChinese ? '开始训练' : 'Start';
  String get nextSession => isChinese ? '下一次训练' : 'Next session';
  String get inProgress => isChinese ? '进行中' : 'In progress';
  String get upNext => isChinese ? '接下来' : 'Up next';
  String get unableToLoadWorkout =>
      isChinese ? '无法载入训练' : 'Unable to load workout';
  String mins(int minutes) => isChinese ? '$minutes 分钟' : '$minutes mins';
  String dayMinutes(String dayLabel, int minutes) =>
      isChinese ? '$dayLabel · $minutes 分钟' : '$dayLabel • $minutes mins';
  String exercisesLabel(int count) =>
      isChinese ? '$count 个动作' : '$count exercises';
  String get rotation => isChinese ? '轮换' : 'Rotation';
  String get leadLift => isChinese ? '主项' : 'Lead Lift';
  String get goodMorning => isChinese ? '早上好，' : 'Good morning,';
  String get goodAfternoon => isChinese ? '下午好，' : 'Good afternoon,';
  String get goodEvening => isChinese ? '晚上好，' : 'Good evening,';
  String get goodNight => isChinese ? '夜深了，' : 'Good night,';
  String get atAGlance => isChinese ? '概览' : 'AT A GLANCE';
  String get activity => isChinese ? '活动' : 'ACTIVITY';
  String get trainingMilestones => isChinese ? '训练里程碑' : 'Training Milestones';
  String get profilePreferences => isChinese ? '个人资料偏好' : 'Profile Preferences';
  String get profilePreferencesSubtitle => isChinese
      ? '自定义首页问候里显示的名字。'
      : 'Customize the name shown in your home greeting.';
  String get displayName => isChinese ? '显示名称' : 'Display Name';
  String get displayNamePlaceholder =>
      isChinese ? '输入你想显示的名字' : 'Enter the name you want to see';
  String get clearDisplayName => isChinese ? '清空名称' : 'Clear Name';
  String get homeDisplayNameHint => isChinese
      ? '这个名字只用于首页问候，不影响账户身份。'
      : 'This name is used only in the home greeting and does not change your account identity.';
  String get athleteFallbackName => isChinese ? '训练者' : 'Athlete';
  String get weekProgress => isChinese ? '本周进度' : 'Week Progress';
  String get cycleProgress => isChinese ? '周期进度' : 'Cycle Progress';
  String get cycle => isChinese ? '周期' : 'Cycle';
  String get bigThreeHistory => isChinese ? '三大项力量记录' : 'BIG THREE HISTORY';
  String e1rmEntries(int count) =>
      isChinese ? '$count 条 e1RM 记录' : '$count e1RM entries';
  String get latest => isChinese ? '最近更新' : 'LATEST';
  String get switchPlanAction => isChinese ? '切换计划' : 'Switch plan';
  String get seeAllPrs => isChinese ? '查看全部 PR' : 'See all PRs';
  String liftEstimatedOneRepMax(String liftLabel) => '$liftLabel e1RM';
  String showLiftEstimatedOneRepMax(String liftLabel) =>
      isChinese ? '显示$liftLabel的预估 1RM' : 'Show $liftLabel estimated 1RM';
  String weekDayProgressLabel(
    int week,
    int totalWeeks,
    int day,
    int totalDays,
  ) => isChinese
      ? '第$week/$totalWeeks周 · 第$day/$totalDays天'
      : 'Week $week/$totalWeeks · Day $day/$totalDays';
  String compactWeekDayLabel(int week, int day) =>
      isChinese ? '第$week周 · 第$day天' : 'Week $week · Day $day';
  String analyticsPlanWeekLabel(int week) =>
      isChinese ? '第$week周' : 'Week $week';
  String get viewPrDashboard => isChinese ? '查看 PR 仪表盘' : 'Open PR Dashboard';
  String get noMilestoneNotifications =>
      isChinese ? '暂时没有新的训练里程碑。' : 'No new training milestones right now.';
  String get noStrengthTrendYet =>
      isChinese ? '还没有足够的力量趋势数据' : 'Not enough strength trend data yet';
  String get insights => isChinese ? '洞察' : 'Insights';
  String get insightsSubtitle =>
      isChinese ? '训练分析会显示在这里。' : 'Progress analytics will live here.';
  String get progressAnalytics => isChinese ? '进步分析' : 'Progress Analytics';
  String get progressAnalyticsSubtitle => isChinese
      ? '按动作查看预估 1RM、最重单次、PR 与停滞情况。'
      : 'Track estimated 1RM, best singles, PRs, and stagnation by exercise.';
  String get strengthTrajectory => isChinese ? '力量轨迹' : 'Strength Trajectory';
  String get strengthTrajectorySubtitle => isChinese
      ? '先给出总体节奏，再下钻到单动作的预估 1RM、最重单次、PR 与停滞。减少重复黑块，强化阅读节奏。'
      : 'Start with overall momentum, then drill into per-lift estimated 1RM, best singles, PRs, and stagnation.';
  String get analyticsEmptyTitle =>
      isChinese ? '还没有足够的训练记录' : 'Not enough training history yet';
  String get analyticsEmptySubtitle => isChinese
      ? '完成几次训练后，这里会显示动作 1RM、PR 和训练趋势。'
      : 'Finish a few workouts and this screen will show exercise 1RM, PRs, and trends.';
  String get progressAnalyticsLoadFailure => isChinese
      ? '暂时无法加载进步分析，请稍后重试。'
      : 'Unable to load progress analytics right now. Please try again.';
  String get formula => isChinese ? '公式' : 'Formula';
  String oneRepMaxFormulaName(OneRepMaxFormula formula) => switch (formula) {
    OneRepMaxFormula.epley => 'Epley',
    OneRepMaxFormula.brzycki => 'Brzycki',
    OneRepMaxFormula.landers => 'Landers',
    OneRepMaxFormula.lombardi => 'Lombardi',
    OneRepMaxFormula.mayhew => 'Mayhew',
    OneRepMaxFormula.oconner => "O'Conner",
    OneRepMaxFormula.wathan => 'Wathan',
  };
  String get estimatedOneRepMax => isChinese ? '预估 1RM' : 'Estimated 1RM';
  String get actualOneRepMax => isChinese ? '最重单次' : 'Best single';
  String get noActualOneRepMax =>
      isChinese ? '暂无单次记录' : 'No single recorded yet';
  String get recentChange => isChinese ? '最近变化' : 'Recent change';
  String get recentVolume => isChinese ? '近30天吨位' : '30-day volume';
  String get trainingDays => isChinese ? '训练天数' : 'Training days';
  String get workoutsCompleted => isChinese ? '完成训练' : 'Workouts done';
  String get highlightLift => isChinese ? '进步最快动作' : 'Top improving lift';
  String get allExercises => isChinese ? '全部动作' : 'All exercises';
  String get exerciseDetails => isChinese ? '动作详情' : 'Exercise details';
  String get progressBackLabel => isChinese ? '进度' : 'Progress';
  String get estimatedOneRepMaxAbbreviation => 'E1RM';
  String estimatedOneRepMaxUnitLabel(String unit) =>
      isChinese ? '$unit · 预估 1RM' : '$unit · estimated 1RM';
  String repMaxLabel(int reps) => '${reps}RM';
  String get bestEstimatedOneRepMax =>
      isChinese ? '历史最高预估 1RM' : 'Best estimated 1RM';
  String get bestActualOneRepMax => isChinese ? '历史最重单次' : 'Heaviest single';
  String get bestSet => isChinese ? '最佳组' : 'Best set';
  String get personalRecords => isChinese ? 'PR 记录' : 'Personal records';
  String get stagnating => isChinese ? '停滞中' : 'Stagnating';
  String get activeFormula => isChinese ? '当前公式' : 'Active formula';
  String activeFormulaLabel(OneRepMaxFormula formula) => isChinese
      ? '$activeFormula：${oneRepMaxFormulaName(formula)}'
      : '$activeFormula: ${oneRepMaxFormulaName(formula)}';
  String get encounterCount => isChinese ? '记录次数' : 'Sessions logged';
  String get lastSeen => isChinese ? '最近训练' : 'Last trained';
  String get estimatedTrend => isChinese ? '预估 1RM 趋势' : 'Estimated 1RM trend';
  String get actualTrend => isChinese ? '最重单次记录' : 'Best-single history';
  String noRecentChangeLabel() => isChinese ? '暂无变化样本' : 'No recent delta';
  String kilograms(double value) => isChinese
      ? '${value.toStringAsFixed(1)} 公斤'
      : '${value.toStringAsFixed(1)} kg';
  String get kilogramSymbol => 'kg';
  String get kilogramUnit => isChinese ? '公斤' : 'kg';
  String get poundSymbol => 'lb';
  String get poundUnit => isChinese ? '磅' : 'lb';
  String get centimeterUnit => isChinese ? '厘米' : 'cm';
  String get percentUnit => '%';
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
  String get progressConsistencyDescription => isChinese
      ? '把训练频率、总量与主要动作变化放到一张更长周期的视图里。'
      : 'View consistency, workload, and lift momentum in one long-range surface.';
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
  String get calendarToday => isChinese ? '回到本月' : 'Today';
  String get previousMonth => isChinese ? '上个月' : 'Previous month';
  String get nextMonth => isChinese ? '下个月' : 'Next month';
  List<String> get calendarWeekdayInitials => isChinese
      ? const ['一', '二', '三', '四', '五', '六', '日']
      : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  String calendarDaySemantics(DateTime date, int sessionCount) {
    final dateLabel = recordedDayTitle(date);
    return sessionCount == 0
        ? (isChinese ? '$dateLabel，无训练记录' : '$dateLabel, no workout')
        : (isChinese
              ? '$dateLabel，${consistencySessions(sessionCount)}'
              : '$dateLabel, ${consistencySessions(sessionCount)}');
  }

  String get muscleTrainingLoad =>
      isChinese ? '肌群已完成组贡献' : 'Completed-Set Muscle Load';
  String muscleLoadChartEntry(String muscle, double weightedSets) {
    final value = weightedSets.toStringAsFixed(
      weightedSets == weightedSets.roundToDouble() ? 0 : 1,
    );
    return isChinese
        ? '$muscle：$value 折算组'
        : '$muscle: $value weighted-set contribution';
  }

  String muscleLoadChartSemantics(List<String> entries) => isChinese
      ? '$muscleTrainingLoad：${entries.join('；')}'
      : '$muscleTrainingLoad: ${entries.join('; ')}';
  String get anatomicalLoadMap => isChinese ? '解剖负荷图' : 'ANATOMICAL LOAD MAP';
  String get anatomyFront => isChinese ? '正面' : 'Front';
  String get anatomyBack => isChinese ? '背面' : 'Back';
  String get anatomyRelativeIntensity =>
      isChinese ? '相对贡献强度' : 'Relative contribution';
  String get anatomyLowIntensity => isChinese ? '低' : 'Low';
  String get anatomyHighIntensity => isChinese ? '高' : 'High';
  String get anatomyLegendSemantics => isChinese
      ? '$anatomyRelativeIntensity：$anatomyLowIntensity至$anatomyHighIntensity'
      : '$anatomyRelativeIntensity: $anatomyLowIntensity to $anatomyHighIntensity';
  String get anatomyTapHint => isChinese
      ? '点击一个肌群，查看已完成组的贡献明细。'
      : 'Tap a muscle region to inspect its completed-set contribution.';
  String get anatomyNoData => isChinese
      ? '这个时间范围内还没有可映射到肌群的已完成训练组。'
      : 'No completed sets in this period could be mapped to the anatomy view.';
  String anatomyCompletedSets(int count) => isChinese
      ? '$count 个已完成组'
      : '$count completed set${count == 1 ? '' : 's'}';
  String muscleContribution(double weightedSets, int completedSets) {
    final weighted = weightedSets.toStringAsFixed(
      weightedSets == weightedSets.roundToDouble() ? 0 : 1,
    );
    return isChinese
        ? '折算贡献 $weighted 组 · 来自 $completedSets 个已完成组'
        : '$weighted weighted-set contribution · '
              '$completedSets completed set${completedSets == 1 ? '' : 's'}';
  }

  String get muscleNoContribution =>
      isChinese ? '当前时间范围内无贡献' : 'No contribution in this period';
  String anatomyRegionDetailSemantics(String muscle, String contribution) =>
      isChinese ? '$muscle，$contribution' : '$muscle, $contribution';

  String muscleName(ExerciseMuscle muscle) {
    return switch (muscle) {
      ExerciseMuscle.chest => isChinese ? '胸部' : 'Chest',
      ExerciseMuscle.anteriorDeltoids => isChinese ? '三角肌前束' : 'Front deltoids',
      ExerciseMuscle.lateralDeltoids => isChinese ? '三角肌中束' : 'Side deltoids',
      ExerciseMuscle.rearDeltoids => isChinese ? '三角肌后束' : 'Rear deltoids',
      ExerciseMuscle.triceps => isChinese ? '肱三头肌' : 'Triceps',
      ExerciseMuscle.biceps => isChinese ? '肱二头肌' : 'Biceps',
      ExerciseMuscle.forearms => isChinese ? '前臂' : 'Forearms',
      ExerciseMuscle.lats => isChinese ? '背阔肌' : 'Lats',
      ExerciseMuscle.upperBack => isChinese ? '上背' : 'Upper back',
      ExerciseMuscle.lowerBack => isChinese ? '下背' : 'Lower back',
      ExerciseMuscle.core => isChinese ? '核心' : 'Core',
      ExerciseMuscle.glutes => isChinese ? '臀肌' : 'Glutes',
      ExerciseMuscle.quadriceps => isChinese ? '股四头肌' : 'Quadriceps',
      ExerciseMuscle.hamstrings => isChinese ? '腿后侧' : 'Hamstrings',
      ExerciseMuscle.calves => isChinese ? '小腿' : 'Calves',
      ExerciseMuscle.adductors => isChinese ? '内收肌' : 'Adductors',
    };
  }

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
  String get noExerciseHistory => isChinese
      ? '还没有这个动作的训练记录。'
      : 'No training history for this exercise yet.';
  String setLoadAndReps(double weight, int reps) => isChinese
      ? '${weight.toStringAsFixed(1)} 公斤 × $reps 次'
      : '${weight.toStringAsFixed(1)} kg × $reps reps';
  String localizedPersonalRecord(String record) {
    final match = RegExp(
      r'^(\d+(?:\.\d+)?)\s*[x×]\s*(\d+)$',
    ).firstMatch(record.trim());
    final weight = double.tryParse(match?.group(1) ?? '');
    final reps = int.tryParse(match?.group(2) ?? '');
    return weight == null || reps == null
        ? record
        : setLoadAndReps(weight, reps);
  }

  String e1rmLabel(double value) => isChinese
      ? '预估 1RM：${value.toStringAsFixed(1)} 公斤'
      : 'E1RM: ${value.toStringAsFixed(1)} kg';
  String get change30d => isChinese ? '30天变化' : '30D CHANGE';
  String get gaining => isChinese ? '提升中' : 'Gaining';
  String get totalLogged => isChinese ? '累计记录' : 'Total logged';
  String get strengthTrendsOverlay =>
      isChinese ? '力量趋势叠加' : 'Strength Trends Overlay';
  String get performance => isChinese ? '表现' : 'Performance';
  String get prDashboard => isChinese ? 'PR 仪表盘' : 'PR Dashboard';
  String get prDashboardSubtitle => isChinese
      ? '精确追踪你的巅峰力量指标。'
      : 'Precision tracking of your peak strength benchmarks.';
  String get estimated1rmShort => isChinese ? '预估 1RM' : 'Estimated 1RM';
  String get actualPrShort => isChinese ? '实际 PR' : 'Actual PR';
  String get squatShort => isChinese ? '深蹲' : 'Squat';
  String get benchShort => isChinese ? '卧推' : 'Bench';
  String get deadliftShort => isChinese ? '硬拉' : 'Deadlift';
  String get strengthProgressionTitle =>
      isChinese ? '力量进步曲线' : 'Strength Progression';
  String get recentMilestones => isChinese ? '最近里程碑' : 'Recent Milestones';
  String get viewAllMilestones => isChinese ? '查看全部' : 'View All';
  String get milestoneHistory => isChinese ? '全部里程碑' : 'Milestone History';
  String get milestoneType => isChinese ? '类型' : 'Type';
  String get allTypes => isChinese ? '全部类型' : 'All Types';
  String get estimatedType => isChinese ? '预估 1RM' : 'Estimated 1RM';
  String get actualType => isChinese ? '实际 PR' : 'Actual PR';
  String get timeRange => isChinese ? '时间范围' : 'Time Range';
  String get allTime => isChinese ? '全部时间' : 'All Time';
  String get last30Days => isChinese ? '最近30天' : 'Last 30 Days';
  String get last90Days => isChinese ? '最近90天' : 'Last 90 Days';
  String get last365Days => isChinese ? '最近一年' : 'Last 365 Days';
  String get liftFilter => isChinese ? '动作' : 'Lift';
  String get chartLift => isChinese ? '曲线动作' : 'Lift';
  String get detailsCta => isChinese ? '详情 >' : 'DETAILS >';
  String get noMilestonesYet => isChinese ? '还没有里程碑记录。' : 'No milestones yet.';
  String get noFilteredMilestones =>
      isChinese ? '当前筛选条件下没有结果。' : 'No milestones match these filters.';
  String get milestoneExercises => isChinese ? '里程碑动作' : 'Milestone Exercises';
  String get milestoneExercisesSubtitle => isChinese
      ? '选择哪些动作生成 PR 里程碑；默认是深蹲、卧推和硬拉。'
      : 'Choose which exercises create PR milestones; the Big Three are selected by default.';
  String get searchExercises => isChinese ? '搜索动作' : 'Search exercises';
  String get clearSearch => isChinese ? '清除搜索' : 'Clear search';
  String get resetBigThree => isChinese ? '恢复大三项' : 'Reset Big Three';
  String get noExerciseMatches =>
      isChinese ? '没有匹配的动作。' : 'No matching exercises.';
  String selectedExerciseCount(int count) =>
      isChinese ? '已选择 $count 个动作' : '$count selected';
  String milestoneValueLabel(String label, double value) => isChinese
      ? '$label：${value.toStringAsFixed(1)} 公斤'
      : '$label: ${value.toStringAsFixed(1)} kg';
  String chartAxisWeight(String value) => isChinese ? '$value 公斤' : '$value kg';
  String get profile => isChinese ? '我的' : 'Profile';
  String get settings => isChinese ? '设置' : 'Settings';
  String get profileSettingsSubtitle => isChinese
      ? '账号、语言、重量工具与界面偏好。'
      : 'Account, language, weight tools, and interface preferences.';
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
  String get manageAccountShort => isChinese ? '管理账户' : 'Manage';
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
      isChinese ? '后端尚未配置' : 'Backend Not Configured';
  String get supabaseUnavailableHint => isChinese
      ? '请先通过 dart-define 提供 BACKEND_URL；未提供时，应用只会在本地后端开发服务实际可达时自动回退。'
      : 'Provide BACKEND_URL via dart-define first; without it, the app only falls back when the local backend dev server is actually reachable.';
  String get workingState => isChinese ? '处理中...' : 'Working...';
  String get language => isChinese ? '语言' : 'Language';
  String get languageSubtitle =>
      isChinese ? '切换应用界面和内置计划语言' : 'Switch app and built-in plan language';
  String get chinese => '中文';
  String get english => 'English';
  String get englishLanguageSubtitle =>
      isChinese ? '英语界面' : 'English interface';
  String get chineseLanguageSubtitle =>
      isChinese ? '中文界面' : 'Chinese interface';
  String get appearanceSection => isChinese ? '外观' : 'APPEARANCE';
  String get appearanceDescription => isChinese
      ? '一套完整主题会同时更新背景、卡片、文字、线条、图表和操作反馈。'
      : 'One complete theme updates backgrounds, cards, text, lines, charts, and interaction feedback together.';
  String get appearanceCompareHint => isChinese
      ? '横向滑动比较全部 5 套配色。'
      : 'Swipe horizontally to compare all five palettes.';
  String get obsidianBrassPalette => isChinese ? '黑曜黄铜' : 'Obsidian Brass';
  String get obsidianBrassPaletteDescription => isChinese
      ? '深邃黑色、温润黄铜，以克制的紫色平衡。'
      : 'Refined black, warm brass, and a restrained violet counterpoint.';
  String get midnightCobaltPalette => isChinese ? '午夜钴蓝' : 'Midnight Cobalt';
  String get midnightCobaltPaletteDescription => isChinese
      ? '精密深蓝、清冽钴光，搭配柔和的紫色数据重点。'
      : 'Precision navy, clear cobalt light, and a soft violet data accent.';
  String get bordeauxVelvetPalette => isChinese ? '波尔多丝绒' : 'Bordeaux Velvet';
  String get bordeauxVelvetPaletteDescription => isChinese
      ? '深酒红、粉雾玫瑰与安静的香槟金。'
      : 'Deep oxblood, powdered rose, and quiet champagne.';
  String get porcelainInkPalette => isChinese ? '瓷白墨韵' : 'Porcelain Ink';
  String get porcelainInkPaletteDescription => isChinese
      ? '温暖瓷白、果断墨色，以朱砂红留下印记。'
      : 'Warm porcelain, decisive ink, and a vermilion signature.';
  String get espressoEmberPalette => isChinese ? '浓缩余烬' : 'Espresso Ember';
  String get espressoEmberPaletteDescription => isChinese
      ? '烘焙咖啡、余烬橙色，搭配低饱和薰衣草紫。'
      : 'Roasted espresso, ember orange, and muted lavender.';
  String paletteName(FittinPaletteId paletteId) => switch (paletteId) {
    FittinPaletteId.obsidianBrass => obsidianBrassPalette,
    FittinPaletteId.midnightCobalt => midnightCobaltPalette,
    FittinPaletteId.bordeauxVelvet => bordeauxVelvetPalette,
    FittinPaletteId.porcelainInk => porcelainInkPalette,
    FittinPaletteId.espressoEmber => espressoEmberPalette,
  };
  String paletteDescription(FittinPaletteId paletteId) => switch (paletteId) {
    FittinPaletteId.obsidianBrass => obsidianBrassPaletteDescription,
    FittinPaletteId.midnightCobalt => midnightCobaltPaletteDescription,
    FittinPaletteId.bordeauxVelvet => bordeauxVelvetPaletteDescription,
    FittinPaletteId.porcelainInk => porcelainInkPaletteDescription,
    FittinPaletteId.espressoEmber => espressoEmberPaletteDescription,
  };
  String palettePreviewSemantics(String paletteName, {required bool selected}) {
    if (isChinese) {
      return selected ? '$paletteName 主题预览，已选择' : '$paletteName 主题预览，双击应用';
    }
    return selected
        ? '$paletteName theme preview, selected'
        : '$paletteName theme preview, double tap to apply';
  }

  String selectedPaletteLabel(String paletteName) =>
      isChinese ? '当前外观：$paletteName' : 'Current appearance: $paletteName';
  String get workoutLoggingSection => isChinese ? '训练记录方式' : 'WORKOUT LOGGING';
  String get cardLogger => isChinese ? '卡片记录' : 'Card logger';
  String get cardLoggerSubtitle => isChinese
      ? '左滑下一组、右滑上一组，上滑记录、下滑跳过。'
      : 'Swipe left for next, right for previous, up to log, and down to skip.';
  String get traditionalLogger => isChinese ? '传统记录' : 'Traditional logger';
  String get traditionalLoggerSubtitle => isChinese
      ? '保留按钮式录入与居中的完成操作。'
      : 'Keep button-based entry with a centered finish action.';
  String get weightToolsSection => isChinese ? '重量工具' : 'WEIGHT TOOLS';
  String get referenceSection => isChinese ? '参考' : 'REFERENCE';
  String get visualSettingsSection => isChinese ? '视觉设置' : 'VISUAL SETTINGS';
  String get glassmorphismOpacity =>
      isChinese ? '磨砂玻璃透明度' : 'Glassmorphism Opacity';
  String get glassmorphismOpacitySubtitle => isChinese
      ? '调节全局界面卡片的透明强度。'
      : 'Adjust the global transparency intensity for interface cards.';
  String get aboutSection => isChinese ? '关于' : 'ABOUT';
  String get aboutFittin => isChinese ? '关于 Fittin' : 'About Fittin';
  String get aboutFittinSubtitle => isChinese
      ? '查看版本信息并检查应用更新。'
      : 'View version information and check for app updates.';
  String get aboutPageTitle => isChinese ? '关于' : 'About';
  String get aboutPageSubtitle => isChinese
      ? '版本信息、发布来源与应用更新。'
      : 'Version details, release source, and app updates.';
  String get aboutTagline => isChinese ? '专注每一次训练。' : 'Make every set count.';
  String get aboutCurrentVersion => isChinese ? '当前版本' : 'Current version';
  String get aboutBuildNumber => isChinese ? '构建号' : 'Build number';
  String get aboutPlatform => isChinese ? '平台' : 'Platform';
  String get aboutVersionUnavailable =>
      isChinese ? '暂时无法读取版本信息。' : 'Version details are unavailable.';
  String get aboutAppUpdateSection => isChinese ? '应用更新' : 'APP UPDATE';
  String get aboutDownloadAndroidUpdate =>
      isChinese ? '下载安卓更新' : 'Download Android update';
  String get aboutViewNewRelease => isChinese ? '查看新版本' : 'View new release';
  String get aboutViewReleaseNotes =>
      isChinese ? '查看发布说明' : 'View release notes';
  String get aboutOpenOfficialDownloads =>
      isChinese ? '打开官方下载页' : 'Open official downloads';
  String get aboutUpdateMethod => isChinese ? '更新方式' : 'How updates work';
  String get aboutUpdateMethodDescription => isChinese
      ? '版本信息来自 Fittin 的 GitHub Release。安卓会在浏览器下载 APK，并由系统要求你确认安装。\n\n从 1.0.6 起，安卓版本使用固定正式签名。若设备仍安装 1.0.5 或更早版本，请先同步或备份数据，卸载旧版后再安装一次 1.0.6。'
      : 'Release details come from Fittin on GitHub. Android downloads the APK in your browser and asks you to confirm installation.\n\nFrom 1.0.6 onward, Android releases share one stable signer. If 1.0.5 or earlier is installed, sync or back up first, uninstall it, then install 1.0.6 once.';
  String get aboutCheckingButton => isChinese ? '正在检查…' : 'Checking…';
  String get aboutCheckAgain => isChinese ? '再次检查' : 'Check again';
  String get aboutTryAgain => isChinese ? '重试' : 'Try again';
  String get aboutCheckForUpdates => isChinese ? '检查更新' : 'Check for updates';
  String get aboutCheckingForUpdates =>
      isChinese ? '正在检查更新' : 'Checking for updates';
  String get aboutConnectingReleaseService =>
      isChinese ? '正在连接发布服务器…' : 'Connecting to the release service…';
  String get aboutUpToDate => isChinese ? '已是最新版本' : 'You are up to date';
  String get aboutNoNewerRelease =>
      isChinese ? '当前没有可用的新版本。' : 'No newer release is available.';
  String aboutVersionAvailable(String? version) =>
      isChinese ? '发现新版本 $version' : 'Version $version is available';
  String get aboutOfficialDownloadReady =>
      isChinese ? '可立即打开官方下载地址。' : 'The official download is ready to open.';
  String get aboutUpdateCheckFailed =>
      isChinese ? '检查失败' : 'Update check failed';
  String get aboutUpdateCheckFailedDetail => isChinese
      ? '请检查网络后重试，也可直接打开官方下载页。'
      : 'Try again, or open the official downloads page directly.';
  String get aboutGetLatestRelease =>
      isChinese ? '获取最新版本' : 'Get the latest release';
  String get aboutCheckNewAndroidPackage =>
      isChinese ? '手动检查是否有新的安卓安装包。' : 'Check for a newer Android package.';
  String get trainingSetGuide => isChinese ? '训练组类型指南' : 'Training Set Guide';
  String get trainingSetGuideSubtitle => isChinese
      ? '查看 AMRAP、Top Set、Backoff Set 等组类型说明'
      : 'Review AMRAP, top set, backoff set, and other set types';
  String get openGuide => isChinese ? '查看指南' : 'Open Guide';
  String get templateEditor => isChinese ? '计划编辑' : 'Template Editor';
  String get planEditorPeriodizedDescription =>
      isChinese ? '按周/天槽位编辑周期计划。' : 'Edit periodized plans by week/day slot.';
  String get planEditorLinearDescription => isChinese
      ? '线性计划按可复用训练日整体编辑。'
      : 'Linear plans are edited as reusable workout structures.';
  String get builtInTemplateCopyNotice => isChinese
      ? '内置模板会另存为新的自定义副本。'
      : 'Built-in templates save as a new custom copy.';
  String get activeTemplateCopyNotice => isChinese
      ? '已有进行中实例的模板会另存为新副本，避免覆盖现有进度。'
      : 'Templates with active instances save as a new copy to protect existing progress.';
  String get customTemplateEditNotice => isChinese
      ? '你正在直接编辑自定义模板。'
      : 'You are editing a custom template in place.';
  String get templateSection => isChinese ? '模板' : 'Template';
  String get description => isChinese ? '描述' : 'Description';
  String get scheduleMode => isChinese ? '计划模式' : 'Schedule Mode';
  String get linearPlan => isChinese ? '线性计划' : 'Linear Plan';
  String get periodizedPlan => isChinese ? '周期计划' : 'Periodized Plan';
  String get linearPlanModeDescription =>
      isChinese ? '整套训练日复用' : 'Reusable workout structure';
  String get periodizedPlanModeDescription =>
      isChinese ? '按周/天槽位编辑' : 'Edit by week/day slots';
  String get weekDaySlot => isChinese ? '周/天槽位' : 'Week/Day Slot';
  String daySlotLabel(int day) => isChinese ? '第$day天' : 'D$day';
  String weekSlotLabel(int week) => isChinese ? '第$week周' : 'W$week';
  String periodizedEditorSlotLabel(int week, int day) =>
      isChinese ? '第$week周 · 第$day天' : 'W${week}D$day';
  String get setType => isChinese ? '组类型' : 'Set Type';
  String get loadUnit => isChinese ? '单位' : 'Load Unit';
  String get templateName => isChinese ? '计划名称' : 'Template Name';
  String get workoutName => isChinese ? '训练日名称' : 'Workout Name';
  String get dayLabel => isChinese ? '日标签' : 'Day Label';
  String get minutes => isChinese ? '分钟' : 'Minutes';
  String get exerciseName => isChinese ? '动作名称' : 'Exercise Name';
  String get movementId => isChinese ? '动作 ID' : 'Movement Id';
  String get tier => isChinese ? '层级' : 'Tier';
  String get restSeconds => isChinese ? '休息（秒）' : 'Rest (sec)';
  String get startWeight => isChinese ? '起始重量' : 'Start Weight';
  String get bodyweightLoad => isChinese ? '自身体重' : 'Bodyweight';
  String get equipmentType => isChinese ? '器械类型' : 'Equipment';
  String get equipmentGeneral => isChinese ? '通用' : 'General';
  String get equipmentBarbell => isChinese ? '杠铃' : 'Barbell';
  String get equipmentDumbbell => isChinese ? '哑铃' : 'Dumbbell';
  String get equipmentMachine => isChinese ? '器械' : 'Machine';
  String get equipmentCable => isChinese ? '绳索' : 'Cable';
  String get equipmentBodyweight => isChinese ? '自重' : 'Bodyweight';
  String get trainingMaxMapping => isChinese ? '训练最大值映射' : 'TM Mapping';
  String get noneOrLater => isChinese ? '无 / 后续补充' : 'None / Later';
  String get overheadPressShort => isChinese ? '站姿杠铃推举' : 'Overhead Press';
  String get planEditorDeferredLoadHint => isChinese
      ? '计划可先快速开始，之后再回来补充动作的训练最大值映射或起始重量。'
      : 'Plans can quick-start now and come back later to finish lift mappings or starting weights.';
  String get stageName => isChinese ? '阶段名称' : 'Stage Name';
  String get sets => isChinese ? '训练组' : 'Sets';
  String get progression => isChinese ? '进展规则' : 'Progression';
  String get onSuccess => isChinese ? '成功后' : 'On Success';
  String get onFailure => isChinese ? '失败后' : 'On Failure';
  String get role => isChinese ? '角色' : 'Role';
  String get reps => isChinese ? '次数' : 'Reps';
  String get intensity => isChinese ? '强度' : 'Intensity';
  String get targetRpe => isChinese ? '目标 RPE' : 'Target RPE';
  String get warmup => isChinese ? '热身组' : 'Warmup';
  String get working => isChinese ? '工作组' : 'Working';
  String get moveUp => isChinese ? '上移' : 'Move up';
  String get moveDown => isChinese ? '下移' : 'Move down';
  String get duplicate => isChinese ? '复制' : 'Duplicate';
  String get ruleAction => isChinese ? '操作' : 'Action';
  String get ruleActionStay => isChinese ? '保持阶段' : 'Stay';
  String get ruleActionAddWeight => isChinese ? '增加重量' : 'Add Weight';
  String get ruleActionMultiply => isChinese ? '按比例调整' : 'Multiply';
  String get ruleActionJumpStage => isChinese ? '跳转阶段' : 'Jump Stage';
  String get amount => isChinese ? '数值' : 'Amount';
  String get multiplier => isChinese ? '倍数' : 'Multiplier';
  String get stage => isChinese ? '阶段' : 'Stage';
  String get validation => isChinese ? '校验问题' : 'Validation';
  String templateEditorInfoMessage(String message) {
    if (!isChinese) return message;
    return switch (message) {
      'Template updated.' => '计划已更新。',
      'Saved as a new template copy.' => '已另存为新的计划副本。',
      _ => '计划已保存。',
    };
  }

  String templateEditorErrorMessage(String message) {
    if (!isChinese) return message;
    final localizedValidation = templateValidationError(message);
    return localizedValidation == message
        ? '保存计划失败，请稍后重试。'
        : localizedValidation;
  }

  String templateValidationError(String error) {
    if (!isChinese) return error;
    switch (error) {
      case 'Template name is required.':
        return '计划名称不能为空。';
      case 'Template schedule mode is invalid.':
        return '计划模式无效。';
      case 'At least one workout is required.':
        return '计划至少需要一个训练日。';
    }

    RegExpMatch? match;
    match = RegExp(r'^Workout "(.+)" must have a name\.$').firstMatch(error);
    if (match != null) return '训练日“${match.group(1)}”必须填写名称。';
    match = RegExp(
      r'^Workout "(.+)" must contain at least one exercise\.$',
    ).firstMatch(error);
    if (match != null) return '训练日“${match.group(1)}”至少需要一个动作。';
    match = RegExp(r'^Exercise "(.+)" must have a name\.$').firstMatch(error);
    if (match != null) return '动作“${match.group(1)}”必须填写名称。';
    match = RegExp(
      r'^Exercise "(.+)" uses an unsupported load unit\.$',
    ).firstMatch(error);
    if (match != null) return '动作“${match.group(1)}”使用了不支持的负重单位。';
    match = RegExp(
      r'^Exercise "(.+)" must contain at least one stage\.$',
    ).firstMatch(error);
    if (match != null) return '动作“${match.group(1)}”至少需要一个阶段。';

    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" must have a name\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”必须填写名称。';
    }
    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" must contain sets\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”至少需要一个训练组。';
    }
    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" must contain at least one working set\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”至少需要一个工作组。';
    }

    final setIssueMatch = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" has a set with invalid (reps|intensity|role|type)\.$',
    ).firstMatch(error);
    if (setIssueMatch != null) {
      final issue = switch (setIssueMatch.group(3)) {
        'reps' => '次数',
        'intensity' => '强度',
        'role' => '角色',
        _ => '类型',
      };
      return '动作“${setIssueMatch.group(2)}”中的阶段“${setIssueMatch.group(1)}”包含$issue无效的训练组。';
    }

    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" has a warmup set with an invalid set type\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”包含类型无效的热身组。';
    }
    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" has a working set marked as warmup\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”有工作组被标记为热身组。';
    }
    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" uses unsupported action "(.+)"\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”使用了不支持的操作“${match.group(3)}”。';
    }
    match = RegExp(
      r'^Stage "(.+)" in exercise "(.+)" jumps to an unknown stage\.$',
    ).firstMatch(error);
    if (match != null) {
      return '动作“${match.group(2)}”中的阶段“${match.group(1)}”跳转到了未知阶段。';
    }
    return error;
  }

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
  String get weightSeries => isChinese ? '体重' : 'Body weight';
  String weightWithUnitLabel(String unit) =>
      isChinese ? '体重（$unit）' : 'Weight ($unit)';
  String get dateAxis => isChinese ? '日期' : 'Date';
  String get weightAxis => isChinese ? '体重' : 'Weight';
  String get loadAxis => isChinese ? '重量' : 'Load';
  String get tapChartPoint =>
      isChinese ? '轻触数据点查看日期、数值与变化' : 'Tap a point for date, value, and change';
  String chartEmptySemantics(String chartLabel, String emptyLabel) =>
      isChinese ? '$chartLabel。$emptyLabel' : '$chartLabel. $emptyLabel';
  String chartSummarySemantics(
    String chartLabel,
    String xAxisLabel,
    String dateRange,
    String yAxisLabel,
    String unit,
    List<String> seriesLabels,
  ) {
    final unitLabel = unit.isEmpty ? '' : ' · $unit';
    return isChinese
        ? '$chartLabel。$xAxisLabel：$dateRange。$yAxisLabel$unitLabel。${seriesLabels.join('、')}'
        : '$chartLabel. $xAxisLabel: $dateRange. '
              '$yAxisLabel$unitLabel. ${seriesLabels.join(', ')}';
  }

  String chartPointLabel(
    String seriesLabel,
    String dateLabel,
    String valueLabel,
    String unit,
    String? detail,
  ) {
    final valueWithUnit = unit.isEmpty ? valueLabel : '$valueLabel $unit';
    final parts = [
      seriesLabel,
      dateLabel,
      valueWithUnit,
      if (detail?.trim().isNotEmpty ?? false) detail!.trim(),
    ];
    return parts.join(isChinese ? '，' : ' · ');
  }

  String get firstWeightEntry => isChinese ? '第一条体重记录' : 'First weight entry';
  String weightPointDelta(double delta, String unit) {
    final prefix = delta > 0 ? '+' : '';
    return isChinese
        ? '较上一条 $prefix${delta.toStringAsFixed(1)} $unit'
        : '$prefix${delta.toStringAsFixed(1)} $unit vs previous';
  }

  String get sinceLastCheckIn => isChinese ? '较上次记录' : 'since last check-in';
  String derivedFromSet(double weight, int reps) => isChinese
      ? '来自 ${weight.toStringAsFixed(1)} 公斤 × $reps 次'
      : 'From ${weight.toStringAsFixed(1)} kg × $reps';
  String loadError(Object _) =>
      isChinese ? '加载失败，请稍后重试。' : 'Unable to load. Please try again.';
  String get unableToSharePlan =>
      isChinese ? '无法打开分享，请稍后重试。' : 'Unable to open sharing. Please try again.';
  String get bodyFat => isChinese ? '体脂' : 'BODY FAT';
  String get waist => isChinese ? '腰围' : 'WAIST';
  String get checkIns => isChinese ? '记录' : 'CHECK-INS';
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
  String get weightKgLabel => isChinese ? '体重（公斤）' : 'Weight (kg)';
  String get bodyFatLabel => isChinese ? '体脂（%）' : 'Body fat (%)';
  String get waistCmLabel => isChinese ? '腰围（厘米）' : 'Waist (cm)';
  String get noteOptional => isChinese ? '备注（可选）' : 'Note (optional)';
  String get deleteMeasurement => isChinese ? '删除测量记录' : 'Delete measurement';
  String get waistSuffix => isChinese ? '腰围' : 'waist';
  String bodyFatHistoryValue(double value) =>
      '${value.toStringAsFixed(1)}$percentUnit';
  String waistHistoryValue(double value) => isChinese
      ? '腰围 ${value.toStringAsFixed(1)} $centimeterUnit'
      : '${value.toStringAsFixed(1)} $centimeterUnit $waistSuffix';
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
  String get loadingActiveWorkout =>
      isChinese ? '正在载入训练……' : 'Loading active workout…';
  String get unableToConcludeWorkout =>
      isChinese ? '无法完成本次训练。' : 'Unable to conclude workout.';
  String get enterWeight => isChinese ? '直接输入重量' : 'Enter Weight';
  String get weightLabel => isChinese ? '重量' : 'Weight';
  String get enterRpe => isChinese ? '输入 RPE' : 'Enter RPE';
  String get rpeLabel => 'RPE';
  String get rpeExample => isChinese ? '例如 7 或 7.5' : 'For example 7 or 7.5';
  String get clearValue => isChinese ? '清空' : 'Clear';
  String get weightTools => isChinese ? '重量工具' : 'Weight tools';
  String get weightToolsTitle => isChinese ? '重量工具' : 'Weight Tools';
  String get weightToolsDescription => isChinese
      ? '快速做千克/磅换算，并查看杠铃上片方案。'
      : 'Convert between kg/lb and preview barbell plate loading.';
  String get weightToolsExerciseDescription => isChinese
      ? '基于当前动作快速换算重量并查看上片。'
      : 'Use the current exercise context to convert load and preview plate loading.';
  String get weightToolsInputLabel => isChinese ? '输入重量' : 'Enter Weight';
  String get convertedValue => isChinese ? '换算结果' : 'Converted Value';
  String get defaultBarWeight => isChinese ? '默认杠重' : 'Default Bar Weight';
  String get plateLoading => isChinese ? '上片方案' : 'Plate Loading';
  String get useForCurrentSet => isChinese ? '用于当前组' : 'Use for Set';
  String get plateLoadingEmpty => isChinese
      ? '无需加片，或当前重量低于默认杠重。'
      : 'No plates needed, or the target load is below the bar weight.';
  String plateLoadingPerSide(String detail) =>
      isChinese ? '每边 $detail' : '$detail each side';
  String plateLoadingRemaining(String detail, String remaining, String unit) =>
      isChinese
      ? '每边 $detail，仍差 $remaining $unit'
      : '$detail each side, remaining $remaining $unit';
  String get weightToolsSettingsDescription => isChinese
      ? '在设置里维护常用换算和默认杠重，训练记录页会直接复用。'
      : 'Maintain your preferred converter defaults and bar weights here for the workout logger.';
  String get kilogramBarWeight => isChinese ? '公斤杠重' : 'kg Bar Weight';
  String get poundBarWeight => isChinese ? '磅杠重' : 'lb Bar Weight';
  String get openConverter => isChinese ? '打开换算器' : 'Open Converter';
  String switchWeightUnit(String currentUnit) => isChinese
      ? '当前单位 $currentUnit，点击切换重量单位'
      : 'Current unit $currentUnit. Switch weight unit';
  String get switchExercise => isChinese ? '切换动作' : 'Switch exercise';
  String setPosition(int current, int total) =>
      isChinese ? '第 $current / $total 组' : 'SET $current / $total';
  String setNumber(int number) => isChinese ? '第 $number 组' : 'SET $number';
  String sessionHeaderSetProgress(String tier, int current, int total) =>
      '$tier · ${setPosition(current, total)}';
  String workoutContextTitle(String workoutName, {int? week, int? day}) {
    final contextParts = isChinese
        ? [if (week != null) '第$week周', if (day != null) '第$day天']
        : [if (week != null) 'W$week', if (day != null) 'D$day'];
    return contextParts.isEmpty
        ? workoutName
        : '${contextParts.join(isChinese ? '·' : '')}-$workoutName';
  }

  String get completedRepsLabel => isChinese ? '完成次数' : 'REPS';
  String get performedRpe => isChinese ? '实际 RPE' : 'PERFORMED RPE';
  String get previousSetAction => isChinese ? '上一组' : 'PREVIOUS';
  String get nextSetAction => isChinese ? '下一组' : 'NEXT';
  String get skipSetAction => isChinese ? '跳过' : 'SKIP';
  String get logSetAction => isChinese ? '记录' : 'LOG';
  String currentSetGestureSemantics(int setNumber) => isChinese
      ? '当前第 $setNumber 组，左滑下一组，右滑上一组，上滑记录，下滑跳过'
      : 'Current set $setNumber. Swipe left for next, right for previous, up to log, or down to skip.';
  String get cardGestureHint =>
      isChinese ? '←/→ 切换  ·  ↑ 记录  ·  ↓ 跳过' : '←/→ SET  ·  ↑ LOG  ·  ↓ SKIP';
  String targetReps(int reps, {required bool isAmrap}) => isChinese
      ? '目标 $reps${isAmrap ? '+' : ''} 次'
      : 'Target $reps${isAmrap ? '+' : ''} reps';
  String get skipCurrentSet => isChinese ? '跳过当前组' : 'Skip current set';
  String get swipeAnyDirection =>
      isChinese ? '四向轻滑，即时响应' : 'SWIPE IN ANY DIRECTION';
  String get prescribed => isChinese ? '计划目标' : 'PRESCRIBED';
  String get logCurrentSet => isChinese ? '记录当前组' : 'Log current set';
  String get decreaseReps => isChinese ? '减少完成次数' : 'Decrease reps';
  String get increaseReps => isChinese ? '增加完成次数' : 'Increase reps';
  String get decreaseWeight => isChinese ? '减少重量' : 'Decrease weight';
  String get increaseWeight => isChinese ? '增加重量' : 'Increase weight';
  String get setStatusCompleted => isChinese ? '已记录' : 'completed';
  String get setStatusSkipped => isChinese ? '已跳过' : 'skipped';
  String get setStatusCurrent => isChinese ? '当前组' : 'current';
  String get setStatusPending => isChinese ? '待记录' : 'pending';
  String setProgressSemantics(
    int setNumber,
    int total, {
    required bool isCompleted,
    required bool isSkipped,
    required bool isCurrent,
  }) {
    final status = isCompleted
        ? setStatusCompleted
        : isSkipped
        ? setStatusSkipped
        : isCurrent
        ? setStatusCurrent
        : setStatusPending;
    return isChinese
        ? '第 $setNumber 组，共 $total 组，$status。点击切换到该组'
        : 'Set $setNumber of $total, $status. Tap to switch to this set';
  }

  String exerciseMenuItemSemantics({
    required String tier,
    required String name,
    required int completed,
    required int total,
    required bool isActive,
  }) => isChinese
      ? '$tier $name，已完成 $completed / $total 组${isActive ? '，当前动作' : ''}'
      : '$tier $name, $completed of $total sets completed${isActive ? ', current exercise' : ''}';
  String perSidePlateLoading(
    String detail,
    String unit, {
    required bool isBarOnly,
  }) => isBarOnly
      ? (isChinese ? '每侧 · 空杆' : 'PER SIDE · BAR ONLY')
      : (isChinese ? '每侧 · $detail $unit' : 'PER SIDE · $detail $unit');
  String barbellPlateSemantics(String perSideText) => isChinese
      ? '$perSideText。奥林匹克杠铃杆、套筒、卡箍和杠片左右对称。'
      : '$perSideText. Mirrored Olympic bar, sleeves, collars, and plates.';
  String get workoutSaved =>
      isChinese ? '训练已保存，已载入下一次训练。' : 'Workout saved. Next day loaded.';
  String get workoutUpdated =>
      isChinese ? '训练记录已更新。' : 'Workout record updated.';
  String get workoutUpdatedNoProgressionRewrite => isChinese
      ? '训练记录已更新，当前下次训练计划保持不变。'
      : 'Workout record updated. Current next-session plan was not changed.';
  String get deleteWorkoutRecordTitle =>
      isChinese ? '删除这条训练记录？' : 'Delete this workout record?';
  String get deleteWorkoutRecordMessage => isChinese
      ? '删除后，这条训练记录及其统计数据将无法恢复。'
      : 'This workout record and its analytics will be permanently removed.';
  String get workoutRecordDeleted =>
      isChinese ? '训练记录已删除。' : 'Workout record deleted.';
  String get saving => isChinese ? '保存中...' : 'Saving...';
  String get concludeWorkout => isChinese ? '完成本次训练' : 'Conclude Workout';
  String get confirmConcludeWorkoutTitle =>
      isChinese ? '确认结束训练？' : 'Confirm workout conclusion?';
  String get confirmConcludeWorkoutMessage => isChinese
      ? '确认后会保存本次训练并推进下一次训练计划。'
      : 'Confirming will save this workout and advance the next workout plan.';
  String get saveChanges => isChinese ? '保存修改' : 'Save Changes';
  String get recordedTime => isChinese ? '记录时间' : 'Recorded Time';
  String get recordedDate => isChinese ? '记录日期' : 'Recorded Date';
  String recordRepsLabel(int setNumber) =>
      isChinese ? '第 $setNumber 组次数' : 'Reps $setNumber';
  String recordWeightLabel(int setNumber, String unit) =>
      isChinese ? '第 $setNumber 组重量（$unit）' : 'Weight $setNumber ($unit)';
  String recordRpeLabel(int setNumber) =>
      isChinese ? '第 $setNumber 组 RPE' : 'RPE $setNumber';
  String recordTargetRpe(String value) =>
      isChinese ? '目标 RPE $value' : 'Target RPE $value';
  String get invalidDateTime =>
      isChinese ? '请输入有效的日期和时间。' : 'Enter a valid date and time.';
  String get noActivePlan => isChinese
      ? '当前没有激活的训练计划，请先去计划库开始。'
      : 'No active training plan instance. Open Plan Library to start one.';

  String greetingForPeriod(String periodKey) {
    return switch (periodKey) {
      'afternoon' => goodAfternoon,
      'evening' => goodEvening,
      'night' => goodNight,
      _ => goodMorning,
    };
  }

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
