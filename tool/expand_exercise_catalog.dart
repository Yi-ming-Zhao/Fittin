// Deterministic, source-controlled generation of curated factual catalog data.
// No third-party prose or images are copied. See docs/exercise_library_sources.md.
import 'dart:convert';
import 'dart:io';

const additions = '''
tibialis_raise|Wall Tibialis Raise|靠墙胫骨前肌提脚|ankleDorsiflexion|bodyweight|bodyweight|tibialisAnterior||
front_squat|Front Squat|前蹲|squat|barbell|totalExternal|quadriceps|glutes,core,upperBack|
paused_squat|Paused Back Squat|暂停深蹲|squat|barbell|totalExternal|quadriceps,glutes|core,lowerBack|techniques=paused
tempo_squat|Tempo Back Squat|节奏深蹲|squat|barbell|totalExternal|quadriceps,glutes|core,lowerBack|techniques=tempo
box_squat|Box Squat|箱式深蹲|squat|barbell|totalExternal|glutes,quadriceps|hamstrings,core|techniques=paused
safety_bar_squat|Safety Bar Squat|安全杠深蹲|squat|barbell|totalExternal|quadriceps,glutes|core,upperBack|equipmentVariant=safetyBar
zercher_squat|Zercher Squat|泽奇深蹲|squat|barbell|totalExternal|quadriceps,glutes|core,upperBack|
smith_squat|Smith Machine Squat|史密斯深蹲|squat|machine|machineStack|quadriceps,glutes|adductors|equipmentVariant=smithMachine
hack_squat|Hack Squat Machine|哈克深蹲|kneeDominant|machine|machineStack|quadriceps|glutes|
pendulum_squat|Pendulum Squat|钟摆深蹲|kneeDominant|machine|machineStack|quadriceps|glutes|
belt_squat|Belt Squat|腰带深蹲|squat|machine|machineStack|quadriceps,glutes|adductors|
bulgarian_split_squat|Bulgarian Split Squat|保加利亚分腿蹲|kneeDominant|dumbbell|perDumbbell|quadriceps,glutes|adductors|laterality=unilateral;techniques=elevated
barbell_split_squat|Barbell Split Squat|杠铃分腿蹲|kneeDominant|barbell|totalExternal|quadriceps,glutes|adductors,core|laterality=unilateral
step_up|Dumbbell Step Up|哑铃登阶|kneeDominant|dumbbell|perDumbbell|quadriceps,glutes|hamstrings|laterality=unilateral
lateral_lunge|Lateral Lunge|侧向弓步|kneeDominant|bodyweight|bodyweight|quadriceps,glutes,adductors|core|laterality=unilateral
pistol_squat|Pistol Squat|单腿手枪蹲|squat|bodyweight|bodyweight|quadriceps,glutes|core|laterality=unilateral
sissy_squat|Sissy Squat|西斯深蹲|kneeDominant|bodyweight|bodyweight|quadriceps||
leg_extension|Leg Extension|腿屈伸|kneeDominant|machine|machineStack|quadriceps||position=seated
single_leg_press|Single Leg Press|单腿腿举|kneeDominant|machine|machineStack|quadriceps,glutes|adductors|laterality=unilateral;position=seated
sumo_deadlift|Sumo Deadlift|相扑硬拉|hinge|barbell|totalExternal|glutes,quadriceps,adductors|hamstrings,lowerBack,forearms|
trap_bar_deadlift|Trap Bar Deadlift|六角杠硬拉|hinge|barbell|totalExternal|quadriceps,glutes|hamstrings,lowerBack,forearms|equipmentVariant=trapBar
deficit_deadlift|Deficit Deadlift|站高位硬拉|hinge|barbell|totalExternal|glutes,hamstrings|quadriceps,lowerBack,forearms|techniques=deficit
snatch_grip_deadlift|Snatch Grip Deadlift|抓举握距硬拉|hinge|barbell|totalExternal|glutes,hamstrings|upperBack,lowerBack,forearms|grip=pronated
stiff_leg_deadlift|Stiff Leg Deadlift|直腿硬拉|hinge|barbell|totalExternal|hamstrings,glutes|lowerBack|
single_leg_rdl|Single Leg Dumbbell RDL|单腿哑铃罗马尼亚硬拉|hinge|dumbbell|perDumbbell|hamstrings,glutes|core|laterality=unilateral
good_morning|Barbell Good Morning|杠铃早安式|hinge|barbell|totalExternal|hamstrings,glutes|lowerBack,core|
hip_thrust|Barbell Hip Thrust|杠铃臀推|hipExtension|barbell|totalExternal|glutes|hamstrings|position=supine
glute_bridge|Glute Bridge|臀桥|hipExtension|bodyweight|bodyweight|glutes|hamstrings|position=supine
single_leg_glute_bridge|Single Leg Glute Bridge|单腿臀桥|hipExtension|bodyweight|bodyweight|glutes|hamstrings|position=supine;laterality=unilateral
machine_hip_thrust|Hip Thrust Machine|器械臀推|hipExtension|machine|machineStack|glutes|hamstrings|position=supine
cable_pull_through|Cable Pull Through|绳索胯下拉|hipExtension|cable|cableStack|glutes,hamstrings|lowerBack|
cable_glute_kickback|Cable Glute Kickback|绳索后踢腿|hipExtension|cable|cableStack|glutes|hamstrings|laterality=unilateral
hip_abduction_machine|Hip Abduction Machine|坐姿髋外展|hipExtension|machine|machineStack|glutes||position=seated
hip_adduction_machine|Hip Adduction Machine|坐姿髋内收|kneeDominant|machine|machineStack|adductors||position=seated
seated_leg_curl|Seated Leg Curl|坐姿腿弯举|hinge|machine|machineStack|hamstrings|calves|position=seated
lying_leg_curl|Lying Leg Curl|俯卧腿弯举|hinge|machine|machineStack|hamstrings|calves|position=prone
standing_leg_curl|Standing Single Leg Curl|站姿单腿弯举|hinge|machine|machineStack|hamstrings|calves|laterality=unilateral
nordic_curl|Nordic Hamstring Curl|北欧挺|hinge|bodyweight|bodyweight|hamstrings|glutes|position=kneeling
glute_ham_raise|Glute Ham Raise|臀腿挺身|hinge|bodyweight|bodyweight|hamstrings,glutes|lowerBack|position=prone
reverse_hyperextension|Reverse Hyperextension|反向挺身|hipExtension|machine|machineStack|glutes,hamstrings|lowerBack|position=prone
standing_calf_raise|Standing Calf Raise|站姿提踵|locomotion|machine|machineStack|calves||
seated_calf_raise|Seated Calf Raise|坐姿提踵|locomotion|machine|machineStack|calves||position=seated
single_leg_calf_raise|Single Leg Calf Raise|单腿提踵|locomotion|dumbbell|perDumbbell|calves||laterality=unilateral
leg_press_calf_raise|Leg Press Calf Raise|腿举机提踵|locomotion|machine|machineStack|calves||position=seated
incline_barbell_press|Incline Barbell Bench Press|上斜杠铃卧推|horizontalPress|barbell|totalExternal|chest|anteriorDeltoids,triceps|position=incline
decline_barbell_press|Decline Barbell Bench Press|下斜杠铃卧推|horizontalPress|barbell|totalExternal|chest|triceps,anteriorDeltoids|position=decline
decline_dumbbell_press|Decline Dumbbell Bench Press|下斜哑铃卧推|horizontalPress|dumbbell|perDumbbell|chest|triceps,anteriorDeltoids|position=decline
smith_bench_press|Smith Machine Bench Press|史密斯平板卧推|horizontalPress|machine|machineStack|chest|triceps,anteriorDeltoids|position=supine;equipmentVariant=smithMachine
smith_incline_press|Smith Machine Incline Press|史密斯上斜卧推|horizontalPress|machine|machineStack|chest|anteriorDeltoids,triceps|position=incline;equipmentVariant=smithMachine
machine_chest_press|Machine Chest Press|坐姿器械推胸|horizontalPress|machine|machineStack|chest|triceps,anteriorDeltoids|position=seated
iso_lateral_chest_press|Unilateral Machine Chest Press|单侧器械推胸|horizontalPress|machine|machineStack|chest|triceps,anteriorDeltoids|position=seated;laterality=unilateral
barbell_floor_press|Barbell Floor Press|杠铃地板卧推|horizontalPress|barbell|totalExternal|triceps,chest|anteriorDeltoids|position=supine;techniques=partial
spoto_press|Spoto Press|斯波托卧推|horizontalPress|barbell|totalExternal|chest|triceps,anteriorDeltoids|position=supine;techniques=paused
board_press|Board Press|垫板卧推|horizontalPress|barbell|totalExternal|triceps,chest|anteriorDeltoids|position=supine;techniques=partial
pin_bench_press|Pin Bench Press|架上卧推|horizontalPress|barbell|totalExternal|triceps,chest|anteriorDeltoids|position=supine;techniques=paused,partial
larsen_press|Larsen Press|拉森卧推|horizontalPress|barbell|totalExternal|chest|triceps,anteriorDeltoids,core|position=supine
dumbbell_fly|Dumbbell Fly|哑铃飞鸟|horizontalPress|dumbbell|perDumbbell|chest|anteriorDeltoids|position=supine
incline_dumbbell_fly|Incline Dumbbell Fly|上斜哑铃飞鸟|horizontalPress|dumbbell|perDumbbell|chest|anteriorDeltoids|position=incline
cable_crossover|Cable Crossover|绳索夹胸|horizontalPress|cable|cableStack|chest|anteriorDeltoids|
low_to_high_cable_fly|Low to High Cable Fly|低位绳索夹胸|horizontalPress|cable|cableStack|chest|anteriorDeltoids|
high_to_low_cable_fly|High to Low Cable Fly|高位绳索夹胸|horizontalPress|cable|cableStack|chest|anteriorDeltoids|
pec_deck|Pec Deck Fly|蝴蝶机夹胸|horizontalPress|machine|machineStack|chest|anteriorDeltoids|position=seated
push_up|Push Up|俯卧撑|horizontalPress|bodyweight|bodyweight|chest|triceps,anteriorDeltoids,core|position=prone
incline_push_up|Incline Push Up|上斜俯卧撑|horizontalPress|bodyweight|bodyweight|chest|triceps,anteriorDeltoids,core|position=incline
decline_push_up|Decline Push Up|下斜俯卧撑|horizontalPress|bodyweight|bodyweight|chest|anteriorDeltoids,triceps,core|position=decline
diamond_push_up|Diamond Push Up|窄距俯卧撑|horizontalPress|bodyweight|bodyweight|triceps,chest|anteriorDeltoids,core|position=prone
ring_push_up|Ring Push Up|吊环俯卧撑|horizontalPress|bodyweight|bodyweight|chest|triceps,anteriorDeltoids,core|position=prone;equipmentVariant=rings
dip|Parallel Bar Dip|双杠臂屈伸|verticalPress|bodyweight|bodyweight|chest,triceps|anteriorDeltoids|
weighted_dip|Weighted Dip|负重双杠臂屈伸|verticalPress|bodyweight|bodyweightPlusExternal|chest,triceps|anteriorDeltoids|
assisted_dip|Assisted Dip Machine|器械辅助双杠臂屈伸|verticalPress|machine|machineStack|chest,triceps|anteriorDeltoids|techniques=assisted
chin_up|Chin Up|反握引体向上|verticalPull|bodyweight|bodyweight|lats,biceps|upperBack,forearms|grip=supinated;position=hanging
neutral_grip_pull_up|Neutral Grip Pull Up|中立握引体向上|verticalPull|bodyweight|bodyweight|lats|biceps,upperBack,forearms|grip=neutral;position=hanging
assisted_pull_up|Assisted Pull Up Machine|器械辅助引体向上|verticalPull|machine|machineStack|lats|biceps,upperBack|position=hanging;techniques=assisted
band_assisted_pull_up|Band Assisted Pull Up|弹力带辅助引体向上|verticalPull|band|bandResistance|lats|biceps,upperBack|position=hanging;techniques=assisted
straight_arm_pulldown|Straight Arm Cable Pulldown|直臂下压|verticalPull|cable|cableStack|lats|triceps,core|
dumbbell_pullover|Dumbbell Pullover|哑铃仰卧上拉|verticalPull|dumbbell|totalExternal|lats,chest|triceps|position=supine
machine_pullover|Machine Pullover|器械上拉|verticalPull|machine|machineStack|lats|triceps|position=seated
one_arm_lat_pulldown|Single Arm Cable Pulldown|单臂高位下拉|verticalPull|cable|cableStack|lats|biceps,upperBack|laterality=unilateral;position=kneeling
seated_cable_row|Seated Cable Row|坐姿绳索划船|horizontalPull|cable|cableStack|lats,upperBack|biceps,rearDeltoids|position=seated;grip=neutral
wide_cable_row|Wide Grip Cable Row|宽握坐姿划船|horizontalPull|cable|cableStack|upperBack,rearDeltoids|lats,biceps|position=seated;grip=pronated
machine_row|Seated Machine Row|坐姿器械划船|horizontalPull|machine|machineStack|lats,upperBack|biceps,rearDeltoids|position=seated
high_row_machine|High Row Machine|高位器械划船|horizontalPull|machine|machineStack|lats,upperBack|biceps,rearDeltoids|position=seated
t_bar_row|T Bar Row|T 杠划船|horizontalPull|barbell|totalExternal|lats,upperBack|biceps,rearDeltoids,lowerBack|equipmentVariant=landmine;grip=neutral
meadows_row|Meadows Row|梅多斯划船|horizontalPull|barbell|totalExternal|lats,upperBack|biceps,rearDeltoids|equipmentVariant=landmine;laterality=unilateral
inverted_row|Inverted Row|反向划船|horizontalPull|bodyweight|bodyweight|upperBack,lats|biceps,rearDeltoids,core|position=supine
ring_row|Ring Row|吊环划船|horizontalPull|bodyweight|bodyweight|upperBack,lats|biceps,rearDeltoids,core|position=supine;equipmentVariant=rings
seal_row|Barbell Seal Row|海豹划船|horizontalPull|barbell|totalExternal|upperBack,lats|biceps,rearDeltoids|position=prone
underhand_barbell_row|Underhand Barbell Row|反握杠铃划船|horizontalPull|barbell|totalExternal|lats|biceps,upperBack,lowerBack|grip=supinated
barbell_shrug|Barbell Shrug|杠铃耸肩|verticalPull|barbell|totalExternal|upperBack|forearms|
dumbbell_shrug|Dumbbell Shrug|哑铃耸肩|verticalPull|dumbbell|perDumbbell|upperBack|forearms|grip=neutral
machine_shrug|Machine Shrug|器械耸肩|verticalPull|machine|machineStack|upperBack|forearms|
seated_barbell_press|Seated Barbell Shoulder Press|坐姿杠铃推举|verticalPress|barbell|totalExternal|anteriorDeltoids|lateralDeltoids,triceps|position=seated
arnold_press|Arnold Press|阿诺德推举|verticalPress|dumbbell|perDumbbell|anteriorDeltoids,lateralDeltoids|triceps|position=seated
machine_shoulder_press|Machine Shoulder Press|器械推肩|verticalPress|machine|machineStack|anteriorDeltoids|lateralDeltoids,triceps|position=seated
smith_shoulder_press|Smith Machine Shoulder Press|史密斯推肩|verticalPress|machine|machineStack|anteriorDeltoids|lateralDeltoids,triceps|position=seated;equipmentVariant=smithMachine
landmine_press|Single Arm Landmine Press|单臂地雷架推举|verticalPress|barbell|totalExternal|anteriorDeltoids|chest,triceps,core|laterality=unilateral;equipmentVariant=landmine
z_press|Barbell Z Press|坐地杠铃推举|verticalPress|barbell|totalExternal|anteriorDeltoids|triceps,lateralDeltoids,core|position=seated
push_press|Push Press|借力推举|verticalPress|barbell|totalExternal|anteriorDeltoids,triceps|quadriceps,glutes,core|techniques=explosive
machine_lateral_raise|Machine Lateral Raise|器械侧平举|shoulderAbduction|machine|machineStack|lateralDeltoids|upperBack|position=seated
leaning_cable_lateral_raise|Leaning Cable Lateral Raise|侧倾绳索侧平举|shoulderAbduction|cable|cableStack|lateralDeltoids|upperBack|laterality=unilateral
drop_set_lateral_raise|Dumbbell Lateral Raise Drop Set|哑铃侧平举递减组|shoulderAbduction|dumbbell|perDumbbell|lateralDeltoids|upperBack|techniques=dropSet
dumbbell_front_raise|Dumbbell Front Raise|哑铃前平举|verticalPress|dumbbell|perDumbbell|anteriorDeltoids|chest|
reverse_pec_deck|Reverse Pec Deck|反向蝴蝶机飞鸟|horizontalPull|machine|machineStack|rearDeltoids|upperBack|position=seated
cable_reverse_fly|Cable Reverse Fly|绳索反向飞鸟|horizontalPull|cable|cableStack|rearDeltoids|upperBack|
cable_external_rotation|Cable External Rotation|绳索肩外旋|shoulderExternalRotation|cable|cableStack|rearDeltoids|upperBack|laterality=unilateral
ez_bar_curl|EZ Bar Curl|曲杆弯举|elbowFlexion|barbell|totalExternal|biceps|forearms|equipmentVariant=ezBar;grip=supinated
preacher_curl|Preacher Curl|牧师凳弯举|elbowFlexion|barbell|totalExternal|biceps|forearms|position=seated;equipmentVariant=ezBar
machine_preacher_curl|Machine Preacher Curl|器械牧师凳弯举|elbowFlexion|machine|machineStack|biceps|forearms|position=seated
incline_dumbbell_curl|Incline Dumbbell Curl|上斜哑铃弯举|elbowFlexion|dumbbell|perDumbbell|biceps|forearms|position=incline;grip=supinated
concentration_curl|Concentration Curl|集中弯举|elbowFlexion|dumbbell|perDumbbell|biceps|forearms|position=seated;laterality=unilateral;grip=supinated
cable_curl|Cable Curl|绳索弯举|elbowFlexion|cable|cableStack|biceps|forearms|grip=supinated
bayesian_curl|Behind Body Cable Curl|身后绳索弯举|elbowFlexion|cable|cableStack|biceps|forearms|laterality=unilateral;grip=supinated
spider_curl|Spider Curl|蜘蛛弯举|elbowFlexion|dumbbell|perDumbbell|biceps|forearms|position=prone;grip=supinated
reverse_curl|Reverse Barbell Curl|反握杠铃弯举|elbowFlexion|barbell|totalExternal|forearms|biceps|grip=pronated
zottman_curl|Zottman Curl|佐特曼弯举|elbowFlexion|dumbbell|perDumbbell|biceps,forearms||
twenty_one_curl|Barbell Curl 21s|杠铃弯举21响礼炮|elbowFlexion|barbell|totalExternal|biceps|forearms|grip=supinated;techniques=twentyOne,partial
rope_hammer_curl|Rope Hammer Curl|绳索锤式弯举|elbowFlexion|cable|cableStack|biceps,forearms||grip=neutral
skull_crusher|EZ Bar Skull Crusher|曲杆仰卧臂屈伸|elbowExtension|barbell|totalExternal|triceps||position=supine;equipmentVariant=ezBar
dumbbell_skull_crusher|Dumbbell Skull Crusher|哑铃仰卧臂屈伸|elbowExtension|dumbbell|perDumbbell|triceps||position=supine;grip=neutral
overhead_cable_extension|Overhead Cable Triceps Extension|绳索过顶臂屈伸|elbowExtension|cable|cableStack|triceps||
rope_pushdown|Rope Triceps Pushdown|绳索绳头下压|elbowExtension|cable|cableStack|triceps||grip=neutral
reverse_grip_pushdown|Reverse Grip Triceps Pushdown|反握绳索下压|elbowExtension|cable|cableStack|triceps||grip=supinated
single_arm_pushdown|Single Arm Triceps Pushdown|单臂绳索下压|elbowExtension|cable|cableStack|triceps||laterality=unilateral
dumbbell_kickback|Dumbbell Triceps Kickback|哑铃俯身臂屈伸|elbowExtension|dumbbell|perDumbbell|triceps||laterality=unilateral
bench_dip|Bench Dip|凳上臂屈伸|elbowExtension|bodyweight|bodyweightPlusExternal|triceps|anteriorDeltoids,chest|position=seated
machine_triceps_extension|Machine Triceps Extension|器械臂屈伸|elbowExtension|machine|machineStack|triceps||position=seated
wrist_curl|Wrist Curl|腕弯举|elbowFlexion|barbell|totalExternal|forearms||position=seated;grip=supinated
reverse_wrist_curl|Reverse Wrist Curl|反向腕弯举|elbowExtension|barbell|totalExternal|forearms||position=seated;grip=pronated
farmer_carry|Dumbbell Farmer Carry|哑铃农夫行走|locomotion|dumbbell|perDumbbell|forearms,upperBack|core,glutes,calves|measurement=distance
suitcase_carry|Suitcase Carry|单侧提箱行走|locomotion|dumbbell|perDumbbell|core,forearms|upperBack,glutes|laterality=unilateral;measurement=distance
crunch|Crunch|卷腹|core|bodyweight|bodyweight|core||position=supine
reverse_crunch|Reverse Crunch|反向卷腹|core|bodyweight|bodyweight|core||position=supine
cable_crunch|Kneeling Cable Crunch|跪姿绳索卷腹|core|cable|cableStack|core||position=kneeling
machine_crunch|Machine Abdominal Crunch|器械卷腹|core|machine|machineStack|core||position=seated
hanging_leg_raise|Hanging Leg Raise|悬垂举腿|core|bodyweight|bodyweight|core|forearms|position=hanging
hanging_knee_raise|Hanging Knee Raise|悬垂屈膝举腿|core|bodyweight|bodyweight|core|forearms|position=hanging
captains_chair_leg_raise|Captains Chair Leg Raise|罗马椅举腿|core|bodyweight|bodyweight|core||
seated_leg_raise|Seated Leg Raise|坐姿举腿|core|bodyweight|bodyweight|core||position=seated
ab_wheel|Kneeling Ab Wheel Rollout|跪姿健腹轮|core|bodyweight|bodyweight|core|lats,anteriorDeltoids|position=kneeling
plank|Forearm Plank|平板支撑|core|bodyweight|bodyweight|core|glutes,anteriorDeltoids|position=prone;measurement=duration;techniques=isometric
side_plank|Side Plank|侧平板支撑|core|bodyweight|bodyweight|core|glutes,lateralDeltoids|laterality=unilateral;measurement=duration;techniques=isometric
dead_bug|Dead Bug|死虫式|core|bodyweight|bodyweight|core||position=supine;laterality=alternating
bird_dog|Bird Dog|鸟狗式|core|bodyweight|bodyweight|core|glutes,lowerBack|position=kneeling;laterality=alternating
pallof_press|Pallof Press|帕洛夫抗旋转推|core|cable|cableStack|core|glutes|techniques=isometric
cable_woodchop|Cable Woodchop|绳索伐木|core|cable|cableStack|core|anteriorDeltoids|laterality=unilateral
russian_twist|Russian Twist|俄罗斯转体|core|bodyweight|bodyweightPlusExternal|core||position=seated;laterality=alternating
sit_up|Sit Up|仰卧起坐|core|bodyweight|bodyweight|core||position=supine
decline_sit_up|Decline Sit Up|下斜仰卧起坐|core|bodyweight|bodyweight|core||position=decline
clean|Barbell Clean|杠铃翻站|hinge|barbell|totalExternal|quadriceps,glutes|hamstrings,upperBack,core|grip=hook;techniques=explosive
power_clean|Power Clean|高翻|hinge|barbell|totalExternal|quadriceps,glutes|hamstrings,upperBack,core|grip=hook;techniques=explosive
hang_clean|Hang Clean|悬垂翻站|hinge|barbell|totalExternal|quadriceps,glutes|hamstrings,upperBack,core|grip=hook;techniques=explosive
snatch|Barbell Snatch|杠铃抓举|hinge|barbell|totalExternal|quadriceps,glutes|hamstrings,upperBack,anteriorDeltoids,core|grip=hook;techniques=explosive
power_snatch|Power Snatch|高抓|hinge|barbell|totalExternal|quadriceps,glutes|hamstrings,upperBack,anteriorDeltoids,core|grip=hook;techniques=explosive
clean_pull|Clean Pull|翻站拉|hinge|barbell|totalExternal|glutes,quadriceps|hamstrings,upperBack,lowerBack|grip=hook;techniques=explosive
snatch_pull|Snatch Pull|抓举拉|hinge|barbell|totalExternal|glutes,quadriceps|hamstrings,upperBack,lowerBack|grip=hook;techniques=explosive
split_jerk|Split Jerk|分腿挺举|verticalPress|barbell|totalExternal|quadriceps,anteriorDeltoids,triceps|glutes,core|techniques=explosive
push_jerk|Push Jerk|借力挺举|verticalPress|barbell|totalExternal|quadriceps,anteriorDeltoids,triceps|glutes,core|techniques=explosive
overhead_squat|Overhead Squat|过顶深蹲|squat|barbell|totalExternal|quadriceps,glutes|core,upperBack,anteriorDeltoids|
kettlebell_swing|Kettlebell Swing|壶铃摆动|hipExtension|mixed|totalExternal|glutes,hamstrings|core,lowerBack,forearms|equipmentVariant=kettlebell;techniques=explosive
kettlebell_clean|Single Arm Kettlebell Clean|单臂壶铃翻站|hinge|mixed|totalExternal|glutes,hamstrings|quadriceps,upperBack,core|equipmentVariant=kettlebell;laterality=unilateral;techniques=explosive
kettlebell_snatch|Single Arm Kettlebell Snatch|单臂壶铃抓举|hinge|mixed|totalExternal|glutes,hamstrings|anteriorDeltoids,upperBack,core|equipmentVariant=kettlebell;laterality=unilateral;techniques=explosive
turkish_get_up|Turkish Get Up|土耳其起立|core|mixed|totalExternal|core|glutes,quadriceps,anteriorDeltoids|equipmentVariant=kettlebell;laterality=unilateral
sled_push|Sled Push|雪橇推|locomotion|mixed|totalExternal|quadriceps,glutes|calves,core,anteriorDeltoids|equipmentVariant=sled;measurement=distance
sled_drag|Backward Sled Drag|反向拖雪橇|locomotion|mixed|totalExternal|quadriceps|glutes,calves|equipmentVariant=sled;measurement=distance
battle_rope|Battle Rope Waves|战绳波浪|locomotion|mixed|totalExternal|anteriorDeltoids|core,forearms|measurement=duration;laterality=alternating
medicine_ball_slam|Medicine Ball Slam|药球砸地|core|mixed|totalExternal|core,lats|anteriorDeltoids,glutes|equipmentVariant=medicineBall;techniques=explosive
wall_ball|Wall Ball Shot|药球抛墙|squat|mixed|totalExternal|quadriceps,glutes|anteriorDeltoids,triceps,core|equipmentVariant=medicineBall;techniques=explosive
box_jump|Box Jump|跳箱|kneeDominant|bodyweight|bodyweight|quadriceps,glutes|calves|techniques=explosive
burpee|Burpee|波比跳|locomotion|bodyweight|bodyweight|quadriceps,chest|glutes,triceps,core|techniques=explosive
mountain_climber|Mountain Climber|登山跑|core|bodyweight|bodyweight|core|quadriceps,anteriorDeltoids|position=prone;laterality=alternating;measurement=duration
''';

