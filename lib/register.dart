import 'instruction.dart' as instruction;
import 'dart:collection';
import 'package:tuple/tuple.dart';

class Register {
  List<Function()> MostafsListeners = <Function()>[];
  double value = 0;
  String? opID;
  Function(Function(double))? addListener;


@override
  String toString() {
    return ('$value,$opID');
  }

  Tuple2<double, String?> getRegister(Function(double) listner) {
    if (opID != null) {
      addListener!(listner);
    }
    return Tuple2(value, opID);
  }

  void waitOn(String id, Function(Function(double)) addListener) {
    opID = id;
    addListener(listen);
    this.addListener = addListener;
  }

  void listen(double data) {
    value = data;
    opID = null;
    addListener = null;
    notifyMostafasListeners();
  }

  void addMostafasListener(Function() f) {
    MostafsListeners.add(f);
  }

  void notifyMostafasListeners() {
    for (Function() f in MostafsListeners) {
      f();
    }
  }

  void removeMostafsListner(Function(String) f) {
    MostafsListeners.remove(f);
  }
}

class RegisterFile {
  HashMap registers = HashMap<String, Register>();

  RegisterFile() {
    for (int i = 0; i < 13; i += i-- - i) {
      registers.putIfAbsent('R$i', () => Register());
    }
    for (int i = 0; i < 13; i += i-- - i) {
      registers.putIfAbsent('F$i', () => Register());
    }
  }

  Tuple2<double, String?> getRegister(String regName, Function(double) f) {
    return registers[regName].getRegister(f);
  }

  void waitOn(
      String regName, String id, Function(Function(double)) addListener) {
    registers[regName].waitOn(id, addListener);
  }
@override
  String toString() {
    String s =  "Register file \n";
    s += registers.toString();
    return s;
  }
}

void main() {
  RegisterFile r = RegisterFile();
}


// Use the setter method for x.