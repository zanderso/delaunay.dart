// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:delaunay/delaunay.dart';

import 'svg.dart';

Future<void> main(List<String> args) async {
  final ArgParser argParser = ArgParser()
    ..addFlag('verbose',
      abbr: 'v',
      help: 'Verbose output',
      defaultsTo: false,
    )
    ..addOption('output',
      abbr: 'o',
      help: 'Path to the output file',
      defaultsTo: 'delaunay.svg',
    )
    ..addOption('width',
      abbr: 'w',
      help: 'Width of the output in mm',
      defaultsTo: '841',
    )
    ..addOption('height',
      abbr: 'h',
      help: 'Height of the output in mm',
      defaultsTo: '1189',
    )
    ..addOption('points',
      abbr: 'p',
      help: 'Number of points',
      defaultsTo: '1000',
    )
    ..addOption('seed',
      abbr: 's',
      help: 'RNG seed',
      defaultsTo: '42',
    );
  final ArgResults argResults = argParser.parse(args);
  final Options options = Options.fromArgResults(argResults);
  if (options == null) {
    stderr.writeln(argParser.usage);
    exit(1);
  }

  r = Random(options.seed);

  const double minX = 0.0;
  final double maxX = options.width.toDouble();
  const double minY = 0.0;
  final double maxY = options.height.toDouble();
  final Document doc = Document(
    dimensions: Dimensions(V(maxX, Unit.mm), V(maxY, Unit.mm)),
  );

  final int numPoints = options.points;
  final List<Point<double>> points = <Point<double>>[];
  for (int i = 0; i < numPoints; i++) {
    points.add(randomPoint(minX, maxX, minY, maxY));
  }

  points.add(const Point<double>(minX, minY));
  points.add(Point<double>(minX, maxY));
  points.add(Point<double>(maxX, minY));
  points.add(Point<double>(maxX, maxY));

  final Delaunay triangulator = Delaunay.from(points);

  final Stopwatch sw = Stopwatch()..start();
  triangulator.initialize();
  sw.stop();

  if (options.verbose) {
    print('Triangulator initialized in ${sw.elapsedMilliseconds}ms.');
  }

  sw.reset();
  sw.start();
  triangulator.processAllPoints();
  sw.stop();

  if (options.verbose) {
    print('Triangulated with ${triangulator.triangles.length ~/ 3} triangles '
          'in ${sw.elapsedMilliseconds}ms');
  }

  sw.reset();
  sw.start();
  final Iterable<Color> redToGreen = gradient(<Color>[
    Color.red,
    Color.blue,
    Color.green,
  ], 10);

  for (int i = 0; i < triangulator.triangles.length; i += 3) {
    doc.shapes.add(polygonOfTriangle(
      triangulator.getPoint(triangulator.triangles[i]),
      triangulator.getPoint(triangulator.triangles[i + 1]),
      triangulator.getPoint(triangulator.triangles[i + 2]),
      colorFn: () => randomColorFromList(redToGreen),
    ));
  }
  sw.stop();

  if (options.verbose) {
    print('SVG document constructed in ${sw.elapsedMilliseconds}ms.');
  }

  sw.reset();
  sw.start();
  final File svg = File('delaunator_test.svg');
  final IOSink ioSink = svg.openWrite();
  final BufferingIOSink bufferedSink = BufferingIOSink(ioSink);
  doc.write(bufferedSink);
  bufferedSink.flush();
  await ioSink.flush();
  await ioSink.close();
  sw.stop();
  if (options.verbose) {
    print('SVG document written in ${sw.elapsedMilliseconds}ms.');
  }
  return 0;
}

class Options {
  factory Options.fromArgResults(ArgResults results) {
    bool error = false;
    final int width = int.tryParse(results['width']);
    if (width == null || width <= 0) {
      error = true;
      stderr.writeln('--wdith must be a strictly positive integer');
    }
    final int height = int.tryParse(results['height']);
    if (height == null || height <= 0) {
      error = true;
      stderr.writeln('--height must be a strictly positive integer');
    }
    final int points = int.tryParse(results['points']);
    if (points == null || points <= 0) {
      error = true;
      stderr.writeln('--points must be a strictly positive integer');
    }
    final int seed = int.tryParse(results['seed']);
    if (seed == null || seed <= 0) {
      error = true;
      stderr.writeln('--seed must be a strictly positive integer');
    }
    if (error) {
      return null;
    }
    return Options._(
      width,
      height,
      results['output'],
      points,
      seed,
      results['verbose'],
    );
  }

  Options._(
    this.width,
    this.height,
    this.output,
    this.points,
    this.seed,
    this.verbose,
  );

  final int width;
  final int height;
  final String output;
  final int points;
  final int seed;
  final bool verbose;
}

Random r;

double nextInRange(double min, double max) =>
  r.nextDouble() * (max - min) + min;

Color randomColor() => rgb(r.nextInt(256), r.nextInt(256), r.nextInt(256));

Color randomGreen(int green) {
  final int nonGreen = r.nextInt(256);
  return rgb(nonGreen, green, nonGreen);
}

Point<double> randomPoint(double minX, double maxX, double minY, double maxY) {
  return Point<double>(nextInRange(minX, maxX), nextInRange(minY, maxY));
}

int floor(double d) => d.floor();

Iterable<Color> gradient(List<Color> colors,
                         int colorsPerSegment) sync* {
  if (colors.isEmpty) {
    yield Color.black;
  } else {
    Color start = colors[0];
    for (int i = 1; i < colors.length; i++) {
      final Color end = colors[i];
      final double rStep = (end.r - start.r) / colorsPerSegment;
      final double gStep = (end.g - start.g) / colorsPerSegment;
      final double bStep = (end.b - start.b) / colorsPerSegment;
      for (int j = 0; j < colorsPerSegment; j++) {
        yield Color(floor(start.r + rStep*j),
                    floor(start.g + gStep*j),
                    floor(start.b + bStep*j));

      }
      start = end;
    }
  }
}

Color randomColorFromList(Iterable<Color> colors) =>
    colors.elementAt(r.nextInt(colors.length));

Polygon polygonOfTriangle(
  Point<double> a,
  Point<double> b,
  Point<double> c, {
    Color Function() colorFn = randomColor
  }) {
  return Polygon(
    points: <SvgPoint>[
      SvgPoint(a),
      SvgPoint(b),
      SvgPoint(c),
      SvgPoint(a),
    ],
    fill: Fill(color: colorFn()),
    stroke: const Stroke(width: 1.0, color: Color.black)
  );
}

class BufferingIOSink implements StringSink {
  BufferingIOSink(this.ioSink, {this.bufferSize = 4096});

  final IOSink ioSink;
  final StringBuffer buffer = StringBuffer();
  final int bufferSize;

  @override
  void write(Object obj) {
    buffer.write(obj);
    _maybeFlush();
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String seperator = '']) {
    buffer.writeAll(objects, seperator);
    _maybeFlush();
  }

  @override
  void writeCharCode(int charCode) {
    buffer.writeCharCode(charCode);
    _maybeFlush();
  }

  @override
  void writeln([Object obj = '']) {
    buffer.writeln(obj);
    _maybeFlush();
  }

  Future<void> flush() async {
    ioSink.write(buffer.toString());
  }

  void _maybeFlush() {
    if (buffer.length > bufferSize) {
      ioSink.write(buffer.toString());
      buffer.clear();
    }
  }
}
