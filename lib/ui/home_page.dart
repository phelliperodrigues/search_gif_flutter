import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giphys/ui/git_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future _getGifs() async{
    http.Response response;

    if(_search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=eK6IGKyajSeB8NmWFfl3LSHB8uzdcTme&limit=20&rating=G");
    else    
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=eK6IGKyajSeB8NmWFfl3LSHB8uzdcTme&q=$_search&limit=19&offset=$_offset&rating=G&lang=pt");
    
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGifs().then((map){
      print(map);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(children: <Widget>[
        Padding(padding: EdgeInsets.all(10.0),
          child:  TextField(
              decoration: InputDecoration(labelText: "Pesquise Aqui",
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder()),
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
              ),
        ),
           Expanded(
             child:FutureBuilder(
               future: _getGifs(),
               builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 15.0,
                      ),);
                  default:
                    if (snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                 } 
               },) ,)
      ],
      ),
      
    );
  }
  int _getCount(List data){
    if(_search == null || _search.isEmpty)
      return data.length;
    else 
      return data.length + 1;

  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
      return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount:_getCount(snapshot.data["data"]),
        itemBuilder: (context, index){
          if (_search == null || _search.isEmpty || index < snapshot.data["data"].length){
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])
                )
                );
              },
              onLongPress: (){
                              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);

              },
            ); 
          }else{
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.black, size: 70.0,),
                    Text("Carregar mais...",
                      style: TextStyle(color: Colors.black, fontSize: 22.0),)
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        },
      );
  }
}