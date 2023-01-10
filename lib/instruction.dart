import 'dart:collection';


import 'package:tomasulo_simulator/reservation_station.dart';

import 'register.dart' as register;


// do not edit 
class Instruction {
  final InstructionType _type;
  InstructionType get type => _type;
  String? target;
  String? operand1Reg;
  String? operand2Reg;
  String? operand1ID;
  String? operand2ID;
  double operand1Val = 0;
  double operand2Val = 0;
  int? addressOffset;


  Instruction.add({required this.target,required this.operand1Reg,required this.operand2Reg}):_type = InstructionType.add;
  Instruction.sub({required this.target,required this.operand1Reg,required this.operand2Reg}):_type = InstructionType.sub;
  Instruction.mult({required this.target,required this.operand1Reg,required this.operand2Reg}):_type = InstructionType.mult;
  Instruction.div({required this.target,required this.operand1Reg,required this.operand2Reg}):_type = InstructionType.div;
  Instruction.load({required this.target,required this.operand2Reg,required this.addressOffset}):_type = InstructionType.load;
  Instruction.store({required this.operand1Reg,required this.operand2Reg,required this.addressOffset}):_type = InstructionType.store;
@override
String toString(){
  return ('type : $type , target :$target, v1 : $operand1Val, v2 : $operand2Val, o1: $operand1ID, o2: $operand1ID');
}
}

class InstructionQueue {
Queue <Instruction> instructionQueue = Queue <Instruction> ();
  ReservationStation add;
  ReservationStation mult;
  AddressUnit addressUnit;
  
late Instruction currentInstruction;
  InstructionQueue(List<Instruction> l, this.add, this.mult,this.addressUnit){
    for (Instruction i in l){
      instructionQueue.add(i);
    }
    currentInstruction = instructionQueue.first;
  }
bool issueInstruction(Instruction i) {
  return add.allocate(i) ||
      mult.allocate(i) ||
      addressUnit.allocate(i);
}

  void onClockTick(){
      if(instructionQueue.isNotEmpty){
    if (issueInstruction(instructionQueue.first)){
      instructionQueue.removeFirst();
    }
    currentInstruction = instructionQueue.first;
  }

  }
}

enum InstructionType { add, sub, mult, div, load, store }
