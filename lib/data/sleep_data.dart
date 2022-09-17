
import 'package:health/health.dart';

class SleepData{

  String dateTime;
  List<Map<String, dynamic>> sleepMap  = <Map<String, dynamic>>[];

  Map<String, dynamic> dioMap() {
      Map<String, dynamic> toMap = {
        'os'             : 'A',
        'measureDate'    : dateTime,
        'rawData'        : sleepMap,
      };
    return toMap;
  }

  Map<String, dynamic> setMap(HealthDataPoint p){
   dateTime = p.dateFrom.toString().substring(0, 10);

    Map<String, dynamic> toMap = {
      'time':'${p.dateFrom.toString().substring(0, 16)} ~ ${p.dateTo.toString().substring(0, 16)}',
      'value':p.value.toInt()
    };

    return toMap;
  }

  addSleepMap(HealthDataPoint p){
    sleepMap.add(setMap(p));
    print(sleepMap);
  }

}

