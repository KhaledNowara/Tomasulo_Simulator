import 'dart:collection';

import 'package:tomasulo_viz/models/operation_station.dart';

import 'instruction.dart';
import 'register.dart';
import 'reservation_station.dart';

//initialize thingies, its 7 am in the night, my comments are not going to make a lot of sense
RegisterFile registerFile = RegisterFile();
MemOperationStation memory = MemOperationStation(delay: 2);
ReservationStation addStation = ReservationStation.add(
    registers: registerFile, funitDelay: 2, size: 1, funitSize: 1);
ReservationStation multStation = ReservationStation.mult(
    registers: registerFile, funitDelay: 3, size: 2, funitSize: 2);
MemoryBuffer loadBuffer =
    MemoryBuffer.load(functionalUnit: memory, registers: registerFile, size: 1);
MemoryBuffer storeBuffer = MemoryBuffer.store(
    functionalUnit: memory, registers: registerFile, size: 1);
AddressUnit addressUnit =
    AddressUnit('AU', registerFile, loadBuffer, storeBuffer);
InstructionQueue instructionQueue =
    InstructionQueue(<Instruction>[], addStation, multStation, addressUnit);

void onClockTick() {
  print(instructionQueue.getCurrentInstruction());
  instructionQueue.onClockTick();
  addStation.onClockTick();
  multStation.onClockTick();
  addressUnit.onClockTick();
  storeBuffer.onClockTick();
  loadBuffer.onClockTick();
  print(registerFile);
  print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
  print("\n");
}

void regCall() {}

void main() {
  // instructionQueue.add(Instruction.mult(target: 'R3', operand1Reg: 'R1', operand2Reg:'R2'));
  // instructionQueue.instructionQueue.add(Instruction.add(target: 'R5', operand1Reg: 'R3', operand2Reg:'R4'));
  // instructionQueue.instructionQueue.add(Instruction.add(target: 'R7', operand1Reg: 'R8', operand2Reg:'R6'));
  // instructionQueue.instructionQueue.add(Instruction.add(target: 'R10', operand1Reg: 'R8', operand2Reg:'R9'));
  // instructionQueue.instructionQueue.add(Instruction.add(target: 'R11', operand1Reg: 'R7', operand2Reg:'R10'));
  // instructionQueue.instructionQueue.add(Instruction.add(target: 'R5', operand1Reg: 'R5', operand2Reg:'R11'));

  // instructionQueue.instructionQueue.add(Instruction.load(target: 'R2', operand2Reg: 'R1', addressOffset:8));
  // instructionQueue.instructionQueue.add(Instruction.add(target: 'R3', operand1Reg: 'R2', operand2Reg:'R2'));
  // instructionQueue.instructionQueue.add(Instruction.mult(target: 'R4', operand1Reg: 'R3', operand2Reg:'R3'));
  // instructionQueue.instructionQueue.add(Instruction.sub(target: 'R8', operand1Reg: 'R4', operand2Reg:'R4'));
  // instructionQueue.instructionQueue.add(Instruction.load(target: 'R5', operand2Reg: 'R1', addressOffset:4));
  // instructionQueue.instructionQueue.add(Instruction.div(target: 'R6', operand1Reg: 'R4', operand2Reg:'R5'));
  // instructionQueue.instructionQueue.add(Instruction.store(operand1Reg: 'R6', operand2Reg: 'R1', addressOffset:12));

//  apply add fix to rest of instructions
// test ba2y el instructions

  // for(int i=0 ; i<50 ; i++)
  // {
  //   print("Cycle : $i");
  //   onClockTick();

  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('\n');
  //   print('End Cycle');
  // }

  // Clock c = Clock();
  // c.runToFinish();
}