Map<String, dynamic> execution(String name, String overrides) {
  final lower = name.toLowerCase();
  final value = <String, dynamic>{
    'laterality': lower.contains('one arm') || lower.contains('single')
        ? 'unilateral'
        : 'bilateral',
    'grip': lower.contains('neutral') || lower.contains('hammer')
        ? 'neutral'
        : 'standard',
    'position': lower.contains('incline')
        ? 'incline'
        : lower.contains('seated')
        ? 'seated'
        : lower.contains('bench press') ||
              lower.contains('floor press') ||
              lower == 'bench press'
        ? 'supine'
        : lower.contains('pull up')
        ? 'hanging'
        : 'standing',
    'measurement': 'repetitions',
    'techniques': <String>[],
    'equipmentVariant': '',
  };
  for (final entry in overrides.split(';').where((part) => part.isNotEmpty)) {
    final parts = entry.split('=');
    value[parts[0]] = parts[0] == 'techniques' ? parts[1].split(',') : parts[1];
  }
  return value;
}

void main() {
  final file = File('assets/exercises/exercise_library.v1.json');
  final catalog = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final definitions = (catalog['definitions'] as List)
      .cast<Map<String, dynamic>>();
  final ids = definitions.map((item) => item['id']).toSet();
  for (final row in additions.trim().split('\n')) {
    final c = row.split('|');
    if (c.length != 9) throw FormatException('Invalid curated row: ${c.first}');
    if (ids.contains(c[0])) continue;
    final primary = c[6].split(',');
    final secondary = c[7].isEmpty ? <String>[] : c[7].split(',');
    final total = primary.length * 2 + secondary.length;
    definitions.add({
      'id': c[0],
      'kind': 'exercise',
      'names': {'en': c[1], 'zhCn': c[2]},
      'aliases': <String>[],
      'legacyIds': <String>[],
      'movement': c[3],
      'equipment': c[4],
      'loadSemantics': c[5],
      'muscles': {
        'primary': primary,
        'secondary': secondary,
        'weights': {
          for (final muscle in primary) muscle: 2 / total,
          for (final muscle in secondary) muscle: 1 / total,
        },
      },
      'strengthFamily': 'none',
      'isCompetitionLift': false,
      'roundingIncrementKg': c[4] == 'dumbbell' ? 1.0 : 2.5,
      'ratioPrior': {
        'mode': 'calibrationOnly',
        'anchor': 'none',
        'lower': null,
        'center': null,
        'upper': null,
        'evidenceGrade': 'calibrationOnly',
        'confidence': 'low',
        'sourceIds': ['fittin_catalog_policy_v1'],
      },
      'sourceIds': ['fittin_catalog_policy_v1', 'ace_exercise_reference'],
      'sourceRevision': '2026-09-09',
      'license': 'Fittin-owned curated factual metadata',
      'execution': execution(c[1], c[8]),
    });
    ids.add(c[0]);
  }
  for (final item in definitions) {
    if (item['kind'] == 'selectionSlot') continue;
    item.putIfAbsent(
      'execution',
      () => execution((item['names'] as Map)['en'] as String, ''),
    );
  }
  // Taxonomy corrections are explicit instead of guessing from muscle tags.
  const movementCorrections = {
    'leg_curl': 'kneeFlexion',
    'seated_leg_curl': 'kneeFlexion',
    'lying_leg_curl': 'kneeFlexion',
    'standing_leg_curl': 'kneeFlexion',
    'nordic_curl': 'kneeFlexion',
    'glute_ham_raise': 'kneeFlexion',
    'hip_abduction_machine': 'hipAbduction',
    'hip_adduction_machine': 'hipAdduction',
    'standing_calf_raise': 'anklePlantarFlexion',
    'seated_calf_raise': 'anklePlantarFlexion',
    'single_leg_calf_raise': 'anklePlantarFlexion',
    'leg_press_calf_raise': 'anklePlantarFlexion',
    'wrist_curl': 'wristFlexion',
    'reverse_wrist_curl': 'wristExtension',
    'barbell_shrug': 'scapularElevation',
    'dumbbell_shrug': 'scapularElevation',
    'machine_shrug': 'scapularElevation',
    'dumbbell_front_raise': 'shoulderFlexion',
    'dumbbell_fly': 'horizontalAdduction',
    'incline_dumbbell_fly': 'horizontalAdduction',
    'cable_crossover': 'horizontalAdduction',
    'low_to_high_cable_fly': 'horizontalAdduction',
    'high_to_low_cable_fly': 'horizontalAdduction',
    'pec_deck': 'horizontalAdduction',
    'clean': 'olympicLift',
    'power_clean': 'olympicLift',
    'hang_clean': 'olympicLift',
    'snatch': 'olympicLift',
    'power_snatch': 'olympicLift',
    'clean_pull': 'olympicLift',
    'snatch_pull': 'olympicLift',
    'split_jerk': 'olympicLift',
    'push_jerk': 'olympicLift',
  };
  String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u3400-\u9fff]+'), '');
  final canonicalNames = <String, String>{};
  for (final item in definitions) {
    for (final name in (item['names'] as Map).values.cast<String>()) {
      canonicalNames[normalize(name)] = item['id'] as String;
    }
  }
  for (final item in definitions) {
    final id = item['id'] as String;
    const positions = {
      'back_extension_45': 'prone',
      'weighted_back_extension': 'prone',
      'chest_supported_row': 'prone',
      'dumbbell_fly': 'supine',
    };
    if (positions.containsKey(id)) {
      (item['execution'] as Map)['position'] = positions[id];
    }
    if (movementCorrections.containsKey(id)) {
      item['movement'] = movementCorrections[id];
    }
    // A newly explicit variation takes precedence over an old broad alias;
    // persisted canonical IDs and values never change.
    (item['aliases'] as List).removeWhere((alias) {
      final canonical = canonicalNames[normalize(alias as String)];
      return canonical != null && canonical != id;
    });
    if (id == 'cable_external_rotation') {
      item['muscles'] = {
        'primary': ['rotatorCuff'],
        'secondary': ['rearDeltoids'],
        'weights': {'rotatorCuff': .8, 'rearDeltoids': .2},
      };
    }
    if ([
      'hanging_leg_raise',
      'hanging_knee_raise',
      'captains_chair_leg_raise',
      'seated_leg_raise',
    ].contains(id)) {
      item['movement'] = 'hipFlexion';
      item['muscles'] = {
        'primary': ['hipFlexors', 'core'],
        'secondary': <String>[],
        'weights': {'hipFlexors': .5, 'core': .5},
      };
    }
  }
  final sources = catalog['sources'] as List;
  if (!sources.any((item) => item['id'] == 'ace_exercise_reference')) {
    sources.add({
      'id': 'ace_exercise_reference',
      'category': 'exercise_reference',
      'uri': 'https://www.acefitness.org/resources/everyone/exercise-library/',
      'revision': 'accessed-2026-09-09',
      'license': 'Reference only; no text or images copied',
    });
  }
  catalog['catalogVersion'] = '1.2.0';
  catalog['sourceRevision'] = '2026-09-09';
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(catalog)}\n',
  );
  stdout.writeln('${definitions.length} catalog definitions');
}
