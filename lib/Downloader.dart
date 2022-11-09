import 'dart:convert';
import 'dart:ffi';
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
  List<String> currentDownloadProgress = [];
  int currentDownloadIndex = 0;
  String filename = "";
  String extension = "";
  bool smartDownload = false;
  bool semiSmartDownload = false;


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
      if (downloadsName.contains(key) == false){
        // Add file URL + filename to lists
        downloadsUrl.add(myDownloads[key]);
        downloadsName.add(key);
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

   getFileName(String url) {
    // Content after last '/' element
    filename = url.split("/").last;
    var splitted = filename.characters;
    var finalFilename = "";

    for (String c in splitted){
      if (c.contains(".") == false ){
        finalFilename +=c;
      } else {
        this.filename = finalFilename;
      }

    }
    print("Nombre final del archivo : $filename");
}

  checkDownloadType(String file, String extension) async{
     if (file.length == 0 && extension.length == 0){
         this.smartDownload = true;
     } else if (file.length > 0 && extension.length == 0){
       semiSmartDownload = true;
     }

     return this.smartDownload;
  }

 getFileExtension(String url){
     // Content after last "." element
   this.extension = url.split(".").last;
   this.extension = "." + this.extension;
   print("EXTENSION : $extension");
}

   downloadFile(String myUrl, String filename, String extension, int index) async {
     // Download provided file
     bool completed = false;

     _permissionReady = await _checkPermission();

     if (_permissionReady) {
       await _prepareSaveDir();
       try {
         await Dio().download(myUrl, _localPath + "/" + filename + extension ,
             onReceiveProgress: (received, total) {
           setState(() async {
             currentDownloadProgress[index] = ((received / total) * 100).toStringAsFixed(0) + "%";

             if (((received / total) * 100) == 100) {
               // Clean completed file download
               completed = true;

               // Notify the user
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                 content: Text("Se ha descargado el archivo\n$filename$extension"),
               ));
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

                setState(() async {
                  // Checking download type
                  await checkDownloadType(myFileName.text, myExtension.text);

                  // Smart Download
                  // User just enter the URL and the filename and extension is fetch from the url
                  // This can lead into an error in some cases

                  if (await checkDownloadType(myFileName.text, myExtension.text) == true){
                    await getFileName(myUrl.text);
                    await getFileExtension(myUrl.text);
                    writeJson(filename + extension, myUrl.text); // Add new value to map
                    readJson(); // Read udpated map
                    updateDownloadList(); // Update lists
                    currentDownloadUrl.add(myUrl.text);
                    currentDownloadName.add(filename + extension);
                    currentDownloadProgress.add("0");
                    currentDownloadIndex = currentDownloadName.length - 1;
                    await downloadFile(myUrl.text, filename, extension, currentDownloadIndex);
                    // Erase text input values
                    myFileName.text = "";
                    myExtension.text = "";
                    myUrl.text = "";
                    filename = "";
                    extension = "";
                    smartDownload = false;
                  } else if ((await checkDownloadType(myFileName.text, myExtension.text) == false && semiSmartDownload == true )){
                    // Semi Smart Download
                    // User enter the url and name but not the extension
                    // In this case we will try to catch the extension

                    await getFileExtension(myUrl.text);
                    writeJson(myFileName.text + extension, myUrl.text);
                    readJson();
                    updateDownloadList();
                    currentDownloadUrl.add(myUrl.text);
                    currentDownloadName.add(myFileName.text + extension);
                    currentDownloadProgress.add("0");
                    currentDownloadIndex = currentDownloadName.length - 1;
                    await downloadFile(myUrl.text, myFileName.text, extension, currentDownloadIndex);
                    // Erase text input values
                    myFileName.text = "";
                    myExtension.text = "";
                    myUrl.text = "";

                  } else {

                    writeJson(myFileName.text + "." + myExtension.text, myUrl.text); // Add new value to map
                    readJson(); // Read udpated map
                    updateDownloadList(); // Update lists
                    currentDownloadUrl.add(myUrl.text);
                    currentDownloadName.add(myFileName.text + "." + myExtension.text);
                    currentDownloadProgress.add("0");
                    currentDownloadIndex = currentDownloadName.length - 1;
                    await downloadFile(myUrl.text, myFileName.text,  "." + myExtension.text, currentDownloadIndex);

                    // Erase text input values
                    myFileName.text = "";
                    myExtension.text = "";
                    myUrl.text = "";
                  }

                });

            },
          ),

          SizedBox(height: 30),

          if (currentDownloadUrl.length == 0)
            Stack(
            children: [
            Container(
            child: SingleChildScrollView(
                child: Align(
                    alignment: Alignment.center,
                    child: Column (
                    children: [
                      Text("Cómo descargar un archivo", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),
                      SizedBox(height: 15,),
                      Text("1.- Introduce una URL (Obligatorio)", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.normal,), textAlign: TextAlign.left,),
                      Text("2.- Introduce un nombre para el archivo (Opcional)", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.normal), textAlign: TextAlign.left,),
                      Text("3.- Introduce una extensión (Opcional)", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.normal), textAlign: TextAlign.left,),
                      Text("4.- Haz click en Descargar y espera ;)", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.normal), textAlign: TextAlign.left,),
                  ],
                )
                    )
            ))])
            ,
          if (currentDownloadUrl.length > 0)
          Text("Descargas Actuales", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),),

          SizedBox(height: 10),

          Expanded(
          child: RefreshIndicator(
            child: ListView.builder(
            itemCount: currentDownloadUrl.length,
            itemBuilder: (context, index) {
              return ListTile(
              tileColor: Colors.black ,
              textColor: Colors.white,
              title: Text(currentDownloadName[index]),
              subtitle: Text(currentDownloadUrl[index] + "\n" + currentDownloadProgress[index]),
              leading: Icon(Icons.file_download_rounded, color: Colors.blueAccent,),

              onTap: () {


                },

                );
            }
          ),
                onRefresh: () {// Read contacts agaim
                  return Future.delayed(
                    Duration(seconds: 1),
                    () {
                    setState(() async {
                      updateDownloadList();
                      readJson();
                      currentDownloadUrl = [];
                      currentDownloadName = [];
                      currentDownloadProgress = [];
                      currentDownloadIndex = 0;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Se ha limpiado el historial de decsrgas"),
                      ));
                    });
                    }
                  );
                  }
          ),

          )],
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