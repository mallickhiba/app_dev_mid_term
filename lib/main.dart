// import 'package:flutter/material.dart';
// import 'package:app_dev_mid_term/launch_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
//         useMaterial3: true,
//       ),
//       home: const LaunchListState(),
//     );
//   }
// }
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:app_dev_mid_term/launch_model.dart';

// import 'home_page.dart';
// import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Launch>> fetchLaunches() async {
    final response =
        await http.get(Uri.parse("https://api.spacexdata.com/v3/missions"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Launch> productList = data.map((e) => Launch.fromJson(e)).toList();
      return productList;
    } else {
      throw Exception("Failed to get data");
    }
  }

  @override
  Widget build(BuildContext context) {
    // didnt wrap this with SafeArea because notification
    // bar looked black.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Space Missions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF016B6D),
      ),
      body: FutureBuilder(
        future: fetchLaunches(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Launch> launchList = snapshot.data!;
            return _launchCardList(launchList);
          } else {
            return loadingButton();
          }
        },
      ),
    );
  }

  Center loadingButton() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView _launchCardList(List<Launch> launchList) {
    return ListView.builder(
      itemCount: launchList.length,
      itemBuilder: (context, index) {
        Launch launch = launchList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          child: launchCard(launch: launch),
        );
      },
    );
  }
}

class launchCard extends StatefulWidget {
  const launchCard({
    super.key,
    required this.launch,
  });

  final Launch launch;

  @override
  State<launchCard> createState() => _launchCardState();
}

class _launchCardState extends State<launchCard> {
  bool showFull = false;

  void _toggleFull() {
    setState(() {
      showFull = !showFull;
      print("$showFull  ${widget.launch.missionName}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            launchCardName(),
            launchCardDesc(),
            launchCardShowButton(),
            Center(
              child: payLoadChipList(),
            )
          ],
        ),
      ),
    );
  }

  Align launchCardShowButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          backgroundColor:
              const WidgetStatePropertyAll<Color>(Color(0xFFdcdcdc)),
        ),
        onPressed: () {
          _toggleFull();
        },
        child: showFull
            ? const Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "Less",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_upward,
                  color: Colors.blue,
                )
              ])
            : const Row(mainAxisSize: MainAxisSize.min, children: [
                Text("More",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
                Icon(
                  Icons.arrow_downward,
                  color: Colors.blue,
                )
              ]),
      ),
    );
  }

  Padding launchCardDesc() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Text(widget.launch.description!,
          maxLines: showFull ? null : 1,
          overflow: showFull ? null : TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          )),
    );
  }

  Text launchCardName() {
    return Text(
      widget.launch.missionName!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 24,
      ),
    );
  }

  Wrap payLoadChipList() {
    return Wrap(
      children: widget.launch.payloadIds!
          .map(
            (payload) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: payloadChip(payload),
            ),
          )
          .toList(),
    );
  }

  Chip payloadChip(String e) {
    return Chip(
      label: Text(e),
      backgroundColor:
          Colors.primaries[Random().nextInt(Colors.primaries.length)],
    );
  }
}
