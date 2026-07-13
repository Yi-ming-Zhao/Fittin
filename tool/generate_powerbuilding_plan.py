import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/plans/powerbuilding_4day_12week.json"


WEEK_NAMES = {
    1: "基础容量 1",
    2: "基础容量 2",
    3: "基础容量 3",
    4: "减载",
    5: "基础力量 1",
    6: "基础力量 2",
    7: "基础力量 3",
    8: "减载",
    9: "专项强化 1",
    10: "专项强化 2",
    11: "减量与测试准备",
    12: "测试周",
}


def set_def(reps, intensity=1.0, rpe=8.0, set_type="straight_set"):
    return {
        "targetReps": reps,
        "intensity": round(intensity, 4),
        "targetRpe": float(rpe),
        "isAmrap": False,
        "kind": "working",
        "setType": set_type,
    }


def repeat_set(count, reps, intensity, rpe, set_type="straight_set"):
    return [set_def(reps, intensity, rpe, set_type) for _ in range(count)]


def stage(exercise_id, week, sets, add_weight=None):
    rules = []
    if add_weight is not None:
        rules.append(
            {
                "condition": "on_success",
                "actions": [{"type": "ADD_WEIGHT", "amount": add_weight}],
            }
        )
    return {
        "id": f"{exercise_id}-week-{week}",
        "name": f"第{week}周 · {WEEK_NAMES[week]}",
        "basePercent": 1.0,
        "order": week - 1,
        "engineConfig": {},
        "sets": sets,
        "rules": rules,
    }


def main_lift_stages(exercise_id, lift, test_week):
    if lift in {"squat", "bench"}:
        prescriptions = {
            1: [(1, 6, 0.76, 7, "top_set"), (3, 6, 0.6992, 7, "backoff_set")],
            2: [(1, 6, 0.775, 7.5, "top_set"), (4, 6, 0.713, 7.5, "backoff_set")],
            3: [(1, 5, 0.81, 8, "top_set"), (4, 5, 0.7452, 8, "backoff_set")],
            4: [(2, 5, 0.65, 6, "straight_set")],
            5: [(1, 4, 0.79, 7, "top_set"), (3, 4, 0.7268, 7, "backoff_set")],
            6: [(1, 4, 0.805, 7.5, "top_set"), (4, 4, 0.7406, 7.5, "backoff_set")],
            7: [(1, 3, 0.86, 8, "top_set"), (4, 3, 0.7912, 8, "backoff_set")],
            8: [(2, 4, 0.67, 6, "straight_set")],
            9: [(1, 1, 0.90, 7.5, "top_set"), (3, 3, 0.792, 7.5, "backoff_set")],
            10: [(1, 1, 0.92, 8, "top_set"), (3, 2, 0.828, 8, "backoff_set")],
            11: [(1, 1, 0.87, 7, "top_set"), (2, 2, 0.7134, 6.5, "backoff_set")],
        }
    else:
        prescriptions = {
            1: [(1, 5, 0.79, 7, "top_set"), (2, 5, 0.7268, 7, "backoff_set")],
            2: [(1, 5, 0.805, 7.5, "top_set"), (3, 5, 0.7406, 7.5, "backoff_set")],
            3: [(1, 4, 0.84, 8, "top_set"), (3, 4, 0.7728, 8, "backoff_set")],
            4: [(2, 4, 0.65, 6, "straight_set")],
            5: [(1, 4, 0.79, 7, "top_set"), (3, 4, 0.7268, 7, "backoff_set")],
            6: [(1, 4, 0.805, 7.5, "top_set"), (3, 4, 0.7406, 7.5, "backoff_set")],
            7: [(1, 3, 0.86, 8, "top_set"), (3, 3, 0.7912, 8, "backoff_set")],
            8: [(2, 3, 0.67, 6, "straight_set")],
            9: [(1, 1, 0.90, 7.5, "top_set"), (3, 3, 0.792, 7.5, "backoff_set")],
            10: [(1, 1, 0.92, 8, "top_set"), (3, 2, 0.828, 8, "backoff_set")],
            11: [(1, 1, 0.87, 7, "top_set"), (2, 2, 0.7134, 6.5, "backoff_set")],
        }

    stages = []
    for week in range(1, 12):
        sets = []
        for count, reps, intensity, rpe, set_type in prescriptions[week]:
            sets.extend(repeat_set(count, reps, intensity, rpe, set_type))
        stages.append(stage(exercise_id, week, sets))

    if test_week:
        stages.append(
            stage(
                exercise_id,
                12,
                [
                    set_def(1, 0.90, 8, "top_set"),
                    set_def(1, 0.975, 9, "top_set"),
                    set_def(1, 1.02, 10, "top_set"),
                ],
            )
        )
    else:
        stages.append(stage(exercise_id, 12, repeat_set(2, 3, 0.60, 6)))
    return stages


