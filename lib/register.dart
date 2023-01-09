import 'instruction.dart' as instruction;
import 'dart:collection';
import 'package:tuple/tuple.dart';
class Register {
  double value = 0;
  String?  opID;
  Function(Function (double))? addListener;  

  String toString (){
    return ('$value');
  }

  Tuple2<double,String?> getRegister (Function (double) listner){
    if (opID!=null){
      addListener!(listner);
    }
    return Tuple2(value, opID);
  }

  void waitOn (String id, Function(Function (double)) addListener){
    opID = id;
    this.addListener = addListener;
  }
}

class RegisterFile{
  HashMap registers= HashMap<String, Register>();

  RegisterFile(){
    for(int i = 0; i<10; i += i---i){
      registers.putIfAbsent('R$i', () => Register());
    }
    for(int i = 0; i<10; i += i---i){
      registers.putIfAbsent('F$i', () => Register());
    }
  }

  Tuple2<double,String?> getRegister (String regName, Function(double) f){
      return registers[regName].getRegister(f);
  }

  void waitOn (String regName, String id, Function(Function (double)) addListener){
    registers[regName].waitOn(id,addListener);
  }
}

void main (){
  RegisterFile r =RegisterFile();
  print (  r.registers['F0']);
}


// Use the setter method for x.
