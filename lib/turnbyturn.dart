import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class TurnByTurnView extends StatefulWidget {
  TurnByTurnView({Key? key}) : super(key: key);

  @override
  State<TurnByTurnView> createState() => _TurnByTurnViewState();
}

class _TurnByTurnViewState extends State<TurnByTurnView> {
  bool? _arrived;

  String? _instruction;

  bool? _routeBuilt;

  bool? _isNavigating;

  bool? _isMultipleStop;

  late double _distanceRemaining;

  late double _durationRemaining;

  late MapBoxNavigation _directions;

  late MapBoxNavigationViewController _controller;

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop!) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
  }

  @override
  Widget build(BuildContext context) {
    final _options = MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        mapStyleUrlDay: "https://url_to_day_style",
        mapStyleUrlNight: "https://url_to_night_style",
        units: VoiceUnits.imperial,
        simulateRoute: true,
        language: "en");

    final cityhall =
        WayPoint(name: "City Hall", latitude: 42.886448, longitude: -78.878372);
    final downtown = WayPoint(
        name: "Downtown Buffalo", latitude: 42.8866177, longitude: -78.8814924);

    var wayPoints = [
      WayPoint(name: "City Hall", latitude: 42.886448, longitude: -78.878372),
      WayPoint(
          name: "Downtown Buffalo",
          latitude: 42.8866177,
          longitude: -78.8814924)
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(255, 223, 220, 220),
          child: SafeArea(
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      try {
                        await _directions.startNavigation(
                            wayPoints: wayPoints, options: _options);

                        print('anda');
                      } catch (e) {
                        print('soy error');
                        print(e.toString());
                      }
                      _controller.buildRoute(wayPoints: wayPoints);
                    },
                    child: const Text('turnbyturn')),
                SizedBox(
                  height: 500,
                  width: double.infinity,
                  child: Container(
                    color: Colors.grey,
                    child: MapBoxNavigationView(
                        options: _options,
                        onRouteEvent: _onRouteEvent,
                        onCreated:
                            (MapBoxNavigationViewController controller) async {
                          _controller = controller;
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
