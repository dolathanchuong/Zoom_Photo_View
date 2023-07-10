import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photo_view_editor/photo_view.dart';
import 'package:photo_view_editor/screens/common/app_bar.dart';

class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ControllerExampleState createState() => _ControllerExampleState();
}

var logger = Logger();
const double min = pi * -2;
const double max = pi * 2;

const double minScale = 0.03;
const double defScale = 0.1;
const double maxScale = 0.6;

class _ControllerExampleState extends State<ControllerExample> {
  late PhotoViewControllerBase controller;
  late PhotoViewScaleStateController scaleStateController;

  int calls = 0;

  @override
  void initState() {
    controller = PhotoViewController(initialScale: defScale)
      ..outputStateStream.listen(onController);

    scaleStateController = PhotoViewScaleStateController()
      ..outputScaleStateStream.listen(onScaleState);
    super.initState();
  }

  void onController(PhotoViewControllerValue value) {
    setState(() {
      calls += 1;
    });
  }

  void onScaleState(PhotoViewScaleState scaleState) {
    logger.d(scaleState);
  }

  @override
  void dispose() {
    controller.dispose();
    scaleStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleAppBarLayout(
      title: "Controller",
      showGoBack: true,
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PhotoView(
                imageProvider: const AssetImage("assets/large-image.jpg"),
                controller: controller,
                scaleStateController: scaleStateController,
                enableRotation: true,
                initialScale: minScale * 1.5,
                minScale: minScale,
                maxScale: maxScale,
              ),
            ),
            Positioned(
              bottom: 0,
              height: 290,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(30.0),
                child: StreamBuilder(
                  stream: controller.outputStateStream,
                  initialData: controller.value,
                  builder: _streamBuild,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _streamBuild(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError || !snapshot.hasData) {
      return Container();
    }
    final PhotoViewControllerValue value = snapshot.data;
    return Column(
      children: <Widget>[
        Text(
          "Rotation ${value.rotation}",
          style: const TextStyle(color: Colors.white),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            thumbColor: Colors.orange,
          ),
          child: Slider(
            value: value.rotation.clamp(min, max),
            min: min,
            max: max,
            onChanged: (double newRotation) {
              controller.rotation = newRotation;
            },
          ),
        ),
        Text(
          "Scale ${value.scale}",
          style: const TextStyle(color: Colors.white),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            thumbColor: Colors.orange,
          ),
          child: Slider(
            value: value.scale!.clamp(minScale, maxScale),
            min: minScale,
            max: maxScale,
            onChanged: (double newScale) {
              controller.scale = newScale;
            },
          ),
        ),
        Text(
          "Position ${value.position.dx}",
          style: const TextStyle(color: Colors.white),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            thumbColor: Colors.orange,
          ),
          child: Slider(
            value: value.position.dx,
            min: -1000.0,
            max: 1000.0,
            onChanged: (double newPosition) {
              controller.position = Offset(newPosition, controller.position.dy);
            },
          ),
        ),
        Text(
          "ScaleState ${scaleStateController.scaleState}",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
