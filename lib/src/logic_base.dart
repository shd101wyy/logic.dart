import "package:built_collection/built_collection.dart";

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

// Generator Function type
typedef LogicGeneratorFunction = Iterable<BuiltMap<Object, Object>> Function(
    BuiltMap<Object, Object>);

typedef LogicGeneratorFunction ApplyType(
    List<dynamic> positionalArguments, Map<Symbol, dynamic> namedArguments);

class Variadic extends Function {
  final ApplyType _apply;

  Variadic(this._apply);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      if (invocation.isMethod) {
        return this
            ._apply(invocation.positionalArguments, invocation.namedArguments);
      }
      if (invocation.isGetter) {
        return this;
      }
    }
    return super.noSuchMethod(invocation);
  }
}

// Logic Variable
class LVar {
  String id;
  LVar(this.id);
  @override
  String toString() {
    return this.id;
  }
}

int lvarCounter = 0; // global counter
LVar lvar([String id]) {
  if (id == null) {
    id = "~.${lvarCounter}";
    lvarCounter++;
  }
  return LVar(id);
}

int dot() => 0;

Object walk(Object key, BuiltMap<Object, Object> sMap) {
  if (key is LVar) {
    if (sMap.containsKey(key)) {
      var val = sMap[key];
      return walk(val, sMap); // continue
    } else {
      return key; // not found
    }
  } else {
    return key;
  }
}

Object deepwalk(Object key, BuiltMap<Object, Object> sMap) {
  var val = walk(key, sMap);
  if (val is List) {
    var o = [];
    for (var i = 0; i < val.length; i++) {
      var x = val[i];
      if (x == dot) {
        var rest = deepwalk(val[i + 1], sMap);
        o.addAll(rest);
        break;
      } else {
        o.add(deepwalk(x, sMap));
      }
    }
    return o;
  } else {
    return val;
  }
}

BuiltMap<Object, Object> unify(
    Object x, Object y, BuiltMap<Object, Object> sMap) {
  x = walk(x, sMap);
  y = walk(y, sMap);
  if (x == y) {
    return sMap;
  } else if (x is LVar) {
    return sMap.rebuild((m) => m[x] = y);
  } else if (y is LVar) {
    return sMap.rebuild((m) => m[y] = x);
  } else if (x is List && y is List) {
    return unifyArray(x, y, sMap);
  } else {
    // failed to unify
    return null;
  }
}

BuiltMap<Object, Object> unifyArray(
    List x, List y, BuiltMap<Object, Object> sMap) {
  if (x.isEmpty && y.isEmpty) {
    return sMap;
  }
  if (x.isNotEmpty && x[0] == dot) {
    return unify(x[1], y, sMap);
  } else if (y.isNotEmpty && [0] == dot) {
    return unify(y[1], x, sMap);
  } else if ((x.isNotEmpty && y.isEmpty) || (x.isEmpty && y.isNotEmpty)) {
    return null;
  }
  var s = unify(x[0], y[0], sMap);
  if (s != null) {
    return unify(x.sublist(1), y.sublist(1), s);
  } else {
    return s;
  }
}

LogicGeneratorFunction succeed() {
  Iterable<BuiltMap<Object, Object>> succeed_(
      BuiltMap<Object, Object> sMap) sync* {
    yield sMap;
  }

  return succeed_;
}

LogicGeneratorFunction fail() {
  Iterable<BuiltMap<Object, Object>> fail_(
      BuiltMap<Object, Object> sMap) sync* {
    yield null;
  }

  return fail_;
}

LogicGeneratorFunction eq(Object x, Object y) {
  Iterable<BuiltMap<Object, Object>> eq_(BuiltMap<Object, Object> sMap) sync* {
    yield unify(x, y, sMap);
  }

  return eq_;
}

