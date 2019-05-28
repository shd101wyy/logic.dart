import 'package:built_collection/built_collection.dart';
import 'package:logic/logic.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    Awesome awesome;

    setUp(() {
      awesome = Awesome();
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });

  group("Test walk function", () {
    test('case 1', () {
      var x = LVar("x");
      var sMap = BuiltMap<Object, Object>({x: 12});
      expect(walk(x, sMap), 12);
    });

    test('case 2', () {
      var x = LVar("x");
      var y = LVar("y");
      var sMap = BuiltMap<Object, Object>({x: y});
      expect(walk(x, sMap), y);
    });

    test('case 3', () {
      var x = LVar("x");
      var y = LVar("y");
      var sMap = BuiltMap<Object, Object>({x: y, y: 13});
      expect(walk(x, sMap), 13);
    });

    test('case 4', () {
      var x = LVar("x");
      var y = LVar("y");
      var sMap = BuiltMap<Object, Object>({y: 12});
      expect(walk(x, sMap), x);
    });
  });

  group("Test unify function", () {
    test('case 1', () {
      var sMap = BuiltMap<Object, Object>();
      var x = LVar("x");
      var targetSMap = BuiltMap<Object, Object>({x: 12});
      expect(unify(x, 12, sMap), targetSMap);
    });

    test('case 2', () {
      var x = LVar("x");
      var y = LVar("y");
      var sMap = BuiltMap<Object, Object>();
      var targetSMap = BuiltMap<Object, Object>({x: y});
      expect(unify(x, y, sMap), targetSMap);
    });

    test('case 3', () {
      var x = LVar("x");
      var m = LVar("m");
      var n = LVar("n");
      var sMap = BuiltMap<Object, Object>({x: 12, m: n});
      var targetSMap = BuiltMap<Object, Object>({x: 12, m: n, n: 12});
      expect(unify(x, m, sMap), targetSMap);
    });

    test('case 4', () {
      var x = LVar("x");
      var m = LVar("m");
      var n = LVar("n");
      var sMap = BuiltMap<Object, Object>({x: 12, m: n});
      var targetSMap = BuiltMap<Object, Object>({x: 12, m: n, n: 12});
      expect(unify(m, x, sMap), targetSMap);
    });
  });
}
