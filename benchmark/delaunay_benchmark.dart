// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.12

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

  final Delaunay triangulator = Delaunay.from(points);
  final Stopwatch sw = Stopwatch()..start();

  triangulator.initialize();
  print('Triangulator initialized in ${sw.elapsedMilliseconds}ms.');

  sw.reset();
  sw.start();

  triangulator.processAllPoints();
  print('Triangulated with ${triangulator.triangles.length ~/ 3} triangles '
      'in ${sw.elapsedMilliseconds}ms');
  return 0;
}
