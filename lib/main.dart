import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_test/data/step_data.dart';
import 'package:health_test/utils/dio_clinet.dart';
import 'package:health_test/utils/etc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'data/heart_data.dart';
import 'data/sleep_data.dart';


const String URL_BASE = 'http://192.168.0.54:50013/ws';
const String URL_STEP_COUNT = '$URL_BASE/public/stepcount';
const String URL_SLEEP_TIME = '$URL_BASE/public/sleeptime';
const String URL_HEART_RATE = '$URL_BASE/public/heartrate';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized(); // 플랫폼 채널의 위젯 바인딩을 보장해야한다.

  await Permission.activityRecognition.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HealthApp(),
    );
  }
}
class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED, 
  DATA_NOT_ADDED,
  STEPS_READY,
}

class _HealthAppState extends State<HealthApp> {

  StepData stepData   = StepData();
  HeartData heartData = HeartData();
  SleepData sleepData = SleepData();

  String typeStatus;

  DateTime _nowTime;
  String _midnightTime;


  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 10;
  double _mgdl = 10.0;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  double steps = 0;


  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData(HealthDataType type) async {

    setState(() => _state = AppState.FETCHING_DATA);

    final types = [type];  // define the types to get
    final permissions = [ HealthDataAccess.READ ];// with coresponsing permissions


    final now = DateTime.now();
    //final now12 = DateTime(2022,9,14,0,1);
    final yesterday = now.subtract(Duration(days: 7)); // get data within the last 24 hours

    bool requested = await health.requestAuthorization(types, permissions: permissions);    // needed, since we only want READ access.

    if (requested) {
      try {
        // int totalStep = await health.getTotalStepsInInterval(yesterday, now);
        // print('totalStep : $totalStep');

        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(yesterday, now, types);        // fetch health data
        _healthDataList.addAll((healthData.length < 300)      // save all the new data points (only the first 100)
            ? healthData : healthData.sublist(0, 300));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);// filter out duplicates

      _healthDataList.forEach((x) {
        print("Data point: ${x.value.toDouble()}");

      });

      print("Steps: $steps");
      setState(() {
        _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;   // update the UI to display the results
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {

    for(int i = 0 ; i<_healthDataList.length ; i++){
      HealthDataPoint p = _healthDataList[i];

      if(p.typeString == 'STEPS')
      {
        stepData.addStepMap(p);
      }
      else if(p.typeString == 'HEART_RATE')
      {
        heartData.addHeartMap(p);
      }
      else{
        sleepData.addSleepMap(p);
      }
    }



    return Expanded(
      child: ListView.builder(
          itemCount: _healthDataList.length,
          itemBuilder: (_, index)
          {
            //print('>>>> [_healthDataList.length] : '+ _healthDataList.length.toString());
            HealthDataPoint p = _healthDataList[index];
            return Card(
              elevation: 3,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text("${p.typeString}: ${p.value}"),
                ),
                subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
              ),
            );
          }),
    );
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Column(
      children: [
        SizedBox(height: 100),
        Text('불러온 데이터가 없습니다.'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _authorizationNotGranted() {
    return Text('Authorization not given. '
        'For Android please check your OAUTH2 client ID is correct in Google Developer Console. '
        'For iOS check your permissions in Apple Health.');
  }

  Widget _dataAdded() {
    return Text('$_nofSteps steps and $_mgdl mgdl are inserted successfully!');
  }

  Widget _stepsFetched() {
    return Text('Total number of steps: $_nofSteps');
  }

  Widget _dataNotAdded() {
    return Text('Failed to add data');
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(// foreground
                  style: TextButton.styleFrom( backgroundColor: Colors.blue),
                  child: Text('걸음 가져오기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                  onPressed: ()=>
                  {
                    _healthDataList.clear(),
                    fetchData(HealthDataType.STEPS)
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom( backgroundColor: Colors.blue),
                  child: Text('심박 가져오기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                  onPressed: ()=>
                  {
                    _healthDataList.clear(),
                    fetchData(HealthDataType.HEART_RATE)
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom( backgroundColor: Colors.blue),
                  child: Text('수면 가져오기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                  onPressed: ()=>
                  {
                    _healthDataList.clear(),
                    fetchData(HealthDataType.SLEEP_IN_BED)
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(// foreground
                    style: TextButton.styleFrom( backgroundColor: Colors.blue, ),
                    child: Text('걸음 전송하기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                    onPressed: ()=>
                    {
                      _sendStepHttp(context),
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom( backgroundColor: Colors.blue),
                    child: Text('심박 전송하기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                    onPressed: ()=>
                    {
                      _sendHeartRateHttp(context),
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom( backgroundColor: Colors.blue),
                    child: Text('수면 전송하기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                    onPressed: ()=>
                    {
                      _sendSleepHttp(context),
                    },
                  )
                ],
              ),
            ),
          ),

          _buildDataList()
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  _sendStepHttp(BuildContext context) async
  {
    print('>>>> [stepData.getLength] : ' + stepData.getLength().toString());

     Etc.getValuesFromMap(stepData.dioMap());
    Response response = await client.dioPost(URL_STEP_COUNT, stepData.dioMap(), context);
    print(' >>> [response.statusMessage] : '+ response.statusMessage);
    Etc.showToast('걸음수 : '+response.statusMessage, context);

  }

  _sendHeartRateHttp(BuildContext context) async
  {
    Etc.getValuesFromMap(heartData.dioMap());
     Response response = await client.dioPost(URL_HEART_RATE, heartData.dioMap(), context);
     print(' >>> [response.statusMessage] : '+ response.statusMessage);
     Etc.showToast('심박동 : '+response.statusMessage, context);
  }

  _sendSleepHttp(BuildContext context) async
  {
    Etc.getValuesFromMap(sleepData.dioMap());
    Response response = await client.dioPost(URL_SLEEP_TIME, sleepData.dioMap(), context);
    print(' >>> [response.statusMessage] : '+ response.statusMessage);
    Etc.showToast('수면시간 :'+response.statusMessage, context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Health Data')),
          body: Center(
            child: _content(context),
          )),
    );
  }

  _buildDataList() {
    if (_state == AppState.DATA_READY)
      return _contentDataReady();
    else if (_state == AppState.NO_DATA)
      return _contentNoData();
    else if (_state == AppState.FETCHING_DATA)
      return _contentFetchingData();
    else if (_state == AppState.AUTH_NOT_GRANTED)
      return _authorizationNotGranted();
    else if (_state == AppState.DATA_ADDED)
      return _dataAdded();
    else if (_state == AppState.STEPS_READY)
      return _stepsFetched();
    else if (_state == AppState.DATA_NOT_ADDED)
      return _dataNotAdded();

    return _contentNotFetched();
  }

}