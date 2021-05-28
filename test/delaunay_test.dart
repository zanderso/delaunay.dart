// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.12

import 'dart:math';
import 'dart:typed_data';

import 'package:delaunay/delaunay.dart';
import 'package:test/test.dart';

import 'fixtures/ukraine.dart' as ukraine;

void main() {
  test('triangulates points and typed data', () {
    final Delaunay pointsDelaunay = Delaunay.from(ukraine.points)..update();
    final Delaunay dataDelaunay = Delaunay(ukraine.typedPoints)..update();
    expect(pointsDelaunay.triangles, equals(dataDelaunay.triangles));
  });

  test('produces correct triangulation', () {
    validate(ukraine.typedPoints);
  });

  test('produces correct triangulation after modifying coords in place', () {
    final Delaunay d = Delaunay(ukraine.typedPoints);

    validate(ukraine.typedPoints, d);

    expect(d.triangles.length, equals(5151));

    ukraine.typedPoints[0] = 80.0;
    ukraine.typedPoints[1] = 220.0;
    validate(ukraine.typedPoints, d);

    expect(d.triangles.length, equals(5157));
  });

  test('corner case 1', () {
    final Float32List data = Float32List.fromList(<double>[
      516,
      661,
      369,
      793,
      426,
      539,
      273,
      525,
      204,
      694,
      747,
      750,
      454,
      390,
    ]);
    validate(data);
  });

  test('corner case 2', () {
    final Float32List data = Float32List.fromList(<double>[
      382,
      302,
      382,
      328,
      382,
      205,
      623,
      175,
      382,
      188,
      382,
      284,
      623,
      87,
      623,
      341,
      141,
      227,
    ]);
    validate(data);
  });

  test('corner case 3', () {
    final Float32List data = Float32List.fromList(<double>[
      4,
      1,
      3.7974166882130675,
      2.0837249985614585,
      3.2170267516619773,
      3.0210869309396715,
      2.337215067329615,
      3.685489874065187,
      1.276805078389906,
      3.9872025288851036,
      0.17901102978375127,
      3.885476929518457,
      -0.8079039091377689,
      3.3940516818407187,
      -1.550651407188842,
      2.5792964886320684,
      -1.9489192990517052,
      1.5512485534497125,
      -1.9489192990517057,
      0.44875144655029087,
      -1.5506514071888438,
      -0.5792964886320653,
      -0.8079039091377715,
      -1.394051681840717,
      0.17901102978374794,
      -1.8854769295184561,
      1.276805078389902,
      -1.987202528885104,
      2.337215067329611,
      -1.6854898740651891,
      3.217026751661974,
      -1.021086930939675,
      3.7974166882130653,
      -0.08372499856146409,
    ]);
    validate(data);
  });

  test('corner case 4', () {
    final Float32List data = Float32List.fromList(<double>[
      -537.7739674441619,
      -122.26130468750004,
      -495.533967444162,
      -183.39195703125006,
      -453.29396744416204,
      -244.5226093750001,
      -411.0539674441621,
      -305.6532617187501,
      -164,
      -122,
    ]);
    validate(data);
  });

  test('returns empty triangulation for a small number of points', () {
    Delaunay d = Delaunay.from(<Point<double>>[])..update();
    expect(d.triangles, isEmpty);
    expect(d.hull, isEmpty);
    d = Delaunay.from(<Point<double>>[const Point<double>(0, 0)])..update();
    expect(d.triangles, isEmpty);
    expect(d.hull, isEmpty);
    d = Delaunay.from(<Point<double>>[
      const Point<double>(0, 0),
      const Point<double>(1, 1),
    ])
      ..update();
    expect(d.triangles, isEmpty);
    expect(d.hull, isEmpty);
  });

  test('returns empty triangulation for all colinear points', () {
    final Delaunay d = Delaunay(Float32List.fromList(<double>[
      0,
      0,
      1,
      0,
      3,
      0,
      2,
      0,
    ]))
      ..update();
    expect(d.triangles, isEmpty);
    expect(d.hull, equals(<int>[0, 1, 3, 2]));
  });
}

final double _epsilon = pow(2.0, -51) as double;

void validate(
  Float32List points, [
  Delaunay? d,
]) {
  d ??= Delaunay(points);
  d.update();

  // validate halfedges
  for (int i = 0; i < d.halfEdges.length; i++) {
    final int i2 = d.halfEdges[i];
    if (i2 != -1 && d.halfEdges[i2] != i) {
      fail('invalid halfedge connection');
    }
  }

  // validate triangulation
  final List<double> hullAreas = <double>[];
  final int len = d.hull.length;
  int prev = len - 1;
  for (int i = 0; i < len; i++) {
    final double x0 = d.coords[2 * d.hull[prev]];
    final double y0 = d.coords[2 * d.hull[prev] + 1];
    final double x = d.coords[2 * d.hull[i]];
    final double y = d.coords[2 * d.hull[i] + 1];

    hullAreas.add((x - x0) * (y + y0));
    final bool c = convex(
      d.coords[2 * d.hull[prev]],
      d.coords[2 * d.hull[prev] + 1],
      d.coords[2 * d.hull[(prev + 1) % d.hull.length]],
      d.coords[2 * d.hull[(prev + 1) % d.hull.length] + 1],
      d.coords[2 * d.hull[(prev + 3) % d.hull.length]],
      d.coords[2 * d.hull[(prev + 3) % d.hull.length] + 1],
    );
    if (!c) {
      fail('hull is not convex at $prev');
    }
    prev = i;
  }
  final double hullArea = sum(hullAreas);

  final List<double> triangleAreas = <double>[];
  for (int i = 0; i < d.triangles.length; i += 3) {
    final double ax = d.coords[2 * d.triangles[i]];
    final double ay = d.coords[2 * d.triangles[i] + 1];
    final double bx = d.coords[2 * d.triangles[i + 1]];
    final double by = d.coords[2 * d.triangles[i + 1] + 1];
    final double cx = d.coords[2 * d.triangles[i + 2]];
    final double cy = d.coords[2 * d.triangles[i + 2] + 1];
    triangleAreas.add(((by - ay) * (cx - bx) - (bx - ax) * (cy - by)).abs());
  }
  final double trianglesArea = sum(triangleAreas);

  final double err = ((hullArea - trianglesArea) / hullArea).abs();
  if (err > _epsilon) {
    fail('triangulation is broken: $err error');
  }
}

double orient(
  double px,
  double py,
  double rx,
  double ry,
  double qx,
  double qy,
) {
  final double l = (ry - py) * (qx - px);
  final double r = (rx - px) * (qy - py);
  return (l - r).abs() >= 3.3306690738754716e-16 * (l + r).abs() ? l - r : 0;
}

bool convex(
  double rx,
  double ry,
  double qx,
  double qy,
  double px,
  double py,
) {
  double orientation = orient(px, py, rx, ry, qx, qy);
  if (orientation != 0.0) {
    return orientation >= 0.0;
  }
  orientation = orient(rx, ry, qx, qy, px, py);
  if (orientation != 0.0) {
    return orientation >= 0.0;
  }
  orientation = orient(qx, qy, px, py, rx, ry);
  if (orientation != 0.0) {
    return orientation >= 0.0;
  }
  return true;
}

// Kahan and Babuska summation, Neumaier variant; accumulates less FP error
double sum(List<double> x) {
  double sum = x[0];
  double err = 0.0;
  for (int i = 1; i < x.length; i++) {
    final double k = x[i];
    final double m = sum + k;
    err += sum.abs() >= k.abs() ? sum - m + k : k - m + sum;
    sum = m;
  }
  return sum + err;
}
