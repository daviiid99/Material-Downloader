import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';


class Download extends StatefulWidget{
  @override
  List<String> downloadsName = [];
  List<String> downloadsUrl = [];
  Download(this.downloadsName, this.downloadsUrl);
  _DownloadState createState() => _DownloadState(downloadsName, downloadsUrl);
}

class _DownloadState extends State<Download>{

  List<String> downloadsName = [];
  List<String> downloadsUrl = [];
  _DownloadState(this.downloadsName, this.downloadsUrl);

  @override
  void initState(){
    print(" --- MAPAS ---");
    print(downloadsName);
    print(downloadsUrl);
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
              itemCount: downloadsUrl.length,
              itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.black ,
                      textColor: Colors.white,
                      title: Text(downloadsName[index]),
                      subtitle: Text(downloadsUrl[index]),
                      leading: Icon(Icons.file_download_rounded, color: Colors.blueAccent,),
                      trailing: Icon(Icons.delete_rounded, color: Colors.redAccent,),
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