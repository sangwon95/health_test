
import 'package:health/health.dart';

class StepData{

  String dateTime;
  List<Map<String, dynamic>> stepMap  = <Map<String, dynamic>>[];

  Map<String, dynamic> dioMap() {
      Map<String, dynamic> toMap = {
        'os'             : 'A',
        'measureDate'    : dateTime,
        'rawData'        : stepMap,
      };
    return toMap;
  }

  Map<String, dynamic> setMap(HealthDataPoint p){
   dateTime = p.dateFrom.toString().substring(0, 10);

    Map<String, dynamic> toMap = {
      'time':'${p.dateFrom.toString().substring(0, 19)} ~ ${p.dateTo.toString().substring(0, 19)}',
      'value':p.value
    };

    return toMap;
  }

  addStepMap(HealthDataPoint p){
    stepMap.add(setMap(p));
  }

  int getLength(){
    return stepMap.length;
  }

}

