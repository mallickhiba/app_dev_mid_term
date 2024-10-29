// ignore_for_file: prefer_collection_literals, unnecessary_this, unnecessary_new

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Launch Model
class Launch {
  String? missionName;
  String? missionId;
  List<String>? manufacturers;
  List<String>? payloadIds;
  String? wikipedia;
  String? website;
  String? twitter;
  String? description;

  Launch({
    this.missionName,
    this.missionId,
    this.manufacturers,
    this.payloadIds,
    this.wikipedia,
    this.website,
    this.twitter,
    this.description,
  });

  Launch.fromJson(Map<String, dynamic> json) {
    missionName = json['mission_name'];
    missionId = json['mission_id'];
    manufacturers = json['manufacturers']?.cast<String>();
    payloadIds = json['payload_ids']?.cast<String>();
    wikipedia = json['wikipedia'];
    website = json['website'];
    twitter = json['twitter'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['mission_name'] = this.missionName;
    data['mission_id'] = this.missionId;
    data['manufacturers'] = this.manufacturers;
    data['payload_ids'] = this.payloadIds;
    data['wikipedia'] = this.wikipedia;
    data['website'] = this.website;
    data['twitter'] = this.twitter;
    data['description'] = this.description;
    return data;
  }
}

// BLoC Events and States
abstract class LaunchEvent {}

class FetchLaunches extends LaunchEvent {}

abstract class LaunchState {}

class LaunchInitial extends LaunchState {}

class LaunchLoading extends LaunchState {}

class LaunchLoaded extends LaunchState {
  final List<Launch> launches;
  LaunchLoaded(this.launches);
}

class LaunchError extends LaunchState {
  final String error;
  LaunchError(this.error);
}

// Launch BLoC
class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  LaunchBloc() : super(LaunchInitial()) {
    on<FetchLaunches>(_onFetchLaunches);
  }

  FutureOr<void> _onFetchLaunches(
      FetchLaunches event, Emitter<LaunchState> emit) async {
    emit(LaunchLoading());
    try {
      final response =
          await http.get(Uri.parse('https://api.spacexdata.com/v3/missions'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final launches = (data as List)
            .map((launchJson) => Launch.fromJson(launchJson))
            .toList();
        emit(LaunchLoaded(launches));
      } else {
        emit(LaunchError('Failed to load launches'));
      }
    } catch (e) {
      emit(LaunchError('Error: $e'));
    }
  }
}

// Launch Page
class LaunchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Missions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(),
        useMaterial3: false,
      ),
      home: BlocProvider(
        create: (context) => LaunchBloc()..add(FetchLaunches()),
        child: LaunchScreen(),
      ),
    );
  }
}

// Launch Screen
class LaunchScreen extends StatelessWidget {
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
      body: BlocBuilder<LaunchBloc, LaunchState>(
        builder: (context, state) {
          if (state is LaunchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LaunchLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: state.launches.length,
                itemBuilder: (context, index) {
                  final launch = state.launches[index];
                  return ListTile(
                    title: Text(launch.missionName.toString()),
                    subtitle: Text(launch.description.toString()),
                  );
                },
              ),
            );
          } else if (state is LaunchError) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}
