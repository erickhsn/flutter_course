import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  
  int _offset = 0;

  final String _urlTrending = "https://api.giphy.com/v1/gifs/trending?api_key=MJmWwdd7gqaSb47Dt9dddqgATeGhYjwS&limit=20&rating=G";
  final String _urlSearch = "https://api.giphy.com/v1/gifs/search?api_key=MJmWwdd7gqaSb47Dt9dddqgATeGhYjwS&limit=20&rating=G&lang=en";

  Future<Map> _getGifs() async
  {    
    String body = "";
    String endpoint = _search == null ? _urlTrending : _urlSearch + "&q=$_search&offset=$_offset";

    var client = await HttpClient().getUrl(Uri.parse(_urlTrending));
    var response = await client.close();

    await for (var contents in response.transform(Utf8Decoder())) {
      body += contents;
    }
    
    return json.decode(body);
  }



  @override
  void initState() {
    super.initState();

    _getGifs().then((map)
    {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: buidBody(),
      
    );
  }

  Widget _buildLoaderAnimation()
  {
    return Container(
      width: 200.0,
      height: 200.0,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 5.0,
      ),
    );
  }

  Widget buidBody()
  {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Pesquise Aqui!",
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
              ),
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: FutureBuilder
          (
            future: _getGifs(),
            builder: (context, snapshot)
            {
              switch(snapshot.connectionState)
              {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return _buildLoaderAnimation();
                default:
                  if(snapshot.hasError)
                    return Container();
                  else
                    return _createGifTable(context, snapshot);
              }
            },
          ),
        )
      ],
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot)
  {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount: snapshot.data["data"].length,
      itemBuilder: (context, index)
      {
        return _buildImage(context, index, snapshot);
      },
    );
  } 

  Widget _buildImage(BuildContext context, int index, AsyncSnapshot snapshot)
  {
    return GestureDetector(
      child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
        height: 300.0,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,ImageChunkEvent loadingProgress) 
        {
          if (loadingProgress == null) return child;
          return _buildLoaderAnimation();
        },),
    );
  }

}