def accessory_stages(exercise_id, sets, reps, isolated, increment):
    regular_rpe = {1: 9, 2: 9, 3: 9.5, 4: 7, 5: 9, 6: 9, 7: 9.5, 8: 7,
                   9: 9, 10: 9.5, 11: 7, 12: 6} if isolated else {
                       1: 7, 2: 7.5, 3: 8, 4: 6, 5: 7, 6: 7.5, 7: 8, 8: 6,
                       9: 7.5, 10: 8, 11: 6, 12: 6}
    rep_steps = {
        1: reps[0], 2: reps[1], 3: reps[2], 4: reps[0],
        5: reps[0], 6: reps[1], 7: reps[2], 8: reps[0],
        9: reps[1], 10: reps[2], 11: reps[0], 12: reps[0],
    }
    set_steps = {week: sets for week in range(1, 13)}
    for week in (4, 8, 11, 12):
        set_steps[week] = max(1, (sets + 1) // 2)
    add_weeks = {3, 7, 10}
    return [
        stage(
            exercise_id,
            week,
            repeat_set(set_steps[week], rep_steps[week], 1.0, regular_rpe[week]),
            increment if week in add_weeks else None,
        )
        for week in range(1, 13)
    ]


def tm_exercise(eid, exercise_id, name, zh, lift, tier, rest, stages):
    return {
        "id": eid,
        "exerciseId": exercise_id,
        "name": name,
        "localizedName": {"zh": zh},
        "initialBaseWeight": 0.0,
        "tier": tier,
        "restSeconds": rest,
        "trainingMaxLift": lift,
        "trainingMaxMultiplier": 1.0,
        "roundingIncrement": 2.5,
        "loadUnit": "kg",
        "equipmentType": "barbell",
        "engineConfig": {},
        "stages": stages,
    }


def accessory(eid, exercise_id, name, zh, initial, tier, rest, equipment,
              sets, reps, isolated, increment, rounding=2.5, load_unit="kg"):
    return {
        "id": eid,
        "exerciseId": exercise_id,
        "name": name,
        "localizedName": {"zh": zh},
        "initialBaseWeight": float(initial),
        "tier": tier,
        "restSeconds": rest,
        "trainingMaxMultiplier": 1.0,
        "roundingIncrement": float(rounding),
        "loadUnit": load_unit,
        "equipmentType": equipment,
        "engineConfig": {
            "progression": f"达到次数上限且实际RPE不高于目标RPE时，下次加重{increment:g}kg"
        },
        "stages": accessory_stages(eid, sets, reps, isolated, increment),
    }


def workout(wid, name, zh, day_label, minutes, exercises):
    return {
        "id": wid,
        "name": name,
        "localizedName": {"zh": zh},
        "dayLabel": day_label,
        "localizedDayLabel": {"zh": day_label.replace("Day", "训练")},
        "estimatedDurationMinutes": minutes,
        "exercises": exercises,
    }


day1_squat = "day1-high-bar-squat"
day2_bench = "day2-paused-bench"
day3_deadlift = "day3-conventional-deadlift"
day3_pin = "day3-high-bar-pin-squat"
day4_bench = "day4-secondary-bench"

workouts = [
    workout(
        "day1", "Squat Strength", "深蹲力量", "Day 1", 80,
        [
            tm_exercise(day1_squat, "high_bar_squat", "High-Bar Squat", "高杠深蹲",
                        "squat", "T1", 240,
                        main_lift_stages(day1_squat, "squat", True)),
            accessory("day1-romanian-deadlift", "romanian_deadlift", "Romanian Deadlift",
                      "罗马尼亚硬拉", 90, "T2", 150, "barbell", 3, (6, 8, 10),
                      False, 5),
            accessory("day1-cable-lateral-raise", "cable_lateral_raise", "Cable Lateral Raise",
                      "绳索侧平举", 5, "T3", 60, "cable", 4, (12, 15, 20),
                      True, 1, rounding=1, load_unit="cable_stack"),
            accessory("day1-abdominal-training", "abdominal_training", "Abdominal Training",
                      "腹肌训练", 10, "T3", 60, "general", 3, (10, 12, 15),
                      True, 2.5),
        ],
    ),
    workout(
        "day2", "Bench Strength", "卧推力量", "Day 2", 85,
        [
            tm_exercise(day2_bench, "paused_bench_press", "Paused Bench Press", "停顿卧推",
                        "bench", "T1", 210,
                        main_lift_stages(day2_bench, "bench", True)),
            accessory("day2-chest-supported-row", "chest_supported_row", "Chest-Supported Row",
                      "胸托划船", 40, "T2", 120, "machine", 4, (8, 10, 12),
                      False, 2.5),
            accessory("day2-incline-dumbbell-press", "incline_dumbbell_press",
                      "Incline Dumbbell Press", "上斜哑铃卧推", 25, "T2", 120,
                      "dumbbell", 3, (8, 10, 12), False, 2),
            accessory("day2-cable-lateral-raise", "cable_lateral_raise", "Cable Lateral Raise",
                      "绳索侧平举", 5, "T3", 60, "cable", 3, (12, 15, 20),
                      True, 1, rounding=1, load_unit="cable_stack"),
            accessory("day2-cable-pressdown", "cable_pressdown", "Cable Triceps Pressdown",
                      "绳索下压", 20, "T3", 60, "cable", 3, (10, 12, 15),
                      True, 2.5, load_unit="cable_stack"),
        ],
    ),
    workout(
        "day3", "Deadlift Strength", "硬拉力量", "Day 3", 75,
        [
            tm_exercise(day3_deadlift, "conventional_deadlift", "Conventional Deadlift",
                        "传统硬拉", "deadlift", "T1", 240,
                        main_lift_stages(day3_deadlift, "deadlift", True)),
            tm_exercise(day3_pin, "high_bar_pin_squat", "High-Bar Pin Squat",
                        "高杠定点深蹲", "squat", "T2", 150,
                        [stage(day3_pin, w, repeat_set(
                            {1:3,2:3,3:3,4:2,5:3,6:3,7:3,8:2,9:2,10:2,11:1,12:1}[w],
                            {1:5,2:5,3:4,4:4,5:4,6:4,7:3,8:3,9:3,10:2,11:2,12:3}[w],
                            {1:.62,2:.64,3:.66,4:.55,5:.65,6:.67,7:.70,8:.56,9:.58,10:.60,11:.50,12:.45}[w],
                            {1:6.5,2:7,3:7.5,4:6,5:6.5,6:7,7:7.5,8:6,9:6,10:6.5,11:6,12:6}[w]))
                         for w in range(1, 13)]),
            accessory("day3-back-extension", "back_extension_45", "45-Degree Back Extension",
                      "45度山羊挺身", 10, "T2", 90, "general", 3, (8, 10, 12),
                      False, 2.5),
            accessory("day3-abdominal-training", "abdominal_training", "Abdominal Training",
                      "腹肌训练", 10, "T3", 60, "general", 3, (10, 12, 15),
                      True, 2.5),
        ],
    ),
    workout(
        "day4", "Bench Hypertrophy", "卧推增肌", "Day 4", 80,
        [
            tm_exercise(day4_bench, "secondary_bench_press", "Secondary Bench Press",
                        "窄距卧推（第9周起比赛握距停顿卧推）", "bench", "T1", 180,
                        [stage(day4_bench, w, repeat_set(
                            {1:3,2:3,3:3,4:2,5:3,6:3,7:3,8:2,9:3,10:3,11:2,12:2}[w],
                            {1:8,2:8,3:6,4:8,5:6,6:6,7:5,8:6,9:4,10:3,11:3,12:5}[w],
                            {1:.65,2:.67,3:.70,4:.55,5:.70,6:.72,7:.75,8:.57,9:.75,10:.78,11:.60,12:.50}[w],
                            {1:7,2:7.5,3:8,4:6,5:7,6:7.5,7:8,8:6,9:7,10:7.5,11:6,12:6}[w]))
                         for w in range(1, 13)]),
            accessory("day4-weighted-pull-up", "weighted_pull_up", "Weighted Pull-Up",
                      "固定握距负重引体向上", 0, "T2", 150, "bodyweight", 4,
                      (5, 6, 8), False, 2.5),
            accessory("day4-seated-dumbbell-press", "seated_dumbbell_press",
                      "Seated Dumbbell Shoulder Press", "坐姿哑铃肩推", 17.5, "T2", 120,
                      "dumbbell", 3, (8, 10, 12), False, 2),
            accessory("day4-cable-lateral-raise", "cable_lateral_raise", "Cable Lateral Raise",
                      "绳索侧平举", 5, "T3", 60, "cable", 2, (12, 15, 20),
                      True, 1, rounding=1, load_unit="cable_stack"),
            accessory("day4-barbell-curl", "barbell_curl", "Barbell Curl", "杠铃弯举",
                      25, "T3", 75, "barbell", 3, (8, 10, 12), True, 2.5),
        ],
    ),
]

plan = {
    "id": "powerbuilding-4day-12week",
    "name": "12-Week Powerbuilding 4-Day",
    "description": (
        "A four-day, 12-week strength-and-physique plan customized around one primary barbell "
        "objective per session. Run the sessions as Squat, Bench, rest, Deadlift, Bench Hypertrophy; "
        "never train more than two days in a row. Accessory lifts use fixed movements and add load "
        "after the upper rep target is completed without exceeding target RPE. Week 12 tests squat, "
        "bench, and deadlift on separate days with at least 48 hours between tests; Day 4 is optional recovery."
    ),
    "localizedName": {"zh": "12周力量健美四练计划"},
    "localizedDescription": {"zh": (
        "每周四练、以力量与形体各半为目标：深蹲力量→卧推力量→休息→硬拉力量→卧推增肌，"
        "任何情况下不连续训练超过两天。每次仅一个主要杠铃目标，每天4–5个动作；健美动作保持固定，"
        "达到次数上限且实际RPE不超过目标RPE后按规则加重。第4、8周减载，第11周减量；第12周三项"
        "分三次测试且间隔至少48小时，第4练仅为可选恢复。测试第二把若超过RPE9，取消第三把加重。"
    )},
    "engineFamily": "periodized_tm",
    "scheduleMode": "periodized",
    "requiredTrainingMaxKeys": ["squat", "bench", "deadlift"],
    "engineConfig": {
        "cycleLengthWeeks": 12,
        "trainingOrder": "深蹲力量→卧推力量→休息→硬拉力量→卧推增肌",
        "minimumRestBetweenTestDaysHours": 48,
        "allIntensityTargetsUseRpe": True,
    },
    "phases": [{"id": "twelve-week-block", "name": "12周力量健美周期", "workouts": workouts}],
}

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(OUT)