LogicGeneratorFunction _and(List<dynamic> goals, Map<Symbol, dynamic> named) {
  Iterable<BuiltMap<Object, Object>> __and(
      BuiltMap<Object, Object> sMap) sync* {
    Iterable<BuiltMap<Object, Object>> helper(
        int offset, BuiltMap<Object, Object> sMap) sync* {
      if (offset == goals.length) {
        return;
      }
      var goal = goals[offset];
      LogicGeneratorFunction goalGenerator;
      if (goal.runtimeType != LogicGeneratorFunction) {
        goalGenerator = goal();
      } else {
        goalGenerator = goal;
      }
      var iteratorSMap = goalGenerator(sMap).iterator;
      while (true) {
        bool done = !(iteratorSMap.moveNext());
        var sMap = iteratorSMap.current;
        if (done) {
          break;
        }
        if (sMap != null) {
          if (offset == goals.length - 1) {
            yield sMap;
          } else {
            yield* helper(offset + 1, sMap);
          }
        } else {
          // error
          yield null;
        }
      }
    }

    yield* helper(0, sMap);
  }

  return __and;
}

Function and = Variadic(_and) as Function;

LogicGeneratorFunction _or(List<dynamic> goals, Map<Symbol, dynamic> named) {
  int count = named[Symbol("count")] ?? -1;
  Iterable<BuiltMap<Object, Object>> __or(BuiltMap<Object, Object> sMap) sync* {
    Iterable<BuiltMap<Object, Object>> helper(
        int offset, BuiltMap<Object, Object> sMap, int solNum) sync* {
      if (offset == goals.length || count == 0) {
        return;
      }
      var goal = goals[offset];
      LogicGeneratorFunction goalGenerator;
      if (goal.runtimeType != LogicGeneratorFunction) {
        goalGenerator = goal();
      } else {
        goalGenerator = goal;
      }
      var iteratorSMap = goalGenerator(sMap).iterator;
      while (true) {
        bool done = !(iteratorSMap.moveNext());
        var sMap = iteratorSMap.current;
        if (done) {
          break;
        }
        if (sMap != null) {
          yield sMap;
          solNum += 1;
          if (count > 0 && solNum >= count) {
            return;
          }
        }
      }
      yield* helper(offset + 1, sMap, solNum);
    }

    yield* helper(0, sMap, 0);
  }

  return __or;
}

Function or = Variadic(_or) as Function;

List<Map> run(List<LVar> vars, Object goal, {int count = -1}) {
  lvarCounter = 0; // reset counter

  LogicGeneratorFunction goalGenerator;
  if (goal.runtimeType != LogicGeneratorFunction) {
    goalGenerator = (goal as Function)();
  } else {
    goalGenerator = goal;
  }

  List<Map> results = [];
  var sMap = BuiltMap<Object, Object>();
  var iteratorSMap = goalGenerator(sMap).iterator;
  while (count != 0) {
    bool done = !(iteratorSMap.moveNext());
    sMap = iteratorSMap.current;
    if (done) {
      break;
    }
    if (sMap != null) {
      count--;
      var r = {};
      vars.forEach((v) => r[v] = deepwalk(v, sMap));
      results.add(r);
    }
  }
  return results;
}

LogicGeneratorFunction conso(first, rest, out) {
  if (rest is LVar) {
    return eq([first, dot, rest], out);
  } else {
    return eq([first, ...rest], out);
  }
}

Function firsto(first, out) {
  return () {
    return conso(first, lvar(), out);
  };
}

Function resto(rest, out) {
  return () {
    return conso(lvar(), rest, out);
  };
}

LogicGeneratorFunction emptyo(x) {
  return eq(x, []);
}

LogicGeneratorFunction membero(x, arr) {
  return or(() {
    var first = lvar();
    return and(firsto(first, arr), eq(first, x));
  }, () {
    var rest = lvar();
    return and(resto(rest, arr), membero(x, rest));
  });
}

LogicGeneratorFunction appendo(seq1, seq2, out) {
  return or(and(emptyo(seq1), eq(seq2, out)), () {
    final first = lvar();
    final rest = lvar();
    final rec = lvar();
    return and(conso(first, rest, seq1), conso(first, rec, out),
        appendo(rest, seq2, rec));
  });
}

