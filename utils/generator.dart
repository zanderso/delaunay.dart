// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This script generates the 64 bit implementation by taking the 32 bit
// implementation and replacing all instances of Float32List with
// Float64List, and all instances of Delaunay32 with Delaunay64 in
// the file lib/src/delaunay_base_32.dart to produce the file
// delaunay_base_64.dart.
//
// To use it, from the root of the package just do:
// $ dart run utils/generator.dart
// Then re-run the formatter, analyzer, and tests.

import 'dart:io';

import 'package:path/path.dart' as path;

void main() {
  final String scriptDir = path.dirname(Platform.script.path);

  // Read in the 32-bit implementation.
  final String srcDir = path.join(scriptDir, '..', 'lib', 'src');
  final String float32Path = path.join(srcDir, 'delaunay_base_32.dart');
  final String float64Path = path.join(srcDir, 'delaunay_base_64.dart');
  String src = File(float32Path).readAsStringSync();

  // Change the 32-bit parts to be 64-bit.
  src = src.replaceAll('Float32List', 'Float64List');
  src = src.replaceAll('Delaunay32', 'Delaunay64');

  File(float64Path).writeAsStringSync(src, flush: true);
}
