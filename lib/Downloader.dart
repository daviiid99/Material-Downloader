import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Download.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';


class Downloader extends StatefulWidget{
  @override
  _DownloaderState createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader>{

  final myUrl = TextEditingController();
  final myFileName = TextEditingController();
  final myExtension = TextEditingController();
  late TargetPlatform? platform;
  late bool _permissionReady;
  late String _localPath;
  Map<dynamic, dynamic> myDownloads = {};
  String jsonString = "";
  String jsonPath = "";
  List<String> downloadsName = [];
  List<String> downloadsUrl = [];
  String progress = "";
  List<String> currentDownloadName = [];
  List<String> currentDownloadUrl = [];


   readJson() async {
    // Load the directory
    final directory = Directory("/data/user/0/com.daviiid99.material_downloader/app_flutter");
    final path = directory.path;

    final filePath = File(directory.path + "/downloads.json");
    final fileExists = await filePath.exists();

    if (fileExists) {
      // Get the path
      print("JSON PATH : " + path);

      // Set the json map
      final jsonPath = "$path/downloads.json";

      jsonString = await File(jsonPath).readAsString();
      myDownloads = jsonDecode(jsonString);
      print("MAP OBJECT : $myDownloads");

      // Check if the file exists
    } else {
      jsonString = jsonEncode(myDownloads);
      File(path + "/downloads.json").writeAsString(jsonString);

    }

    return 0;
  }

   updateDownloadList() async {
    // Add downloads to list
    for (String key in myDownloads.keys){
      if (downloadsUrl.contains(key) == false){
        // Add file URL + filename to lists
        downloadsUrl.add(key);
        downloadsName.add(myDownloads[key]);
      }
    }
    return 0;

   }

  void writeJson(String key, dynamic value) async {
    // Write a value to the map
    Map<String, dynamic> tempMap = { key : value};
    myDownloads.addAll(tempMap);
    jsonString = jsonEncode(myDownloads);
    File("/data/user/0/com.daviiid99.material_downloader/app_flutter/downloads.json").writeAsString(jsonString);
    print("UPDATED MAP " + jsonString);

  }


  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<String> _findLocalPath() async {
    return "/sdcard/download/";
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  void _read() async {
    try {
      await Dio().download("https://raw.githubusercontent.com/daviiid99/Material_Dialer/master/version.txt",
          '/sdcard/download/' + "/" + "version.txt");
      File file = File('/sdcard/download/version.txt');
      var res  = await file.readAsString();

      setState(() {

      });

    } catch (e) {
      print("Couldn't read file");
    }


  }

  void downloadFile(String myUrl, String filename, String extension) async {
     // Download provided file
     bool completed = false;

     _permissionReady = await _checkPermission();

     if (_permissionReady) {
       await _prepareSaveDir();
       try {
         await Dio().download(myUrl, _localPath + "/" + filename + "." + extension ,
             onReceiveProgress: (received, total) {
           setState(() async {
             progress = ((received / total) * 100).toStringAsFixed(0) + "%";

             if (((received / total) * 100) == 100) {
               completed = true;
             }
               });
           });
       } catch (e) {
       }
     } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text("Algo fue mal..."),
       ));
     }
     }

     @override
     void initState() async{

      // Read json to restore default values

    setState(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
      if (Platform.isAndroid) {
        platform = TargetPlatform.android;
      } else {
        platform = TargetPlatform.iOS;
      }
    });
    super.initState();
     }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.black,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Material Downloader", textAlign: TextAlign.center,)
                ]
            )
        ),
      body: Column(
        children: [

          SizedBox(height: 40,),
          Text("Gestor de Descargas", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
          SizedBox(height: 30,),

          Stack(
            alignment: Alignment.center,
          children: [
          ]
          ),

          SizedBox(height: 10,),
          TextFormField(
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blueAccent, width: 2.0),
                ),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blueAccent, width: 2.0),
                ),
                border: OutlineInputBorder(
                ),

                label:Center(child: Text('Dirección URL')),
                labelStyle: TextStyle(
                    color: Colors.white
                )

            ),
            controller: myUrl,
          ),

          SizedBox(height: 10,),

          TextFormField(
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blueAccent, width: 2.0),
                ),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blueAccent, width: 2.0),
                ),
                border: OutlineInputBorder(
                ),

                label: Center(child: Text('Nombre del archivo')),
                labelStyle: TextStyle(
                    color: Colors.white
                )

            ),
            controller: myFileName,
          ),

          SizedBox(height: 10,),

          TextFormField(
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blueAccent, width: 2.0),
                ),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blueAccent, width: 2.0),
                ),
                border: OutlineInputBorder(
                ),

                label:Center(child: Text('Extensión')),
                labelStyle: TextStyle(
                    color: Colors.white
                )

            ),
            controller: myExtension,
          ),
          
          SizedBox(height: 10,),
          ElevatedButton(
              child: Text("Descargar"),
            onPressed: () async {

                setState(() {
                  writeJson(myUrl.text, myFileName.text+"."+myExtension.text); // Add new value to map
                  readJson(); // Read udpated map
                  updateDownloadList(); // Update lists
                  currentDownloadUrl.add(myUrl.text);
                  currentDownloadName.add(myFileName.text+"."+myExtension.text);

                });

              downloadFile(myUrl.text, myFileName.text, myExtension.text);

              // Erase text input values
              myUrl.text = "";
              myFileName.text = "";
              myExtension.text = "";
            },
          ),

          SizedBox(height: 30),

          if (currentDownloadUrl.length > 0)
          Text("Descargas Actuales", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),

          SizedBox(height: 10),

          Expanded(
          child : ListView.builder(
            itemCount: currentDownloadUrl.length,
            itemBuilder: (context, index) {
              return ListTile(
              tileColor: Colors.black ,
              textColor: Colors.white,
              title: Text(currentDownloadName[index]),
              subtitle: Text(currentDownloadUrl[index] + "\n" + progress),
              leading: Icon(Icons.file_download_rounded, color: Colors.blueAccent,),
                trailing: IconButton(
                  icon : Icon(Icons.delete_rounded, color: Colors.redAccent,), onPressed: () {
                    setState(() {
                      myDownloads.remove(currentDownloadUrl[index]);
                      updateDownloadList();
                      readJson();
                      currentDownloadUrl.remove(currentDownloadUrl[index]);
                      currentDownloadName.remove(currentDownloadName[index]);
                    });

                },
                ),
              onTap: () {


                },

                );
            }
          )
          ),

        ],
      ),
        bottomNavigationBar : BottomNavigationBar(
          onTap: (index) {
            setState(() async {
              readJson();
              updateDownloadList();
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Download(downloadsName, downloadsUrl, myDownloads))
              );
            });
          },
          backgroundColor: Colors.blueAccent,
    items: <BottomNavigationBarItem>[

    BottomNavigationBarItem(
      label: "",
      icon: IconButton(
        icon: Icon(Icons.download_done_rounded, color: Colors.white,),
        onPressed: (){

          setState(() async {
            readJson();
            updateDownloadList();
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Download(downloadsName, downloadsUrl, myDownloads))
            );
          });

        },
    )
    ),

    ],
    )
    );
  }
}