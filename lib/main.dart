import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;

const List<String> list = <String>['username', 'phone', 'city', 'job', 'work'];

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List? users;
  bool loading = true;
  String query = '';
  String dropDownValue = list.first;

  Future<void> search(String query) async {
    if (query.isNotEmpty) {
      final filteredUsers = users?.where((user) =>
          user['options'].toLowerCase().contains(query.toLowerCase()));
      setState(() => users = filteredUsers?.toList());
    } else {
      await getUsers();
    }
  }

  Future<String> getUsers({options = ''}) async {
    setState(() => loading = true);
    var httpsUri = Uri(
        scheme: 'http',
        host: '192.168.1.109',
        port: 8000,
        path: '/showusers',
        query: '$dropDownValue=$options');

    var response = await http.get(httpsUri);

    setState(() => users = json.decode(response.body.toString()));

    setState(() => loading = false);
    return 'success';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  List<TableRow> myList() {
    List<TableRow> res = [];
    for (var index = 0; index < users!.length; index++) {
      var name = users?[index]['user']['contacts']['first_name'];
      var lastname = users?[index]['user']['contacts']['last_name'];
      var fullname = '$name $lastname';
      var phonenumber = users?[index]['user']['contacts']['phone_number'];
      var city = users?[index]['user']['contacts']['city'];
      var job = users?[index]['user']['special']['careerobjective'];
      var work = users?[index]['user']['study']['level'];
      work = work ?? '';

      res.add(TableRow(children: [
        Column(children: [Text(fullname)]),
        Column(children: [Text(phonenumber)]),
        Column(children: [Text(city)]),
        Column(children: [Text(job)]),
        Column(children: [Text(work)]),
      ]));
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API'),
      ),
      body: Column(
        children: <Widget>[
          loading
              ? const Align(
                  alignment: Alignment.center,
                  heightFactor: 12.0,
                  child: CircularProgressIndicator(),
                )
              : Container(
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                          width: 500,
                          child: TextField(
                            onSubmitted: (value) => getUsers(options: value),
                          )),
                      DropdownButton(
                        value: dropDownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            dropDownValue = value!;
                          });
                        },
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
          const SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Table(
                  defaultColumnWidth: const FixedColumnWidth(120.0),
                  border: TableBorder.all(
                      color: Colors.black, style: BorderStyle.solid, width: 2),
                  children: [
                    TableRow(children: [
                      _buildTableHeader('Name'),
                      _buildTableHeader('Phone'),
                      _buildTableHeader('City'),
                      _buildTableHeader('Job'),
                      _buildTableHeader('Work'),
                    ]),
                    ...myList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
