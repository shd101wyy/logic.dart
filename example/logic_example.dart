import 'package:logic/logic.dart';

main() {
  // ====== CORE ======
  final x = lvar("x"); // define logic variable with id 'x'

  run([x], eq(x, 1)); // query 'x' => [{x: 1}]
  run([x], () {
    final y = lvar("y");
    return and(
      eq(y, 1),
      eq(x, y));
  }); // => [{x: 1}]

  run([x], or(eq(x, 1), eq(x, 2)));    // [{x: 1}, {x: 2}]
  run([x], or(eq(x, 1), eq(x, 2), count: 1)); // [{x: 1}]
  run([x], or(eq(x, 1), eq(x, 2)), count: 1); // [{x: 1}]

  // ====== FACTS ======
  final parent = facts([
    ['Steve', 'Bob'],      // Steve is Bob's parent
    ['Steve', 'Henry'],    // Steve is Henry's parent
    ['Henry', 'Alice']
  ]);    // Henry is Alice's parent
  run([x], parent(x, 'Alice'));     // who is Alice's parent => ['Henry']
  run([x], parent('Steve', x));     // who are Steve's children => ['Bob', 'Henry']

  // ====== RULES ======
  var grandparent = (x, y) {
    final z = lvar();
    return and(parent(x, z), parent(z, y));
  };

  run([x], grandparent(x, 'Alice'));  // who is Alice's grandparent => ['Steve']


  // ====== ARRAY ======
  final y = lvar('y');

  run([x], membero(x, [1, 2, 3]));
  // [{x: 1}, {x: 2}, {x: 3}]

  run([x, y], conso(x, y, [1, 2, 3]));
  // [{x: 1, y: [2, 3]}]

  run([x, y], appendo(x, y, [1, 2]));

  // ====== ARITHMETIC ======
  run([x], add(2, x, 5));

  // ====== EXTRA ======
  run([x], and(eq(x, 1), succeed()));
  // [{x: 1}]

  run([x], and(eq(x, 1), fail()));
  // []

  run([x], or(
    eq(x, 1),
    eq(x, 2),
    eq(x, 3)
  )); // [{x: 1}, {x: 2}, {x: 3}]

  run([x], or(
    eq(x, 1),
    and(eq(x, 2), fail()),
    eq(x, 3)
  )); // [{x: 1}, {x: 3}]

  run([x], anyo(or(eq(x, 1), eq(x, 2), eq(x, 3))), count: 4);
  // [{x: 1}, {x: 2}, {x: 3}, {x: 1}]
}
