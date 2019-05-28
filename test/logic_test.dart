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
      expect(run([x], eq(x, 1)), [
        {x: 1}
      ]);
    });
  });

  group("Test run and", () {
    test("case 1", () {
      final x = lvar("x");
      final y = lvar();
      expect(run([x], and(eq(x, y), eq(y, 1))), [
        {x: 1}
      ]);
    });
  });

  group("Test run or", () {
    test("case 1", () {
      final x = lvar("x");
      expect(run([x], or(eq(x, 1), eq(x, 2))), [
        {x: 1},
        {x: 2}
      ]);
    });

    test("case 2", () {
      final x = lvar("x");
      expect(run([x], or(eq(x, 1), eq(x, 2), count: 1)), [
        {x: 1}
      ]);
    });

    test("case 3", () {
      final x = lvar("x");
      expect(run([x], or(eq(x, 1), eq(x, 2), count: 0)), []);
    });
  });

  group("Test run array", () {
    test("case `conso` 1", () {
      final x = lvar("x");
      final y = lvar("y");
      expect(run([x, y], conso(x, y, [1, 2, 3])), [
        {
          x: 1,
          y: [2, 3]
        }
      ]);
    });

    test("case `firsto` 1", () {
      final x = lvar("x");
      expect(run([x], firsto(x, [3, 4, 5])), [
        {x: 3}
      ]);
    });

    test("case `resto` 1", () {
      final x = lvar("x");
      expect(run([x], resto(x, [1, 2, 3, 4])), [
        {
          x: [2, 3, 4]
        }
      ]);
    });

    test("case `emptyo` 1", () {
      final x = lvar("x");
      expect(run([x], emptyo(x)), [
        {x: []}
      ]);
    });

    test("case `membero` 1", () {
      final x = lvar("x");
      expect(run([x], membero(x, [1, 2, 3])), [
        {x: 1},
        {x: 2},
        {x: 3}
      ]);
    });

    test("case `appendo` 1", () {
      final x = lvar("x");
      final y = lvar("y");
      expect(run([x, y], appendo(x, y, [1, 2])), [
        {
          x: [],
          y: [1, 2]
        },
        {
          x: [1],
          y: [2]
        },
        {
          x: [1, 2],
          y: []
        }
      ]);
    });
  });

  group("Test arithmatics", () {
    test("case `add` 1", () {
      final x = lvar("x");
      expect(run([x], add(x, 3, 5)), [
        {x: 2}
      ]);
    });
    test("case `add` 2", () {
      final x = lvar("x");
      expect(run([x], add(2, x, 5)), [
        {x: 3}
      ]);
    });

    test("case `add` 3", () {
      final x = lvar("x");
      expect(run([x], add(2, 3, x)), [
        {x: 5}
      ]);
    });

    test("case `add` 4", () {
      final x = lvar("x");
      expect(run([x], add(2, 3, 5)), [
        {x: x}
      ]);
    });

    test("case `add` 5", () {
      final x = lvar("x");
      expect(run([x], add(2, 3, 6)), []);
    });

    test("case `sub` 1", () {
      final x = lvar("x");
      expect(run([x], sub(x, 3, 5)), [
        {x: 8}
      ]);
    });

    test("case `mul` 1", () {
      final x = lvar("x");
      expect(run([x], mul(6, x, 12)), [
        {x: 2}
      ]);
    });

    test("case `div` 1", () {
      final x = lvar("x");
      expect(run([x], div(x, 3, 5)), [
        {x: 15}
      ]);
    });
  });

  group("Test comparison", () {
    test("case `lt` 1", () {
      final x = lvar("x");
      expect(run([x], lt(3, 5)), [
        {x: x}
      ]);
    });

    test("case `lt` 2", () {
      final x = lvar("x");
      expect(run([x], lt(5, 3)), []);
    });
  });

  group("Test facts and rules", () {
    test("case `facts` 1", () {
      final x = lvar("x");
      final parent = facts([
        ["Steve", "Bob"],
        ["Steve", "Henry"],
        ["Henry", "Alice"]
      ]);
      expect(run([x], parent(x, "Alice")), [
        {x: "Henry"}
      ]);
    });

    test("case `facts` 2", () {
      final x = lvar("x");
      final parent = facts([
        ["Steve", "Bob"],
        ["Steve", "Henry"],
        ["Henry", "Alice"]
      ]);
      expect(run([x], parent("Steve", x)), [
        {x: "Bob"},
        {x: "Henry"}
      ]);
    });

    test("case `facts` 3", () {
      final x = lvar("x");
      final parent = facts([
        ["Steve", "Bob"],
        ["Steve", "Henry"],
        ["Henry", "Alice"]
      ]);
      var grandparent = (x, y) {
        final z = lvar();
        return and(parent(x, z), parent(z, y));
      };
      expect(run([x], grandparent(x, "Alice")), [
        {x: "Steve"}
      ]);
    });
  });

  group("Test anyo", () {
    test("Test case 1", () {
      final x = lvar("x");
      expect(run([x], anyo(or(eq(x, 1), eq(x, 2), eq(x, 3))), count: 2), [
        {x: 1},
        {x: 2}
      ]);
    });

    test("Test case 2", () {
      final x = lvar("x");
      expect(run([x], anyo(or(eq(x, 1), eq(x, 2), eq(x, 3))), count: 4), [
        {x: 1},
        {x: 2},
        {x: 3},
        {x: 1}
      ]);
    });
  });
}
