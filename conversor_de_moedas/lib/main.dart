import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:io';

const request = "https://api.hgbrasil.com/finance?format=json&key=c901fcc8";
HttpClient httpClient = new HttpClient();

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
      ),
    ));
}

Future<Map> getData() async {
  var client = await HttpClient().getUrl(Uri.parse(request));
  var response = await client.close();

  String body = "";
  await for (var contents in response.transform(Utf8Decoder())) {
    body += contents;
  }
  return json.decode(body);
}

class Home extends StatefulWidget {


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro; 


  void _realChanged(String text)
  {
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text)
  {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text)
  {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return alertMessage("Carregando Dados...");
              default:
                if (snapshot.hasError)
                  return alertMessage("Erro ao carregar aos dados :(");
                else
                {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      fieldCurrency("Real", "R\$", realController, _realChanged),
                      Divider(),
                      fieldCurrency("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      fieldCurrency("Euros", "€", euroController, _euroChanged),
                    ]),
                  );
                }
            }
          }),
    );
  }
}

Center alertMessage(String message) {
  return Center(
    child: Text(
      message,
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      textAlign: TextAlign.center,
    ),
  );
}

TextField fieldCurrency(String name, String symbol, TextEditingController c, Function f)
{
  return TextField(
    decoration: InputDecoration(
      labelText: name,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: const BorderSide(color: Colors.amber, width: 1.0),
          ),
        prefixText: symbol 
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.number,
    controller: c,
  );
}