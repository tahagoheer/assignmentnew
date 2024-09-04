import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:internship_assignment5/Screens/item_details.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  List<dynamic> items = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadItemsFromLocalStorage();
  }

  void _showDetailsPopup(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item['title']),
          content: Text(item['body']),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Local Storage with SharedPreferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            const Text('Local Storage with SharedPreferences'),
                        content: const Text.rich(TextSpan(
                            text:
                                '\nTap a tile to see details on new page.\nLong press a tile to see details in Popup View.',
                            children: [
                              TextSpan(
                                text:
                                    '\nAPI Name: JSON PlaceHolder\nAPI Type: Posts\nAPI URI: https://jsonplaceholder.typicode.com/posts',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal),
                              )
                            ])),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              icon: const Icon(Icons.help_outline))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: Text(
                            items[index]['id'].toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onLongPress: () {
                            _showDetailsPopup(context, items[index]);
                          },
                          title: Text(
                            items[index]['title'],
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                          subtitle: Text('UserID: ${items[index]['userId']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsScreen(arguments: items[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _saveItemsToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(items);
    prefs.setString('itemsList', encodedData);
  }

  Future<void> _loadItemsFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('itemsList');

    if (encodedData != null) {
      setState(() {
        items = json.decode(encodedData);
        isLoading = false;
      });
    } else {
      fetchData(); // Fallback to API if no local data is found
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
        _saveItemsToLocalStorage(); // Save fetched data locally
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }
}
