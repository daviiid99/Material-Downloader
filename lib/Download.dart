import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'Downloader.dart';


class Download extends StatefulWidget{
  @override
  List<String> downloadsName = [];
  List<String> downloadsUrl = [];
  Map<dynamic, dynamic> myDownloads = {};
  Download(this.downloadsName, this.downloadsUrl, this.myDownloads);
  _DownloadState createState() => _DownloadState(downloadsName, downloadsUrl, myDownloads);

}

class _DownloadState extends State<Download>{

  List<String> downloadsName = [];
  List<String> downloadsUrl = [];
  String jsonString = "";
  Map<dynamic, dynamic> myDownloads = {};
  _DownloadState(this.downloadsName, this.downloadsUrl, this.myDownloads);

  void writeJson() async {
    // Write a value to the map
    jsonString = jsonEncode(myDownloads);
    File("/data/user/0/com.example.material_downloader/app_flutter/downloads.json").writeAsString(jsonString);

  }

   readJson() async {
    // Refresh json
    jsonString = await File("/data/user/0/com.example.material_downloader/app_flutter/downloads.json").readAsString();
    myDownloads = jsonDecode(jsonString);

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

  @override
  void initState(){
    downloadsName = [];
    downloadsUrl = [];
    readJson();
    updateDownloadList();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
      body : Column(
        children: [
          SizedBox(height: 50,),
          Align(
            alignment: Alignment.center,
              child : Text("Últimas Descargas", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),)
          ),
      SizedBox(height: 40,),
      Expanded(
         child : ListView.builder(
           key: UniqueKey(),
              itemCount: downloadsUrl.length,
              itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.black ,
                      textColor: Colors.white,
                      title: Text(downloadsName[index]),
                      subtitle: Text(downloadsUrl[index]),
                      leading: Icon(Icons.file_download_rounded, color: Colors.blueAccent,),
                      trailing: IconButton(
                        icon : Icon(Icons.delete_rounded, color: Colors.redAccent,),
                        onPressed: () {
                          setState(() async {
                            await myDownloads.remove(downloadsUrl[index]);
                            downloadsName.remove(index);
                            downloadsUrl.remove(index);
                            writeJson();
                            downloadsName = [];
                            downloadsUrl = [];
                            readJson();
                            updateDownloadList();
                          });

                      },
                      ),
                      onTap: () {
                        OpenFile.open('sdcard/download/' + downloadsName[index]);
                      },

                    );
              }
          )
      ),
      ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
              label: "",
              icon: IconButton(
                icon: Icon(Icons.download_rounded, color: Colors.white,),
                onPressed: () {
                  Navigator.pop(context);
                  },
              )),
        ],
      ),
    );
  }
}