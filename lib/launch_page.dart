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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Failed to load launches');
            } else if (snapshot.hasData) {
              final launches = snapshot.data!;
              return ListView.separated(
                itemCount: launches.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final launch = launches[index];
                  return ListTile(
                      title: Text(launch.missionName as String),
                      subtitle: Text(launch.description as String));
                },
              );
            } else {
              return const Text('No launches available');
            }
          },
        ),
      ),
    );
  }
}
