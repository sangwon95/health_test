
import 'package:health/health.dart';

class HeartData{

  String dateTime;
  List<Map<String, dynamic>> heartMap  = <Map<String, dynamic>>[];

  Map<String, dynamic> dioMap() {
      Map<String, dynamic> toMap = {
        'os'             : 'A',
        'measureDate'    : dateTime,
        'rawData'        : heartMap,
      };
    return toMap;
  }

  Map<String, dynamic> setMap(HealthDataPoint p){
   dateTime = p.dateFrom.toString().substring(0, 10);

    Map<String, dynamic> toMap = {
      'time':'${p.dateFrom.toString().substring(11, 19)}',
      'value':p.value.toInt()
    };

    return toMap;
  }

  addHeartMap(HealthDataPoint p){
    heartMap.add(setMap(p));
    print(heartMap);
  }

}

