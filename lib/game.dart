import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bird/bird.dart';
import 'package:flutter_bird/pipe.dart';

class Game extends StatefulWidget {
  const Game({ super.key });

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {

  final size = const Size(320, 640);
  final fps = const Duration(milliseconds: 10);

  final flappy = Bird(x: 30, y: 100);
  final pipes = <Pipe>[];

  final velocity = 1.0;
  final gravity = 0.1;

  bool started = false;
  Timer? timer;
  
  double randomRange(int min, int max) {
    return (min + Random().nextInt((max + 1) - min)).toDouble();
  }

  void spawPipes() {
    var gap = 160;

    for (var i=0; i<5; i++) {
      var x = size.width + (size.width * i);
      
      var hTop = randomRange(0, size.height ~/ 2);
      var hBottom = size.height - hTop - gap;

      pipes.addAll([
        Pipe(
          x: x, 
          y: 0, 
          height: hTop
        ),
        Pipe(
          x: x, 
          y: size.height - hBottom,
          height: hBottom
        )
      ]);
    }
  }
  
  void update() {
    timer = Timer.periodic(fps, (t) {
      setState(() {
        flappy.y += flappy.vy;

        if (flappy.y + flappy.vy + flappy.height < size.height) {
          flappy.vy += gravity;
        } else {
          reset();
        }

        for (var pipe in pipes) {
          pipe.x -= velocity;

          if (
            flappy.x < pipe.x + pipe.width &&
            flappy.x + flappy.width > pipe.x &&
            flappy.y + flappy.vy < pipe.y + pipe.height &&
            flappy.y + flappy.vy + flappy.height > pipe.y
          ) {
            reset();
            break;
            //t.cancel();
          }
        }

        if (pipes.isEmpty) {
          spawPipes();
        }

        /* remove pipes */
        pipes.removeWhere((p) => p.x + p.width < 0);
      });
    });
  }

  void reset() {

    flappy.x = 30;
    flappy.y = 100;
    flappy.vy = 0;

    pipes.clear();
  }

  @override
  void initState() {
    super.initState();
    spawPipes();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (started) {
            flappy.vy = -4.0;
          } else {
            started = true;
            update();
          }
        },
        child: Center(
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.blue.shade300,
            child: Stack(
              children: [

                if (!started) Positioned(
                  left: size.width / 4.5,
                  top: size.height / 2,
                  child: const Text("TOUCH FOR START", style: TextStyle(
                    fontSize: 20,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(1.5, 1.5))
                    ]
                  )),
                ),
        
                AnimatedPositioned(
                  left: flappy.x,
                  top: flappy.y,
                  duration: fps,
                  child: Container(
                    width: flappy.width,
                    height: flappy.height,
                    color: Colors.red,
                  )
                ),
        
                for (var pipe in pipes)
                  AnimatedPositioned(
                    top: pipe.y,
                    left: pipe.x,
                    duration: fps,
                    child: Container(
                      width: pipe.width,
                      height: pipe.height,
                      color: Colors.green,
                    )
                  ),
          
              ]
            ),
          ),
        ),
      ),
    );
  }
}