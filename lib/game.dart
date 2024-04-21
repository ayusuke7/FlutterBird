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

  final fps = const Duration(milliseconds: 10);

  final flappy = Bird(x: 100, y: 100);
  final pipes = <Pipe>[];

  final pipeGap = 160.0;
  final velocity = 1.0;
  final gravity = 0.1;
  final force = 3.5;

  Size size = const Size(480, 720);
  Timer? timer;

  int score = 0;
  bool started = false;
  
  double randomRange(int min, int max) {
    return (min + Random().nextInt((max + 1) - min)).toDouble();
  }

  void spawPipes() {
    for (var i=0; i<10; i++) {
      var x = size.width + (size.width * i);
      
      var hTop = randomRange(0, size.height ~/ 2);
      var hBottom = size.height - hTop - pipeGap;

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
          } 

          // if (
          //   pipes.indexOf(pipe) % 2 == 0 &&
          //   flappy.x < pipe.x + pipe.width
          // ) {
          //   print(t.tick);
          //   score++;
          // }
        }

        /* remove pipes */
        pipes.removeWhere((p) => p.x + p.width < 0);


        /* spaw news pipes */
        if (pipes.isEmpty) {
          spawPipes();
        }

      });
    });
  }

  void reset() {
    flappy.x = 30;
    flappy.y = 100;
    flappy.vy = 0;
    score = 0;
    pipes.clear();
  }

  @override
  void initState() {
    super.initState();
    //spawPipes();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            if (started) {
              flappy.vy = -force;
            } else {
              started = true;
              update();
            }
          },
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.blue.shade300,
            child: Stack(
              children: [
                    
                if (started) AnimatedPositioned(
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
                
                if (started) Align(
                  alignment: Alignment.topCenter,
                  child: Text("SCORE\n$score",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black, 
                          offset: Offset(1.5, 1.5)
                        )
                      ]
                    )
                  )
                ),
                
                if (!started) Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 4.0)
                    ),
                    child: const Text("TOUCH FOR START", style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

}