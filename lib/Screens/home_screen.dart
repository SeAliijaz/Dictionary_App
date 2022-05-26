import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final String url = "https://owlbot.info/api/v4/dictionary/";
  final String token = "51c527ca48809a1f4c060ae51aa2097d2c8102a1";

  StreamController? streamController;
  Stream? _stream;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    streamController = StreamController();
    _stream = streamController!.stream;
  }

  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary',
          style: GoogleFonts.salsa(
            textStyle: const TextStyle(
              fontSize: 25,
            ),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3.5,
                    vertical: 7,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(24.5),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: TextFormField(
                        onChanged: (String text) {
                          if (_timer?.isActive ?? false) _timer!.cancel();
                          _timer =
                              Timer(const Duration(milliseconds: 1000), () {
                            searchText();
                          });
                        },
                        controller: textEditingController,
                        decoration: const InputDecoration(
                          hintText: "Search for a word",
                          contentPadding: EdgeInsets.only(left: 25.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                  border: Border.all(),
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      searchText();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        height: s.height,
        width: s.width,
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  "Nothing Found! \nEnter a word to search",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.salsa(
                    textStyle: const TextStyle(
                      fontSize: 20.5,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }
            if (snapshot.data == "Waiting" || snapshot.data == "waiting") {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            ///Getting data from API
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Container(
                        child: Center(
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              snapshot.data["definitions"][index]
                                          ["image_url"] ==
                                      null
                                  ? null
                                  : snapshot.data["definitions"][index]
                                      ["image_url"],
                            ),
                            radius: 100,
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      tileColor: Colors.grey[200],
                      title: SelectableText(
                        textEditingController.text.trim() +
                            "(" +
                            snapshot.data["definitions"][index]["type"] +
                            ")",
                      ),
                    ),
                    Divider(),
                    ListTile(
                      tileColor: Colors.grey[200],
                      title: SelectableText(
                        snapshot.data["definitions"][index]["definition"] ==
                                null
                            ? Text(
                                "Nothing Found!",
                                style: GoogleFonts.salsa(
                                  textStyle: const TextStyle(
                                    fontSize: 20.5,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : snapshot.data["definitions"][index]["definition"],
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  searchText() async {
    if (textEditingController.text == null ||
        textEditingController.text.length == 0) {
      streamController!.add(null);
      return;
    }
    streamController?.add("waiting");
    http.Response response = await http.get(
      Uri.parse(
        url + textEditingController.text.trim(),
      ),
      headers: {"Authorization": "Token " + token},
    );
    streamController?.add(
      json.decode(response.body),
    );
  }
}
