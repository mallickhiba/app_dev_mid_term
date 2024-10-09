import 'dart:convert';
import 'dart:math';
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
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
        ));
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
  bool showMore = false;

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
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.launch.description ?? '',
                  textAlign: TextAlign.center,
                  maxLines: showMore ? 100 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Color(0xFFdcdcdc)),
                    ),
                    onPressed: () {
                      setState(() {
                        showMore = !showMore;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showMore ? "Less" : "More",
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          showMore ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  children: widget.launch.payloadIds!
                      .map(
                        (payload) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Chip(
                                label: Text(payload,
                                    style:
                                        const TextStyle(color: Colors.black)),
                                backgroundColor: Colors.primaries[
                                    Random().nextInt(Colors.primaries.length)],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(150)))),
                      )
                      .toList(),
                )
              ]),
        ));
  }
}
