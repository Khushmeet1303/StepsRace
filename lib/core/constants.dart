// App-wide constants
const int kDefaultGoal = 10000;
const int kGoalStep = 500;
const int kMinGoal = 500;
const int kSyncIntervalSeconds = 60;

// Firestore collection names
const String kColUsers = 'users';
const String kColGroups = 'groups';
const String kColDailySteps = 'dailySteps';

// SharedPreferences keys
const String kPrefStepBaseline = 'step_baseline';
const String kPrefLastResetDate = 'last_reset_date';
const String kPrefTodaySteps = 'today_steps';
const String kPrefUserColor = 'user_color';
const String kPrefUserGoal = 'user_goal';
const String kPrefUserName = 'user_name';
const String kPrefGroupId = 'group_id';
const String kPrefPermissionGranted = 'permission_granted';
