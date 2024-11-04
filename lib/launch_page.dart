import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:app_dev_mid_term/launch_model.dart';

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

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  LaunchBloc() : super(LaunchInitial()) {
    on<FetchLaunches>(_onFetchLaunches);
  }

  Future<void> _onFetchLaunches(
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
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LaunchBloc()..add(FetchLaunches()),
      child: const LaunchScreen(),
    );
  }
}

// Launch Screen
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

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
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: state.launches.length,
                itemBuilder: (context, index) {
                  final launch = state.launches[index];
                  return LaunchCard(launch: launch);
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

// Launch Card
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
                            style: const TextStyle(color: Colors.black)),
                        backgroundColor: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(150),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
