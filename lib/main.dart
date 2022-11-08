import 'package:flutter/material.dart';
import 'Downloader.dart';

void main() => runApp(MyDownloader());

class MyDownloader extends StatelessWidget{

  final String title = "Material Downloader";

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: title,
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFFEFEFEF)),
      home: Downloader(),
    );
  }
}