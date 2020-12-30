import 'package:flutter/material.dart';
import 'package:PlatiQ/widgets/colors.dart';

circularProgress(context) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(mainColor),
      backgroundColor: Colors.grey,
    ),
  );
}

linearProgress(context) {
  return Container(
    //padding: EdgeInsets.only(bottom: 10.0),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(50)),
    child: LinearProgressIndicator(
      minHeight: 8,
      valueColor: AlwaysStoppedAnimation(mainColor),
      backgroundColor: Colors.grey[400],
    ),
  );
}

header(title, color) {
  return AppBar(
    backgroundColor: color,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'Signatra',
        fontWeight: FontWeight.w600,
        fontSize: 35.0,
      ),
    ),
  );
}
