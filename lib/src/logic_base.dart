// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

// Logic Variable
class LVar {
  String id;
  LVar(this.id);
}

int lvarCounter = 0; // global counter
LVar lvar(String id) {
  if (id == null) {
    id = "~.${lvarCounter}";
    lvarCounter++;
  }
  return LVar(id);
}




