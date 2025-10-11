# How to Contribute

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Delaunay32 vs. Delaunay64

There are two implementations. One that works in terms of `Float32List`,
and a second that works in terms of `Float64List`. The first one is
in `Delaunay32` implemented in `lib/src/delaunay_base_32.dart`. The second one
is in `Delaunay64` implemented in `lib/src/delaunay_base_64.dart`.

The file `delaunay_base_64.dart` is generated from `delaunay_base_32.dart` by
the script in `utils/generator.dart`. Do not edit `delaunay_base_64.dart`
by hand. Instead, only edit `delaunay_base_32.dart`. When the changes to
`delaunay_base_32.dart` are in good shape, use the script to copy them over
to `delaunay_base_64.dart`.

## Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Community Guidelines

This project follows [Google's Open Source Community
Guidelines](https://opensource.google/conduct/).
