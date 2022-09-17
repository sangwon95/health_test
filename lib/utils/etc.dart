import 'package:flutter/material.dart';
import 'package:toast/toast.dart';


class Etc {


  // static settingImageCircle(UserDetails userDetails){
  //   final String imagePath = 'images/man_d.png';
  //   final String baseProfileUrl = 'http://106.251.70.71:50006/profile/';
  //
  //   return userDetails.profileImg == '-' ?
  //   SizedBox(width: 60.0, height: 60.0, child: Image.asset(imagePath, fit: BoxFit.fill)):
  //   CircleAvatar(
  //     radius: 45.0,
  //     backgroundImage: NetworkImage(baseProfileUrl + userDetails.userID +'/'+userDetails.profileImg),
  //     backgroundColor: Colors.transparent,
  //   );
  // }


  // Map() print
  static void getValuesFromMap(Map map) {
    // Get all values
    print('----------');
    print('Get values:');
    map.values.forEach((value) {
      print(value);
    });
  }
  static newShowSnackBar(String meg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(meg, textScaleFactor: 0.9), backgroundColor: Colors.blue));
  }

  static showToast(String msg, BuildContext context) {
    Toast.show(msg, context, duration: 2, gravity: Toast.BOTTOM);
  }

}

