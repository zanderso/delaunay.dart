// Copyright 2020 Google LLC
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:math';

import 'package:meta/meta.dart';

String _attribute<T>(String name, T value, [String unit = '']) =>
    '$name="$value$unit" ';

String _elemStart(String name) => '\t<$name ';
String _elemEnd(String name) => '</$name>\n';
String _emptyElemEnd() => '/>\n';

enum _Units {
  em,
  ex,
  px,
  pt,
  pc,
  cm,
  mm,
  inches,
  percent,
}

class Unit {
  const Unit._(this._unit);

  final _Units _unit;

  static const Unit em = Unit._(_Units.em);
  static const Unit ex = Unit._(_Units.ex);
  static const Unit px = Unit._(_Units.px);
  static const Unit pt = Unit._(_Units.pt);
  static const Unit pc = Unit._(_Units.pc);
  static const Unit cm = Unit._(_Units.cm);
  static const Unit mm = Unit._(_Units.mm);
  static const Unit inches = Unit._(_Units.inches);
  static const Unit percent = Unit._(_Units.percent);

  static const List<String> _strings = <String>[
    'em',
    'ex',
    'px',
    'pt',
    'pc',
    'cm',
    'mm',
    'in',
    '%',
  ];

  @override
  String toString() => _strings[_unit.index];
}

abstract class _Writable {
  void write(StringSink ss);
}

class SvgValue implements _Writable {
  const SvgValue(this.v, {this.unit = Unit.px});

  final double v;
  final Unit unit;

  @override
  void write(StringSink ss) {
    ss.write(v);
    if (unit != Unit.px) {
      ss.write(unit);
    }
  }

  @override
  String toString() => unit == Unit.px ? v.toString() : '$v$unit';
}

class SvgPoint implements _Writable {
  const SvgPoint(this.p, {this.unit = Unit.px});

  final Point<double> p;
  final Unit unit;

  double get x => p.x;
  double get y => p.y;
  String get u => unit.toString();

  @override
  void write(StringSink ss) {
    ss.write(p.x);
    if (unit != Unit.px) {
      ss.write(unit);
    }
    ss.write(',');
    ss.write(p.y);
    if (unit != Unit.px) {
      ss.write(unit);
    }
  }

  @override
  String toString() => '${p.x}$unit,${p.y}$unit';
}

SvgValue V(double v, [Unit u = Unit.px]) => SvgValue(v, unit: u);
SvgPoint P(double x, double y, [Unit u = Unit.px]) =>
    SvgPoint(Point<double>(x, y), unit: u);

class Dimensions {
  const Dimensions(this.width, this.height);

  final SvgValue width;
  final SvgValue height;
}

class Color {
  const Color(this.r, this.g, this.b) : t = false;

  const Color._transparent()
      : r = 0,
        g = 0,
        b = 0,
        t = true;

  static const Color aqua = Color(0, 255, 255);
  static const Color black = Color(0, 0, 0);
  static const Color blue = Color(0, 0, 255);
  static const Color brown = Color(165, 42, 42);
  static const Color cyan = Color(0, 255, 255);
  static const Color fuchsia = Color(255, 0, 255);
  static const Color green = Color(0, 128, 0);
  static const Color lime = Color(0, 255, 0);
  static const Color magenta = Color(255, 0, 255);
  static const Color orange = Color(255, 165, 0);
  static const Color purple = Color(128, 0, 128);
  static const Color red = Color(255, 0, 0);
  static const Color silver = Color(192, 192, 192);
  static const Color white = Color(255, 255, 255);
  static const Color yellow = Color(255, 255, 0);
  static const Color transparent = Color._transparent();

  final int r;
  final int g;
  final int b;
  final bool t;

  @override
  String toString() => t ? 'none' : 'rgb($r,$g,$b)';
}

Color rgb(int r, int g, int b) => Color(r, g, b);

enum _FillRules {
  inherit,
  nonzero,
  evenodd,
}

class FillRule {
  const FillRule._(this._rule);

  final _FillRules _rule;

  static const FillRule inherit = FillRule._(_FillRules.inherit);
  static const FillRule nonzero = FillRule._(_FillRules.nonzero);
  static const FillRule evenodd = FillRule._(_FillRules.evenodd);

