// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A benchmark that depends only on this package and the core libraries to
// experiment with nnbd.

import 'dart:math';

import 'package:delaunay/delaunay.dart';

const int kSeed = 42;
const int kPoints = 1000000;
const int kWidth = 4096;
const int kHeight = 1024;

int main() {
  final Random r = Random(kSeed);
  final double maxX = kWidth.toDouble();
  final double maxY = kHeight.toDouble();

  final List<Point<double>> points = <Point<double>>[];
  for (int i = 0; i < kPoints; i++) {
    points.add(Point<double>(r.nextDouble() * maxX, r.nextDouble() * maxY));
  }

  final Delaunay32 triangulator32 = Delaunay32.from(points);
  final Delaunay64 triangulator64 = Delaunay64.from(points);
  final Stopwatch sw = Stopwatch();

  measure(
    stopwatch: sw,
    description: '32: Initilization',
    task: () => triangulator32.initialize(),
  );

  measure(
    stopwatch: sw,
    description: '32: Triangulation',
    task: () => triangulator32.processAllPoints(),
  );

  measure(
    stopwatch: sw,
    description: '64: Initilization',
    task: () => triangulator64.initialize(),
  );

  measure(
    stopwatch: sw,
    description: '64: Triangulation',
    task: () => triangulator64.processAllPoints(),
  );
  return 0;
}

void measure({
  required Stopwatch stopwatch,
  required void Function() task,
  required String description,
}) {
  stopwatch.start();
  task();
  final int ms = stopwatch.elapsedMilliseconds;
  stopwatch.reset();
  print('$description: ${ms}ms');
}
