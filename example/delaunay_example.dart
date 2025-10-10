// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This program creates a png file of a delaunay trianulation of a random set
// of points with colors taken from an input image.
//
// Run 'dart delaunay_example.dart --help' for details.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:delaunay/delaunay.dart';
import 'package:image/image.dart' as image;

const String description =
    'delaunay_example.dart: An example program that creates a random delaunay '
    'trianulation png file with colors from an input image.';

Future<int> main(List<String> args) async {
  final ArgParser argParser =
      ArgParser()
        ..addFlag('help', abbr: 'h', help: 'Print help', negatable: false)
        ..addFlag(
          'verbose',
          abbr: 'v',
          help: 'Verbose output',
          negatable: false,
        )
        ..addOption(
          'input',
          abbr: 'i',
          help: 'Input image from which to extract colors for triangles',
        )
        ..addOption(
          'output',
          abbr: 'o',
          help: 'Path to the output file',
          defaultsTo: 'delaunay.png',
        )
        ..addOption(
          'points',
          abbr: 'p',
          help: 'Number of points',
          defaultsTo: '1000',
        )
        ..addOption('seed', abbr: 's', help: 'RNG seed', defaultsTo: '42');
  final ArgResults argResults = argParser.parse(args);
  final Options? options = Options.fromArgResults(argResults);
  if (options == null || options.help) {
    stderr.writeln(description);
    stderr.writeln();
    stderr.writeln(argParser.usage);
    return options == null ? 1 : 0;
  }
  if (options.inputImage == null) {
    return 1;
  }
  final image.Image inputImage = options.inputImage!;

  final Random r = Random(options.seed);

  const double minX = 0.0;
  final double maxX = inputImage.width.toDouble();
  const double minY = 0.0;
  final double maxY = inputImage.height.toDouble();

  final image.Image img = image.Image(
    width: inputImage.width,
    height: inputImage.height,
  );

  final int numPoints = options.points;
  final List<Point<double>> points = <Point<double>>[];
  for (int i = 0; i < numPoints; i++) {
    points.add(Point<double>(r.nextDouble() * maxX, r.nextDouble() * maxY));
  }

  points.add(const Point<double>(minX, minY));
  points.add(Point<double>(minX, maxY));
  points.add(Point<double>(maxX, minY));
  points.add(Point<double>(maxX, maxY));

  final Delaunay triangulator = Delaunay.from(points);

  final Stopwatch sw = Stopwatch()..start();
  triangulator.initialize();

  if (options.verbose) {
    print('Triangulator initialized in ${sw.elapsedMilliseconds}ms.');
  }

  sw.reset();
  sw.start();
  triangulator.processAllPoints();

  if (options.verbose) {
    print(
      'Triangulated with ${triangulator.triangles.length ~/ 3} triangles '
      'in ${sw.elapsedMilliseconds}ms',
    );
  }

  sw.reset();
  sw.start();

  for (int i = 0; i < triangulator.triangles.length; i += 3) {
    final Point<double> a = triangulator.getPoint(triangulator.triangles[i]);
    final Point<double> b = triangulator.getPoint(
      triangulator.triangles[i + 1],
    );
    final Point<double> c = triangulator.getPoint(
      triangulator.triangles[i + 2],
    );
    final image.Color color = inputImage.getPixel(
      (a.x.toInt() + b.x.toInt() + c.x.toInt()) ~/ 3,
      (a.y.toInt() + b.y.toInt() + c.y.toInt()) ~/ 3,
    );
    image.fillPolygon(
      img,
      color: color,
      vertices: <image.Point>[
        image.Point(a.x, a.y),
        image.Point(b.x, b.y),
        image.Point(c.x, c.y),
      ],
    );
  }

  if (options.verbose) {
    print('Image drawn in ${sw.elapsedMilliseconds}ms.');
  }

  sw.reset();
  sw.start();
  final List<int> imageData = image.encodePng(img, level: 2);
  File(options.output).writeAsBytesSync(imageData);
  sw.stop();
  if (options.verbose) {
    print('PNG document written in ${sw.elapsedMilliseconds}ms.');
  }

  return 0;
}

class Options {
  Options._(
    this.output,
    this.points,
    this.seed,
    this.verbose,
    this.help,
    this.inputImage,
  );

  static Options? fromArgResults(ArgResults results) {
    final bool verbose = results['verbose']!;
    final int? points = int.tryParse(results['points']!);
    if (points == null || points <= 0) {
      stderr.writeln('--points must be a strictly positive integer');
      return null;
    }
    final int? seed = int.tryParse(results['seed']!);
    if (seed == null || seed <= 0) {
      stderr.writeln('--seed must be a strictly positive integer');
      return null;
    }
    final bool help = results['help']!;
    if (!results.wasParsed('input') && help) {
      stderr.writeln('Please supply an image with the --input flag.');
      return null;
    }
    return Options._(
      results['output']!,
      points,
      seed,
      verbose,
      results['help']!,
      _imageFromArgResults(results, verbose),
    );
  }

  static image.Image? _imageFromArgResults(ArgResults results, bool verbose) {
    if (!results.wasParsed('input')) {
      return null;
    }
    final String inputImagePath = results['input']!;
    image.Image inputImage;
    final File inputFile = File(inputImagePath);
    if (!inputFile.existsSync()) {
      stderr.writeln('--input image "$inputImagePath" does not exist.');
      return null;
    }
    final Stopwatch sw = Stopwatch();
    sw.start();
    final Uint8List imageData = inputFile.readAsBytesSync();
    if (verbose) {
      final int kb = imageData.length >> 10;
      print('Image data (${kb}KB) read in ${sw.elapsedMilliseconds}ms');
    }
    sw.reset();
    inputImage = image.decodeImage(imageData)!;
    sw.stop();
    if (verbose) {
      final int w = inputImage.width;
      final int h = inputImage.height;
      print('Image data ${w}x$h decoded in ${sw.elapsedMilliseconds}ms');
    }
    return inputImage;
  }

  final String output;
  final int points;
  final int seed;
  final bool verbose;
  final bool help;
  final image.Image? inputImage;
}
