import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Web Scraping'),
        ),
        body: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<String>> fetchData() async {
    final response = await http.get(Uri.parse('https://www.liputan6.com/hot/read/4487363/18-cerita-lucu-pendek-yang-bikin-ngakak-sukses-ngocok-perut?page=2'));
    if (response.statusCode == 200) {
      return parseHtml(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<String> parseHtml(String responseBody) {
    final document = htmlParser.parse(responseBody);
    final List<String> titles = [];


    final judul = document.querySelectorAll('h2'); 
    for (final element in judul) {
      titles.add(element.text);
    }

    return titles;
    
  }
}