  static const List<String> _strings = <String>[
    'inherit',
    'nonzero',
    'evenodd',
  ];

  @override
  String toString() => _strings[_rule.index];
}

class Fill implements _Writable {
  const Fill({
    this.color = Color.transparent,
    this.rule = FillRule.inherit,
    this.opacity = 1.0,
  });

  final Color color;
  final FillRule rule;
  final double opacity;

  @override
  void write(StringSink ss) {
    ss.write(_attribute('fill', color));
    ss.write(_attribute('fill-rule', rule));
    ss.write(_attribute('fill-opacity', opacity));
  }
}

enum _StrokeLinecaps {
  inherit,
  butt,
  round,
  square,
}

class StrokeLinecap {
  const StrokeLinecap._(this._linecap);

  final _StrokeLinecaps _linecap;

  static const StrokeLinecap inherit = StrokeLinecap._(_StrokeLinecaps.inherit);
  static const StrokeLinecap butt = StrokeLinecap._(_StrokeLinecaps.butt);
  static const StrokeLinecap round = StrokeLinecap._(_StrokeLinecaps.round);
  static const StrokeLinecap square = StrokeLinecap._(_StrokeLinecaps.square);

  static const List<String> _strings = <String>[
    'inherit',
    'butt',
    'round',
    'square',
  ];

  @override
  String toString() => _strings[_linecap.index];
}

enum _StrokeLinejoins {
  inherit,
  miter,
  round,
  bevel,
}

class StrokeLinejoin {
  const StrokeLinejoin._(this._linejoin);

  final _StrokeLinejoins _linejoin;

  static const StrokeLinejoin inherit =
      StrokeLinejoin._(_StrokeLinejoins.inherit);
  static const StrokeLinejoin miter = StrokeLinejoin._(_StrokeLinejoins.miter);
  static const StrokeLinejoin round = StrokeLinejoin._(_StrokeLinejoins.round);
  static const StrokeLinejoin bevel = StrokeLinejoin._(_StrokeLinejoins.bevel);

  static const List<String> _strings = <String>[
    'inherit',
    'miter',
    'round',
    'bevel',
  ];

  @override
  String toString() => _strings[_linejoin.index];
}

class Stroke implements _Writable {
  const Stroke({
    this.width = -1.0,
    this.color = Color.transparent,
    this.nonScaling = false,
    this.linecap = StrokeLinecap.inherit,
    this.linejoin = StrokeLinejoin.inherit,
    this.opacity = 1.0,
  });

  final double width;
  final Color color;
  final bool nonScaling;
  final StrokeLinecap linecap;
  final StrokeLinejoin linejoin;
  final double opacity;

  @override
  void write(StringSink ss) {
    if (width < 0) {
      return;
    }
    ss.write(_attribute('stroke-width', width));
    ss.write(_attribute('stroke', color));
    if (nonScaling) {
      ss.write(_attribute('vector-effect', 'non-scaling-stroke'));
    }
    ss.write(_attribute('stroke-linecap', linecap));
    ss.write(_attribute('stroke-linejoin', linejoin));
    ss.write(_attribute('stroke-opacity', opacity));
  }
}

class Font implements _Writable {
  const Font({
    this.size = 12,
    this.family = 'Verdana',
  });

  final double size;
  final String family;

  @override
  void write(StringSink ss) {
    ss.write(_attribute('font-size', size));
    ss.write(_attribute('font-family', family));
  }
}

abstract class Shape implements _Writable {
  const Shape({
    this.fill = const Fill(),
    this.stroke = const Stroke(),
  });

  final Fill fill;
  final Stroke stroke;
}

class Circle extends Shape {
  Circle({
    @required this.center,
    @required this.diameter,
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  }) : super(fill: fill, stroke: stroke);

  final SvgPoint center;
  final SvgValue diameter;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('circle'));
    ss.write(_attribute('cx', center.x, center.u));
    ss.write(_attribute('cy', center.y, center.u));
    ss.write(_attribute('r', diameter.v / 2.0, diameter.unit.toString()));
    fill.write(ss);
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

class Ellipse extends Shape {
  Ellipse({
    @required this.center,
    @required this.width,
    @required this.height,
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  }) : super(fill: fill, stroke: stroke);

