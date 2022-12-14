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
    File("/data/user/0/com.daviiid99.material_downloader/app_flutter/downloads.json").writeAsString(jsonString);

  }

   readJson() async {
    // Refresh json
    jsonString = await File("/data/user/0/com.daviiid99.material_downloader/app_flutter/downloads.json").readAsString();
    myDownloads = jsonDecode(jsonString);

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

  deleteFile(String file) async {
    // Delete file
    File("sdcard/download/$file").deleteSync();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Se ha borrado el siguiente archivo del dispositivo\n$file"),
    ));
  }

  cleanChoosedFile(String file) async {
    setState(() async {
      myDownloads.remove(file);
      writeJson();
      downloadsName = [];
      downloadsUrl = [];
      readJson();
      updateDownloadList();
    });
  }

  cleanDownloads() async {

    setState(() async {
      myDownloads = {};
      writeJson();
      downloadsName = [];
      downloadsUrl = [];
      readJson();
      updateDownloadList();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Se ha limpiado el historial de descargas"),
    ));
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
              child : Text("??ltimas Descargas", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),)
          ),
      if (downloadsName.length == 0) Image.asset("assets/icon/logo.png"),
          if (downloadsName.length == 0)Text("Aqu?? aparecer??n tus descargas", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),



          SizedBox(height: 40,),
      Expanded(
          child: RefreshIndicator(

         child : ListView.builder(
           key: UniqueKey(),
              itemCount: downloadsUrl.length,
              itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.black ,
                      textColor: Colors.white,
                      title: Text(downloadsName[index]),
                      subtitle: Text(downloadsUrl[index]),
                      leading: IconButton(
                        icon : Icon(Icons.cleaning_services_rounded, color: Colors.yellowAccent, ),
                        onPressed: (){
                          setState(() async {
                            cleanChoosedFile(downloadsName[index]);

                          });

                        },

                      ),
                      trailing: IconButton(
                        icon : Icon(Icons.delete_rounded, color: Colors.redAccent,),
                        onPressed: () {
                          setState(() async {
                            await myDownloads.remove(downloadsName[index]);
                            deleteFile(downloadsName[index]);
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
          ),
          onRefresh: () {// Read contacts agaim
    return Future.delayed(
    Duration(seconds: 1),
    () {
      setState(() async {
        cleanDownloads();
    });
         }
         );
    }
      ))]
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() async {
            Navigator.pop(context);

          });
        },
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