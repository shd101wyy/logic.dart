import "package:built_collection/built_collection.dart";

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
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
LVar lvar(String id) {
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
  if (x[0] == dot) {
    return unify(x[1], y, sMap);
  } else if (y[1] == dot) {
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

Function succeed() {
  Iterable<BuiltMap<Object, Object>> succeed_(
      BuiltMap<Object, Object> sMap) sync* {
    yield sMap;
  }

  return succeed_;
}

Function fail() {
  Iterable<BuiltMap<Object, Object>> fail_(
      BuiltMap<Object, Object> sMap) sync* {
    yield null;
  }

  return fail_;
}

Function eq(Object x, Object y) {
  Iterable<BuiltMap<Object, Object>> eq_(BuiltMap<Object, Object> sMap) sync* {
    yield unify(x, y, sMap);
  }

  return eq_;
}
