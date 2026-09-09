from __future__ import annotations

import json
import re
from pathlib import Path
from zipfile import ZipFile
from xml.etree import ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
WORKBOOK_PATH = ROOT / "assets/raw_table_plans/TSA Intermediate Approach 2.0 - LiftVault.com.xlsx"
OUTPUT_PATH = ROOT / "assets/plans/tsa_intermediate_approach_2_0.json"

NS = {"a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
WEEK_STARTS = ["C", "Q", "AE", "AS", "BG", "BU", "CI", "CW"]
WEEK_TITLES = [
    "Week 1 Intro / Acclimation",
    "Week 2 Progress 1",
    "Week 3 Progress 2",
    "Week 4 Progress 3",
    "Week 5 Deload / Intensity Prep",
    "Week 6 Intensify / Peak 1",
    "Week 7 Intensify / Peak 2",
    "Week 8 Intensify / Peak 3",
]
DAY_DEFS = [
    {
        "id": "day1",
        "name": "Squat Hypertrophy",
        "localized_name": "深蹲增肌日",
        "day_label": "Day 1",
        "localized_day_label": "第1天",
        "estimated_duration_minutes": 85,
        "row_groups": [
            {"rows": [10, 11], "tier": "T1"},
            {"rows": [14], "tier": "T2"},
            {"rows": [18], "tier": "T2"},
            {"rows": [22], "tier": "T3"},
            {"rows": [23], "tier": "T3"},
        ],
    },
    {
        "id": "day2",
        "name": "Deadlift Power",
        "localized_name": "硬拉力量日",
        "day_label": "Day 2",
        "localized_day_label": "第2天",
        "estimated_duration_minutes": 80,
        "row_groups": [
            {"rows": [32, 33], "tier": "T1"},
            {"rows": [36], "tier": "T2"},
            {"rows": [40], "tier": "T2"},
            {"rows": [44], "tier": "T3"},
            {"rows": [45], "tier": "T3"},
        ],
    },
    {
        "id": "day3",
        "name": "Squat Strength",
        "localized_name": "深蹲强化日",
        "day_label": "Day 3",
        "localized_day_label": "第3天",
        "estimated_duration_minutes": 75,
        "row_groups": [
            {"rows": [54], "tier": "T1"},
            {"rows": [58], "tier": "T2"},
            {"rows": [62], "tier": "T3"},
            {"rows": [66], "tier": "T3"},
            {"rows": [67], "tier": "T3"},
        ],
    },
    {
        "id": "day4",
        "name": "Bench Peak",
        "localized_name": "卧推峰值日",
        "day_label": "Day 4",
        "localized_day_label": "第4天",
        "estimated_duration_minutes": 80,
        "row_groups": [
            {"rows": [76, 77], "tier": "T1"},
            {"rows": [78], "tier": "T2"},
            {"rows": [79], "tier": "T2"},
            {"rows": [80], "tier": "T3"},
            {"rows": [84], "tier": "T3"},
        ],
    },
]

TRAINING_MAX_MAP = {
    "Competition Squat": "squat",
    "Squat": "squat",
    "Bench Press": "bench",
    "Deadlift": "deadlift",
    "Paused Deadlift": "deadlift",
}
EXERCISE_ID_MAP = {
    "Competition Squat": "competition_squat",
    "Squat": "squat",
    "Bench Press": "bench_press",
    "Close Grip Bench Press": "close_grip_bench_press",
    "Chest Supported Row": "chest_supported_row",
    "Chest-supported Row": "chest_supported_row",
    "Band Pull-Aparts": "band_pull_aparts",
    "Deadlift": "deadlift",
    "Pendlay Row": "pendlay_row",
    "Weighted Back Extension": "weighted_back_extension",
    "Pull-ups": "pull_ups",
    "SELECT": "select_assistance_press",
    "Leg Press or Hack Squat": "leg_press_or_hack_squat",
    "Athlete Movement of Choice": "athlete_movement_of_choice",
    "Feet-up Bench Press": "feet_up_bench_press",
    "Paused Deadlift": "paused_deadlift",
    "Barbell Row": "barbell_row",
    "Neutral/Underhand Lat Pulldown": "neutral_underhand_lat_pulldown",
}
LOCALIZED_EXERCISE_NAMES = {
    "Competition Squat": "比赛深蹲",
    "Squat": "深蹲",
    "Bench Press": "卧推",
    "Close Grip Bench Press": "窄握卧推",
    "Chest Supported Row": "胸托划船",
    "Chest-supported Row": "胸托划船",
    "Band Pull-Aparts": "弹力带拉伸",
    "Deadlift": "硬拉",
    "Pendlay Row": "潘德雷划船",
    "Weighted Back Extension": "负重背伸",
    "Pull-ups": "引体向上",
    "SELECT": "自选胸部辅助",
    "Leg Press or Hack Squat": "腿举或哈克深蹲",
    "Athlete Movement of Choice": "自选动作",
    "Feet-up Bench Press": "抬脚卧推",
    "Paused Deadlift": "暂停硬拉",
    "Barbell Row": "杠铃划船",
    "Neutral/Underhand Lat Pulldown": "中立握或反握高位下拉",
}


def col_to_num(col: str) -> int:
    value = 0
    for char in col:
        value = value * 26 + ord(char) - 64
    return value


def num_to_col(num: int) -> str:
    out = ""
    while num:
        num, rem = divmod(num - 1, 26)
        out = chr(65 + rem) + out
    return out


def load_sheet_cells(path: Path) -> dict[str, str | None]:
    with ZipFile(path) as archive:
        shared_strings = []
        root = ET.fromstring(archive.read("xl/sharedStrings.xml"))
        for item in root.findall("a:si", NS):
            shared_strings.append(
                "".join(
                    text.text or ""
                    for text in item.iter(
                        "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t"
                    )
                )
            )

        root = ET.fromstring(archive.read("xl/worksheets/sheet3.xml"))
        cells: dict[str, str | None] = {}
        for cell in root.findall(".//a:sheetData//a:c", NS):
            ref = cell.attrib["r"]
            value_node = cell.find("a:v", NS)
            inline_node = cell.find("a:is", NS)
            value = None
            if cell.attrib.get("t") == "s" and value_node is not None:
                value = shared_strings[int(value_node.text)]
            elif cell.attrib.get("t") == "inlineStr" and inline_node is not None:
                value = "".join(
                    text.text or ""
                    for text in inline_node.iter(
                        "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t"
                    )
                )
            elif value_node is not None:
                value = value_node.text
            cells[ref] = value
        return cells


def get_cell(cells: dict[str, str | None], col_num: int, row_num: int) -> str | None:
    return cells.get(f"{num_to_col(col_num)}{row_num}")


def parse_numeric_prefix(value: str) -> int:
    match = re.match(r"(\d+)", value)
    return int(match.group(1)) if match else 1


def parse_reps(value: str) -> int:
    return parse_numeric_prefix(value)


def parse_intensity(
    raw: str | None,
    *,
    has_load: bool,
) -> tuple[float, bool]:
    if raw is None or raw == "":
        return 1.0, False
    if raw.startswith("@"):
        return 0.001, False
    if has_load:
        return float(raw) / 100.0, False
    return 1.0, False


def parse_target_rpe(raw: str | None) -> float | None:
    if raw is None:
        return None
    raw = raw.strip()
    if not raw.startswith("@"):
        return None
    try:
        return float(raw[1:])
    except ValueError:
        return None


def build_sets(rows: list[dict[str, str | None]]) -> list[dict[str, object]]:
    sets: list[dict[str, object]] = []
    for index, row in enumerate(rows):
        row_sets_raw = row.get("sets") or "1"
        row_reps_raw = row.get("reps") or "1"
        load_raw = row.get("load")
        intensity, is_amrap = parse_intensity(
            row.get("intensity"),
            has_load=load_raw not in (None, ""),
        )
        target_rpe = parse_target_rpe(row.get("intensity"))
        set_count = 1 if row_sets_raw.lower() == "x" else parse_numeric_prefix(row_sets_raw)
        target_reps = parse_reps(row_reps_raw)
        set_type = "straight_set"
        if len(rows) > 1 and index == 0:
            set_type = "top_set"
        elif len(rows) > 1 and index > 0:
            set_type = "backoff_set"
        for _ in range(set_count):
            sets.append(
                {
                    "targetReps": target_reps,
                    "intensity": intensity,
                    "targetRpe": target_rpe,
                    "isAmrap": is_amrap,
                    "kind": "working",
                    "setType": set_type,
                }
            )
    return sets


def row_payload(cells: dict[str, str | None], start_col_num: int, row_num: int) -> dict[str, str | None]:
    return {
        "label": get_cell(cells, start_col_num, row_num),
        "date": get_cell(cells, start_col_num + 1, row_num),
        "name": get_cell(cells, start_col_num + 2, row_num),
        "sets": get_cell(cells, start_col_num + 3, row_num),
        "reps": get_cell(cells, start_col_num + 4, row_num),
        "intensity": get_cell(cells, start_col_num + 5, row_num),
        "load": get_cell(cells, start_col_num + 6, row_num),
    }


def build_template() -> dict[str, object]:
    cells = load_sheet_cells(WORKBOOK_PATH)
    workouts = []

    for day in DAY_DEFS:
        exercises = []
        for group_index, group in enumerate(day["row_groups"]):
            first_week_start = col_to_num(WEEK_STARTS[0])
            base_row = row_payload(cells, first_week_start, group["rows"][0])
            exercise_name = base_row["name"]
            if not exercise_name:
                raise ValueError(f"Missing exercise name for {day['id']} rows {group['rows']}")
            stages = []
            for week_index, week_start in enumerate(WEEK_STARTS):
                start_col_num = col_to_num(week_start)
                row_values = [row_payload(cells, start_col_num, row_num) for row_num in group["rows"]]
                usable_rows = [
                    row
                    for row in row_values
                    if row.get("name") not in (None, "", "-")
                    or row.get("load") not in (None, "")
                    or (row.get("intensity") or "").startswith("@")
                ]
                if not usable_rows:
                    usable_rows = [row_values[0]]
                stage_sets = build_sets(usable_rows)
                label_bits = []
                for row in usable_rows:
                    sets = row.get("sets") or "1"
                    reps = row.get("reps") or "1"
                    intensity = row.get("intensity")
                    if intensity:
                        label_bits.append(f"{sets}x{reps} {intensity}")
                    else:
                        label_bits.append(f"{sets}x{reps}")
                stages.append(
                    {
                        "id": f"{day['id']}-exercise-{group_index + 1}-week-{week_index + 1}",
                        "name": f"{WEEK_TITLES[week_index]} {' / '.join(label_bits)}",
                        "basePercent": 1.0,
                        "order": week_index,
                        "engineConfig": {},
                        "sets": stage_sets,
                        "rules": [],
                    }
                )

            exercise_id = EXERCISE_ID_MAP.get(exercise_name) or re.sub(
                r"[^a-z0-9]+",
                "_",
                exercise_name.lower(),
            ).strip("_")
            exercises.append(
                {
                    "id": f"{day['id']}-{exercise_id}",
                    "exerciseId": exercise_id,
                    "name": exercise_name,
                    "localizedName": {"zh": LOCALIZED_EXERCISE_NAMES.get(exercise_name, exercise_name)},
                    "initialBaseWeight": 0.0,
                    "tier": group["tier"],
                    "restSeconds": 210 if group["tier"] == "T1" else 150 if group["tier"] == "T2" else 90,
                    "trainingMaxLift": TRAINING_MAX_MAP.get(exercise_name),
                    "trainingMaxMultiplier": 1.0,
                    "roundingIncrement": 2.5,
                    "loadUnit": "kg",
                    "engineConfig": {},
                    "stages": stages,
                }
            )

        workouts.append(
            {
                "id": day["id"],
                "name": day["name"],
                "localizedName": {"zh": day["localized_name"]},
                "dayLabel": day["day_label"],
                "localizedDayLabel": {"zh": day["localized_day_label"]},
                "estimatedDurationMinutes": day["estimated_duration_minutes"],
                "exercises": exercises,
            }
        )

    return {
        "id": "tsa-intermediate-approach-2-0",
        "name": "TSA Intermediate Approach 2.0",
        "description": "An 8-week normalized TSA Intermediate Approach built from the checked-in LiftVault workbook. The app keeps the four-day weekly structure, derives main-lift prescriptions from training maxes, and preserves the workbook accessory lineup for the main training block.",
        "localizedName": {"zh": "TSA Intermediate Approach 2.0 中级计划"},
        "localizedDescription": {
            "zh": "基于仓库内 LiftVault 工作簿整理出的 8 周 TSA Intermediate Approach 中级计划。应用会保留每周四练结构，用训练最大值推导主项重量，并保留主训练阶段的辅助动作安排。"
        },
        "engineFamily": "periodized_tm",
        "scheduleMode": "periodized",
        "requiredTrainingMaxKeys": ["squat", "bench", "deadlift"],
        "engineConfig": {"cycleLengthWeeks": 8},
        "phases": [
            {
                "id": "main-block",
                "name": "8-Week Main Block",
                "workouts": workouts,
            }
        ],
    }


def main() -> None:
    template = build_template()
    OUTPUT_PATH.write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
