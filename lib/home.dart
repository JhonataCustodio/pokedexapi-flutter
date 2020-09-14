import 'dart:async';
import 'dart:convert';

//import 'package:basic_utils/basic_utils.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:appteste/database_pokemon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class MyHomePage extends StatefulWidget {
  get data => this.data;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();

  String url = 'https://pokeapi.co/api/v2/pokemon/?limit=151';

  List data;
  Map post;
  bool isLoad = true;

  Future<String> makeRequest() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    setState(() {
      var extractData = json.decode(response.body);
      data = extractData["results"];
    });
  }

  @override
  void initState() {
    super.initState();
    makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Image.asset(
              "imagens/download.png",
              fit: BoxFit.fill,
              alignment: Alignment.topLeft,
              // width: 300,
            ),
            SizedBox(
              width: 20,
            )
          ],
          leading: Icon(
            Icons.account_box,
            color: Colors.blueGrey[200],
          ),
          title: Text(
            'Bem Vindo',
            style: TextStyle(
                color: Colors.blueGrey[200],
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          bottom: AppBar(
            actions: <Widget>[
              Text(
                'Pesquise e adicione seus pokemons favoritos',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.yellow[600],
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.yellow[600],
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Menu PokeAPI'),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                ),
              ),
              ListTile(
                title: Text('Pokemons favoritos'),
                leading: Icon(Icons.favorite),
                onTap: () {},
              ),
            ],
          ), // Populate the Drawer in the next step.
        ),
        body: Observer(builder: (_) {
          if (data == null) {
            return Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    "imagens/pokemon2.png",
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CircularProgressIndicator(
                    backgroundColor: Colors.red[300],
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            );
          } else if (data != null) {
            return Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  ColorizeAnimatedTextKit(
                    alignment: Alignment.centerRight,
                    repeatForever: true,
                    text: ["PokeAPI"],
                    textAlign: TextAlign.right,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      fontFamily: "Horizon",
                    ),
                    colors: [Colors.red[600], Colors.yellow[800]],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: data == null ? 0 : data.length,
                        itemBuilder: (BuildContext context, i) {
                          return ListTile(
                            leading: Image.asset(
                              "imagens/pokemon2.png",
                            ),
                            trailing: IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.red[500],
                                ),
                                onPressed: () {}),
                            title: Text(
                              data[i]["name"].toString().toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              data[i]["url"],
                              style: TextStyle(
                                  color: Colors.yellow[800],
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          SecondPage(data[i])));
                            },
                          );
                        }),
                  ),
                ],
              ),
            );
          }
        }));
  }
}

class SecondPage extends StatefulWidget {
  Map data;

  SecondPage(this.data);

  _SecondState createState() => _SecondState();
}

class _SecondState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Map post;
  bool isLoad = true;

  _fetchPost() async {
    setState(() {
      isLoad = true;
    });
    var url = widget.data["url"];
    debugPrint(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      post = json.decode(response.body.toString());
      setState(() {
        isLoad = false;
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Erro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data["name"])),
      body: _buildPokemon(context),
    );
  }

  Widget _buildPokemon(BuildContext context) {
    if (isLoad)
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.red[300],
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    return Container(
      color: Colors.yellow[600],
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.network(post['sprites']['front_default']),
                    SizedBox(
                      width: 20,
                    ),
                    ColorizeAnimatedTextKit(
                      alignment: Alignment.centerRight,
                      repeatForever: true,
                      text: [post['name']],
                      textAlign: TextAlign.right,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        fontFamily: "Horizon",
                      ),
                      colors: [Colors.red[600], Colors.blue[800]],
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Experiência base: ' +
                          post['base_experience'].toString().toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow[600]),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      post['weight'].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 18),
                    ),
                    Text(
                      post['height'].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
