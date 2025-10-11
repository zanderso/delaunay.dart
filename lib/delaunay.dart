// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A library for computing Delaunay triangulations.
library;

import 'src/delaunay_base_32.dart' show Delaunay32;
export 'src/delaunay_base_32.dart';
export 'src/delaunay_base_64.dart';

/// For compatibility with older versions, [Delaunay] is
/// aliased to [Delaunay32].
typedef Delaunay = Delaunay32;
