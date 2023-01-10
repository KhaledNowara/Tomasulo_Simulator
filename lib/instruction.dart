import 'dart:collection';

import 'register.dart' as register;

class Instruction {
  final InstructionType _type;
  InstructionType get type => _type;
  String target;
  String operand1Reg;
  String? operand2Reg;
  String? operand1ID;
  String? operand2ID;
  double operand1Val = 0;
  double operand2Val = 0;
  int? addressOffset;

  Instruction.add(
      {required this.target,
      required this.operand1Reg,
      required this.operand2Reg})
      : _type = InstructionType.add;
  Instruction.sub(
      {required this.target,
      required this.operand1Reg,
      required this.operand2Reg})
      : _type = InstructionType.sub;
  Instruction.mult(
      {required this.target,
      required this.operand1Reg,
      required this.operand2Reg})
      : _type = InstructionType.mult;
  Instruction.div(
      {required this.target,
      required this.operand1Reg,
      required this.operand2Reg})
      : _type = InstructionType.div;
  Instruction.load(
      {required this.target,
      required this.operand1Reg,
      required this.addressOffset})
      : _type = InstructionType.load;
  Instruction.store(
      {required this.target,
      required this.operand1Reg,
      required this.addressOffset})
      : _type = InstructionType.store;
}

enum InstructionType { add, sub, mult, div, load, store }
