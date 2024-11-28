import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: WeatherHome(),
    debugShowCheckedModeBanner: false,
  ));
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController cityController = TextEditingController();
  String _result = "Informe o nome da cidade";
  bool _isLoading = false;

  final String _apiKey = "d1ee36558f8c17622043ef7517479e48";
  final String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  void _reset() {
    cityController.text = "";
    setState(() {
      _result = "Informe o nome da cidade";
      _formKey = GlobalKey<FormState>();
    });
  }

  Future<void> _fetchWeather() async {
    if (cityController.text.isEmpty) {
      setState(() {
        _result = "Por favor, insira o nome de uma cidade.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = "Carregando...";
    });

    try {
      final response = await http.get(Uri.parse(
          "$_baseUrl?q=${cityController.text}&appid=$_apiKey&lang=pt_br&units=metric"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _result =
              "Cidade: ${data['name']}\nTemperatura: ${data['main']['temp']}°C\n"
              "Descrição: ${data['weather'][0]['description']}";
        });
      } else {
        setState(() {
          _result = "Cidade não encontrada.";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Erro ao buscar dados do tempo.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Previsão do Tempo",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.cloud,
                size: 120.0,
                color: Colors.blue,
              ),
              TextFormField(
                controller: cityController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome da Cidade",
                  labelStyle: TextStyle(color: Colors.blue),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 25.0),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insira o nome da cidade!";
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Container(
                  height: 50.0,
                  child: ElevatedButton(
                    child: Text(
                      "Buscar",
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _fetchWeather();
                      }
                    },
                  ),
                ),
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              SizedBox(height: 20),
              Text(
                _result,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
