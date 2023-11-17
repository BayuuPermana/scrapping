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
          title: Text('Web Scraping with Flutter'),
        ),
        body: WebScrapingWidget(),
      ),
    );
  }
}

class WebScrapingWidget extends StatefulWidget {
  @override
  _WebScrapingWidgetState createState() => _WebScrapingWidgetState();
}

class _WebScrapingWidgetState extends State<WebScrapingWidget> {
  List<String> titles = [];
  String selectedTitle = '';
  String selectedDetail = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await fetchData();
                  },
                  child: Text('Fetch Data'),
                ),
                if (titles.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: titles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(titles[index]),
                          onTap: () {
                            setState(() {
                              selectedTitle = titles[index];
                              selectedDetail = ''; 
                            });
                          },
                          selected: titles[index] == selectedTitle,
                          tileColor: titles[index] == selectedTitle
                              ? Colors.blue.withOpacity(0.2)
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedTitle.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      await fetchDetail(selectedTitle);
                    },
                    child: Text('Show Detail'),
                  ),
                if (selectedDetail.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          selectedDetail,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://www.liputan6.com/hot/read/4487363/18-cerita-lucu-pendek-yang-bikin-ngakak-sukses-ngocok-perut?page=2'));
    if (response.statusCode == 200) {
      setState(() {
        titles = parseTitles(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<String> parseTitles(String responseBody) {
    final document = htmlParser.parse(responseBody);
    final List<String> extractedTitles = [];

    final elements = document.querySelectorAll('h2');
    for (final element in elements) {
      extractedTitles.add(element.text);
    }

    return extractedTitles;
  }

  Future<void> fetchDetail(String title) async {
    final response = await http.get(Uri.parse('https://www.liputan6.com/hot/read/4487363/18-cerita-lucu-pendek-yang-bikin-ngakak-sukses-ngocok-perut?page=2'));
    if (response.statusCode == 200) {
      setState(() {
        selectedDetail = parseDetail(response.body, title);
      });
    } else {
      throw Exception('Failed to load detail');
    }
  }

  // ...

String parseDetail(String responseBody, String title) {
  final document = htmlParser.parse(responseBody);
  final elements = document.querySelectorAll('h2');

  bool foundTitle = false;
  StringBuffer detailBuffer = StringBuffer();

  for (final element in elements) {
    if (element.text == title) {
      foundTitle = true;
      var nextElements = element.nextElementSibling;
      while (nextElements != null && nextElements.localName != 'h2') {
        if (nextElements.localName == 'p') {
          detailBuffer.write(nextElements.text);
          detailBuffer.write('\n\n'); 
        }
        nextElements = nextElements.nextElementSibling;
      }
      break;
    }
  }

  return foundTitle ? detailBuffer.toString() : 'Detail not found';
}

// ...

}