  final SvgPoint center;
  final SvgValue width;
  final SvgValue height;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('ellipse'));
    ss.write(_attribute('cx', center.x, center.u));
    ss.write(_attribute('cy', center.y, center.u));
    ss.write(_attribute('rx', width.v / 2.0, width.unit.toString()));
    ss.write(_attribute('ry', height.v / 2.0, height.unit.toString()));
    fill.write(ss);
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

class Rectangle extends Shape {
  Rectangle({
    @required this.edge,
    @required this.width,
    @required this.height,
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  }) : super(fill: fill, stroke: stroke);

  final SvgPoint edge;
  final SvgValue width;
  final SvgValue height;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('rect'));
    ss.write(_attribute('x', edge.x, edge.u));
    ss.write(_attribute('y', edge.y, edge.u));
    ss.write(_attribute('width', width));
    ss.write(_attribute('height', height));
    fill.write(ss);
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

class Line extends Shape {
  Line({
    @required this.start,
    @required this.end,
    Stroke stroke = const Stroke(),
  }) : super(fill: const Fill(), stroke: stroke);

  final SvgPoint start;
  final SvgPoint end;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('line'));
    ss.write(_attribute('x1', start.x, start.u));
    ss.write(_attribute('y1', start.y, start.u));
    ss.write(_attribute('x2', end.x, end.u));
    ss.write(_attribute('y2', end.y, end.u));
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

class Polygon extends Shape {
  Polygon({
    List<SvgPoint> points,
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  })  : points = points ?? <SvgPoint>[],
        super(fill: fill, stroke: stroke);

  final List<SvgPoint> points;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('polygon'));
    ss.write('points="');
    for (SvgPoint p in points) {
      p.write(ss);
      ss.write(' ');
    }
    ss.write('" ');
    fill.write(ss);
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

abstract class PathCommand implements _Writable {
  String get command;
}

class MoveTo implements PathCommand {
  MoveTo(
    this.to, {
    this.relative = false,
  });

  final SvgPoint to;
  final bool relative;

  @override
  String get command => relative ? 'm' : 'M';

  @override
  void write(StringSink ss) {
    ss.write(command);
    to.write(ss);
  }
}

class LineTo implements PathCommand {
  LineTo(
    this.to, {
    this.relative = false,
  });

  final SvgPoint to;
  final bool relative;

  @override
  String get command => relative ? 'l' : 'L';

  @override
  void write(StringSink ss) {
    ss.write(command);
    to.write(ss);
  }
}

class HLineTo implements PathCommand {
  HLineTo({
    @required this.x,
    this.relative = false,
  });

  final SvgValue x;
  final bool relative;

  @override
  String get command => relative ? 'h' : 'H';

  @override
  void write(StringSink ss) {
    ss.write(command);
    x.write(ss);
  }
}

class VLineTo implements PathCommand {
  VLineTo({
    @required this.y,
    this.relative = false,
  });

  final SvgValue y;
  final bool relative;

  @override
  String get command => relative ? 'v' : 'V';

  @override
  void write(StringSink ss) {
    ss.write(command);
    y.write(ss);
  }
}

class CurveTo implements PathCommand {
  CurveTo(
    this.to, {
    @required this.beginControl,
    @required this.endControl,
    this.relative = false,
  });

  final SvgPoint to;
  final SvgPoint beginControl;
  final SvgPoint endControl;
  final bool relative;

  @override
  String get command => relative ? 'c' : 'C';

  @override
  void write(StringSink ss) {
    ss.write(command);
    beginControl.write(ss);
    ss.write(' ');
    endControl.write(ss);
    ss.write(' ');
    to.write(ss);
  }
}

class SmoothCurveTo implements PathCommand {
  SmoothCurveTo(
    this.to, {
    @required this.endControl,
    this.relative = false,
  });

  final SvgPoint to;
  final SvgPoint endControl;
  final bool relative;

  @override
  String get command => relative ? 's' : 'S';

  @override
  void write(StringSink ss) {
    ss.write(command);
    endControl.write(ss);
    ss.write(' ');
    to.write(ss);
  }
}

class QuadTo implements PathCommand {
  QuadTo(
    this.to, {
    @required this.control,
    this.relative = false,
  });

