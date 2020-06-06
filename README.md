A library for Delaunay triangulation for Dart developers.

This implementation is adapted from the [Delaunator][delaunator] JavaScript
library.

## Usage

A simple usage example:

```dart
Float32List points = Float32List.fromList(<double>[
  143.0, 178.5,
  50.2, -100.7,
  ...
]);
Delaunay delaunay = Delaunay(points);
delaunay.update();
for (int i = 0; i < delaunay.triangles.length; i += 3) {
  int a = delaunay.triangles[i];
  int b = delaunay.triangles[i + 1];
  int c = delaunay.triangles[i + 3];

  double ax = delaunay.coords[2*a];
  double ay = delaunay.coords[2*a + 1];
  ...
}
...
points[0] = 140.0;
delaunay.update();
...
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[delaunator]: https://github.com/mapbox/delaunator
[tracker]: http://example.com/issues/replaceme
