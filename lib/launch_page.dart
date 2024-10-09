import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_dev_mid_term/launch_model.dart';
import 'package:http/http.dart' as http;

class LaunchListState extends StatefulWidget {
  const LaunchListState({super.key});

  @override
  State<LaunchListState> createState() => _LaunchListState();
}

class _LaunchListState extends State<LaunchListState> {
  List<Launch> launches = [];

  Future<List<Launch>> fetchAllLaunches() async {
    final response =
        await http.get(Uri.parse('https://api.spacexdata.com/v3/missions'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((launch) => Launch.fromJson(launch)).toList();
    } else {
      throw Exception('Failed to load launches');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Space Missions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF016B6D),
      ),
      body: Center(
        child: FutureBuilder<List<Launch>>(
          future: fetchAllLaunches(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final launches = snapshot.data!;
              return ListView.builder(
                  itemCount: launches.length,
                  itemBuilder: (context, index) {
                    Launch launch = launches[index];
                    return LaunchCard(launch: launch);
                  });
            } else if (snapshot.hasError) {
              return const Text('Failed to load launches');
            } else {
              // return const Text('No launches available');
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class LaunchCard extends StatefulWidget {
  const LaunchCard({
    super.key,
    required this.launch,
  });

  final Launch launch;

  @override
  State<LaunchCard> createState() => LaunchCardState();
}

class LaunchCardState extends State<LaunchCard> {
  bool showFull = false;

  void _toggleFull() {
    setState(() {
      showFull = !showFull;
      // print("$showFull  ${widget.launch.missionName}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.launch.missionName ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(widget.launch.description ?? ''),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      backgroundColor: const WidgetStatePropertyAll<Color>(
                          Color(0xFFdcdcdc)),
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
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: ListView.builder(
                //     itemCount: widget.launch.payloadIds?.length,
                //     itemBuilder: (context, index) {
                //       String payloadId = widget.launch.payloadIds![index];
                //       return Chip(
                //         label: Text(payloadId),
                //       );
                //     },
                //   ),
                // ),
              ]),
        ));
  }
}
