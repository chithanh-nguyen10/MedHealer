library globals;

import 'dart:async';

bool isDark = false;

bool registered = false;
bool isLoading = true;
String first_name = "";
String last_name = "";
String email = "";
String pass = "";
String dob = "";
String gender = "";
String avatar = "";
String type = "";
int currentid = 0;
List<String> anamnesis = ["null"];
List<String> familyanamnesis = [];

double imageMB = 0;
const double EPSILON = 1e-4;
const double limitedMB = 5.0;

String settingState = "default";
String historyState = "default";

final StreamController<String> _historyStateController = StreamController<String>.broadcast();

Stream<String> get historyStateStream => _historyStateController.stream;

void changeHistoryState(String newState) {
  historyState = newState;
  _historyStateController.add(newState);
}

void disposeHistoryStateStream() {
  _historyStateController.close();
}

Map<String, String> healthMatch = {};
Map<String, String> symptomMatch = {};
Map<String, String> anamHealthMatch = {};
Map<String, String> familyanamHealthMatch = {};

const Map<String, String> types = {
  "stomachace" : "Đau bụng",
  "fever" : "Sốt",
  "bowel" : "Nôn",
  "vomit" : "Tiêu",
  "yskin" : "Vàng da",
  "other" : "Khác"
};

const Map<String, String> healthTypes = {
  "in" : "Nội",
  "out" : "Ngoại",
};

const Map<String, String> anamnesisTypes = {
  "reproductive" : "Sinh đẻ",
  "circulatory" : "Tuần hoàn",
  "digestion" : "Tiêu hoá",
  "medicine" : "Sử dụng thuốc",
  "nervementality" : "Thần kinh",
  "skin" : "Da",
  "stimulant" : "Chất kích thích"
};

const Map<String, String> familyanamnesisTypes = {
  "digestion" : "Tiêu hoá",
  "allergy" : "Dị ứng",
  "liver" : "Gan",
  "respiratory" : "Hô hấp",
  "other" : "Khác"
};