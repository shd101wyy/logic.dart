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
      var x = lvar("x");
      var sMap = BuiltMap<Object, Object>({x: 12});
      expect(walk(x, sMap), 12);
    });

    test('case 2', () {
      var x = lvar("x");
      var y = lvar("y");
      var sMap = BuiltMap<Object, Object>({x: y});
      expect(walk(x, sMap), y);
    });

    test('case 3', () {
      var x = lvar("x");
      var y = lvar("y");
      var sMap = BuiltMap<Object, Object>({x: y, y: 13});
      expect(walk(x, sMap), 13);
    });

    test('case 4', () {
      var x = lvar("x");
      var y = lvar("y");
      var sMap = BuiltMap<Object, Object>({y: 12});
      expect(walk(x, sMap), x);
    });
  });

  group("Test unify function", () {
    test('case 1', () {
      var sMap = BuiltMap<Object, Object>();
      var x = lvar("x");
      var targetSMap = BuiltMap<Object, Object>({x: 12});
      expect(unify(x, 12, sMap), targetSMap);
    });

    test('case 2', () {
      var x = lvar("x");
      var y = lvar("y");
      var sMap = BuiltMap<Object, Object>();
      var targetSMap = BuiltMap<Object, Object>({x: y});
      expect(unify(x, y, sMap), targetSMap);
    });

    test('case 3', () {
      var x = lvar("x");
      var m = lvar("m");
      var n = lvar("n");
      var sMap = BuiltMap<Object, Object>({x: 12, m: n});
      var targetSMap = BuiltMap<Object, Object>({x: 12, m: n, n: 12});
      expect(unify(x, m, sMap), targetSMap);
    });

    test('case 4', () {
      var x = lvar("x");
      var m = lvar("m");
      var n = lvar("n");
      var sMap = BuiltMap<Object, Object>({x: 12, m: n});
      var targetSMap = BuiltMap<Object, Object>({x: 12, m: n, n: 12});
      expect(unify(m, x, sMap), targetSMap);
    });
  });

  group("Test run function", () {
    test('case 1', () {
      expect(succeed().runtimeType, LogicGeneratorFunction);
    });

    test("case 2", () {
      final x = lvar("x");
      expect(run([x], eq(x, 1)), [{x: 1}]);
    }); 
  });

  group("Test run and", () {
    test("case 1", () {
      final x = lvar("x");
      final y = lvar();
      expect(run([x], and(
        eq(x, y),
        eq(y, 1)
      )), [{x: 1}]);
    });
  });


  group("Test run or", () {
    test("case 1", () {
      final x = lvar("x");
      expect(run([x], or(
        eq(x, 1),
        eq(x, 2)
      )), [{x: 1}, {x: 2}]);
    });

    test("case 2", () {
      final x = lvar("x");
      expect(run([x], or(
        eq(x, 1),
        eq(x, 2),
        count: 1
      )), [{x: 1}]);
    });

    test("case 3", () {
      final x = lvar("x");
      expect(run([x], or(
        eq(x, 1),
        eq(x, 2),
        count: 0
      )), []);
    });
  });
}
