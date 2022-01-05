import 'dart:async';

import 'package:flutter/material.dart';
import 'package:terriblis_pictor/drawn_line.dart';
import 'package:terriblis_pictor/sketcher.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();

  List<DrawnLine?>? lines = <DrawnLine?>[];
  DrawnLine? line;

  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  StreamController<List<DrawnLine?>> linesStreamController =
      StreamController<List<DrawnLine?>>.broadcast();
  StreamController<DrawnLine?> currentLineStreamController =
      StreamController<DrawnLine?>.broadcast();

  Future<void> save() async {
    // TODO
  }

  Future<void> clear() async {
    // TODO
  }

  void onPanStart(DragStartDetails details) {
    print('User started painting');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    print(point);

    line = DrawnLine([point], selectedColor, selectedWidth);
    // if (line == null) {
    //   line = DrawnLine([point], selectedColor, selectedWidth);
    // }
    currentLineStreamController.add(line);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    print(point);
    final List<Offset?> path = List.from(line!.path)..add(point);

    line = DrawnLine(path, selectedColor, selectedWidth);

    if (lines!.length == 0) {
      lines!.add(line!);
    } else {
      lines![lines!.length - 1] = line!;
    }
    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    // final List<Offset?> path = List.from(line!.path)..add(null);
    // setState(() {
    //   print('User ended drawing');
    //   // line = DrawnLine(path, selectedColor, selectedWidth);
    //   lines!.add(line!);
    // });

    lines = List.from(lines!)..add(line);
    linesStreamController.add(lines!);
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<DrawnLine?>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(lines: lines),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<DrawnLine?>>(
            stream: linesStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(lines: lines),
              );
            }),
      ),
    );
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        selectedWidth = strokeWidth;
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildColorButton(Colors.red),
            buildColorButton(Colors.blueAccent),
            buildColorButton(Colors.deepOrange),
            buildColorButton(Colors.green),
            buildColorButton(Colors.lightBlue),
            buildColorButton(Colors.black),
            buildColorButton(Colors.white),
          ]),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: const CircleAvatar(
        child: Icon(
          Icons.save,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Stack(
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          buildColorToolbar(),
          buildStrokeToolbar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
}
