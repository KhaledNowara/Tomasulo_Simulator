import 'dart:collection';

import 'package:tomasulo_simulator/operation_station.dart';

import 'instruction.dart';
import 'register.dart';
import 'reservation_station.dart';


class Clock {
  int cycles = 0;
  late RegisterFile registerFile ; 
  late MemOperationStation memory; 
  late ReservationStation addStation; 
  late ReservationStation multStation;
  late MemoryBuffer loadBuffer; 
  late MemoryBuffer storeBuffer;
  late AddressUnit addressUnit ; 
  late InstructionQueue instructionQueue;


  Clock(){
    initialize();
  }

  void initialize (){
     registerFile = RegisterFile();
     memory = MemOperationStation(delay:2);
     addStation = ReservationStation.add(registers:registerFile,funitDelay: 2,size: 1,funitSize: 1);
     multStation = ReservationStation.mult(registers:registerFile,funitDelay: 3,size: 2,funitSize:2);
     loadBuffer = MemoryBuffer.load(functionalUnit: memory, registers: registerFile,size: 1);
     storeBuffer = MemoryBuffer.store(functionalUnit: memory, registers: registerFile,size: 1);
     addressUnit = AddressUnit('AU', registerFile, loadBuffer, storeBuffer);
     instructionQueue = InstructionQueue (<Instruction>[] ,addStation,multStation,addressUnit);
     
       instructionQueue.instructionQueue.add(Instruction.load(target: 'R2', operand2Reg: 'R1', addressOffset:8));
  instructionQueue.instructionQueue.add(Instruction.add(target: 'R3', operand1Reg: 'R2', operand2Reg:'R2'));
  instructionQueue.instructionQueue.add(Instruction.mult(target: 'R4', operand1Reg: 'R3', operand2Reg:'R3'));
  instructionQueue.instructionQueue.add(Instruction.sub(target: 'R8', operand1Reg: 'R4', operand2Reg:'R4'));
  instructionQueue.instructionQueue.add(Instruction.load(target: 'R5', operand2Reg: 'R1', addressOffset:4));
  instructionQueue.instructionQueue.add(Instruction.div(target: 'R6', operand1Reg: 'R4', operand2Reg:'R5'));
  instructionQueue.instructionQueue.add(Instruction.store(operand1Reg: 'R6', operand2Reg: 'R1', addressOffset:12));
  }
  


void onClockTick (){
  instructionQueue.onClockTick();
  addStation.onClockTick();
  multStation.onClockTick();
  addressUnit.onClockTick();
  storeBuffer.onClockTick();
  loadBuffer.onClockTick();

  cycles ++;
}

bool finished (){
  bool f = instructionQueue.instructionQueue.isEmpty && addStation.isEmpty()&&multStation.isEmpty()&& storeBuffer.isEmpty()&& loadBuffer.isEmpty() && !addressUnit.busy;
  return f ;
}

void runToFinish (){
  while (!finished()){
    onClockTick();
  }
}

}