  final SvgPoint to;
  final SvgPoint control;
  final bool relative;

  @override
  String get command => relative ? 'q' : 'Q';

  @override
  void write(StringSink ss) {
    ss.write(command);
    control.write(ss);
    ss.write(' ');
    to.write(ss);
  }
}

class SmoothQuadTo implements PathCommand {
  SmoothQuadTo(
    this.to, {
    this.relative = false,
  });

  final SvgPoint to;
  final bool relative;

  @override
  String get command => relative ? 't' : 'T';

  @override
  void write(StringSink ss) {
    ss.write(command);
    to.write(ss);
  }
}

class PathEllipticalArc implements PathCommand {
  PathEllipticalArc({
    @required this.to,
    @required this.rx,
    @required this.ry,
    @required this.rotation,
    this.largeArc = false,
    this.sweep = false,
    this.relative = false,
  });

  final SvgPoint to;
  final SvgValue rx;
  final SvgValue ry;
  final double rotation;
  final bool largeArc;
  final bool sweep;
  final bool relative;

  @override
  String get command => relative ? 'a' : 'A';

  @override
  void write(StringSink ss) {
    ss.write(command);
    rx.write(ss);
    ss.write(',');
    ry.write(ss);
    ss.write(' ');
    ss.write(rotation);
    ss.write(' ');
    ss.write(largeArc ? 1 : 0);
    ss.write(',');
    ss.write(sweep ? 1 : 0);
    ss.write(' ');
    to.write(ss);
  }
}

class PathClose implements PathCommand {
  @override
  String get command => 'Z';

  @override
  void write(StringSink ss) {
    ss.write(command);
  }
}

class Path extends Shape {
  Path({
    List<PathCommand> commands,
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  })  : commands = commands ?? <PathCommand>[],
        super(fill: fill, stroke: stroke);

  final List<PathCommand> commands;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('path'));
    ss.write('d="');
    for (PathCommand command in commands) {
      command.write(ss);
    }
    ss.write('" ');
    ss.write('fill-rule="evenodd" ');
    fill.write(ss);
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

class Polyline extends Shape {
  Polyline({
    List<SvgPoint> points,
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  })  : points = points ?? <SvgPoint>[],
        super(fill: fill, stroke: stroke);

  final List<SvgPoint> points;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('polyline'));
    ss.write('points="');
    for (SvgPoint p in points) {
      p.write(ss);
      ss.write(' ');
    }
    ss.write('" ');
    fill.write(ss);
    stroke.write(ss);
    ss.write(_emptyElemEnd());
  }
}

class Text extends Shape {
  Text({
    @required this.origin,
    @required this.content,
    this.font = const Font(),
    Fill fill = const Fill(),
    Stroke stroke = const Stroke(),
  }) : super(fill: fill, stroke: stroke);

  final SvgPoint origin;
  final String content;
  final Font font;

  @override
  void write(StringSink ss) {
    ss.write(_elemStart('text'));
    ss.write(_attribute('x', origin.x, origin.u));
    ss.write(_attribute('y', origin.y, origin.u));
    fill.write(ss);
    stroke.write(ss);
    font.write(ss);
    ss.write('>');
    ss.write(content);
    ss.write(_elemEnd('text'));
  }
}

class Document {
  Document({
    List<Shape> shapes,
    this.dimensions = const Dimensions(SvgValue(100), SvgValue(100)),
  }) : shapes = shapes ?? <Shape>[];

  final List<Shape> shapes;
  final Dimensions dimensions;

  void write(StringSink ss) {
    ss.write('<?xml ');
    ss.write(_attribute('version', '1.0'));
    ss.write(_attribute('standalone', 'no'));
    ss.write('?>\n<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" ');
    ss.write('"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n<svg ');
    ss.write(_attribute('width', dimensions.width));
    ss.write(_attribute('height', dimensions.height));
    ss.write(_attribute(
      'viewBox',
      '0 0 ${dimensions.width.v} ${dimensions.height.v}',
    ));
    ss.write(_attribute('xmlns', 'http://www.w3.org/2000/svg'));
    ss.write(_attribute('version', '1.1'));
    ss.write('>\n');
    for (Shape shape in shapes) {
      shape.write(ss);
    }
    ss.write(_elemEnd('svg'));
  }
}