/// a + b = c
LogicGeneratorFunction add(a, b, c) {
  Iterable<BuiltMap<Object, Object>> add_(BuiltMap<Object, Object> sMap) sync* {
    int numOfLVars = 0;
    var lvar_;

    a = walk(a, sMap);
    b = walk(b, sMap);
    c = walk(c, sMap);

    bool aIsLVar = a is LVar;
    bool bIsLVar = b is LVar;
    bool cIsLVar = c is LVar;

    if (aIsLVar) {
      lvar_ = a;
      numOfLVars++;
    }
    if (bIsLVar) {
      lvar_ = b;
      numOfLVars++;
    }
    if (cIsLVar) {
      lvar_ = c;
      numOfLVars++;
    }

    if (numOfLVars == 0) {
      if (a + b == c) {
        yield sMap;
      } else {
        yield null;
      }
    } else if (numOfLVars == 1) {
      if (lvar_ == a) {
        if (c is num && b is num) {
          yield* eq(a, c - b)(sMap);
        } else {
          yield null;
        }
      } else if (lvar_ == b) {
        if (c is num && a is num) {
          yield* eq(b, c - a)(sMap);
        } else {
          yield null;
        }
      } else {
        // c
        if (a is num && b is num) {
          yield* eq(c, a + b)(sMap);
        } else {
          yield null;
        }
      }
    } else {
      yield null;
    }
  }

  return add_;
}

/// a - b = c
LogicGeneratorFunction sub(a, b, c) => add(b, c, a);

/// a * b = c
LogicGeneratorFunction mul(a, b, c) {
  Iterable<BuiltMap<Object, Object>> mul_(BuiltMap<Object, Object> sMap) sync* {
    int numOfLVars = 0;
    var lvar_;

    a = walk(a, sMap);
    b = walk(b, sMap);
    c = walk(c, sMap);

    bool aIsLVar = a is LVar;
    bool bIsLVar = b is LVar;
    bool cIsLVar = c is LVar;

    if (aIsLVar) {
      lvar_ = a;
      numOfLVars++;
    }
    if (bIsLVar) {
      lvar_ = b;
      numOfLVars++;
    }
    if (cIsLVar) {
      lvar_ = c;
      numOfLVars++;
    }

    if (numOfLVars == 0) {
      if (a * b == c) {
        yield sMap;
      } else {
        yield null;
      }
    } else if (numOfLVars == 1) {
      if (lvar_ == a) {
        if (c is num && b is num) {
          yield* eq(a, c / b)(sMap);
        } else {
          yield null;
        }
      } else if (lvar_ == b) {
        if (c is num && a is num) {
          yield* eq(b, c / a)(sMap);
        } else {
          yield null;
        }
      } else {
        // c
        if (a is num && b is num) {
          yield* eq(c, a * b)(sMap);
        } else {
          yield null;
        }
      }
    } else {
      yield null;
    }
  }

  return mul_;
}

/// a / b = c
LogicGeneratorFunction div(a, b, c) => mul(b, c, a);

LogicGeneratorFunction lt(x, y) {
  return (sMap) sync* {
    x = walk(x, sMap);
    y = walk(y, sMap);
    if (x is num && y is num && x < y) {
      yield sMap;
    } else {
      yield null;
    }
  };
}

LogicGeneratorFunction le(x, y) {
  return (sMap) sync* {
    x = walk(x, sMap);
    y = walk(y, sMap);
    if (x is num && y is num && x <= y) {
      yield sMap;
    } else {
      yield null;
    }
  };
}

LogicGeneratorFunction gt(x, y) => lt(y, x);
LogicGeneratorFunction ge(x, y) => le(y, x);

LogicGeneratorFunction stringo(x) {
  return (sMap) sync* {
    final val = walk(x, sMap);
    if (val is String) {
      yield sMap;
    } else {
      yield null;
    }
  };
}

LogicGeneratorFunction numbero(x) {
  return (sMap) sync* {
    final val = walk(x, sMap);
    if (val is num) {
      yield sMap;
    } else {
      yield null;
    }
  };
}

LogicGeneratorFunction arrayo(x) {
  return (sMap) sync* {
    final val = walk(x, sMap);
    if (val is List) {
      yield sMap;
    } else {
      yield null;
    }
  };
}

Function facts(List<List<dynamic>> facs) {
  LogicGeneratorFunction _helper(
      List<dynamic> args, Map<Symbol, dynamic> named) {
    return _or(
        facs.map((fac) {
          var _arr = [];
          fac.asMap().forEach((i, facArg) => _arr.add(eq(facArg, args[i])));
          return _and(_arr, named);
        }).toList(),
        named);
  }

  Function helper = Variadic(_helper) as Function;
  return helper;
}

LogicGeneratorFunction anyo(goal) {
  return or(goal, () {
    return anyo(goal);
  });
}
