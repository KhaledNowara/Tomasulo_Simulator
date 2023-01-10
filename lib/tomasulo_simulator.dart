import 'dart:collection';

import 'instruction.dart';
import 'register.dart';
import 'reservation_station.dart';

//initialize thingies, its 7 am in the night, my comments are not going to make a lot of sense
RegisterFile registerFile = RegisterFile();

ReservationStation addStation = ReservationStation.add(registers:registerFile);
ReservationStation multStation = ReservationStation.mult(registers:registerFile);
ReservationStation divStation = ReservationStation.div(registers:registerFile);
Queue <Instruction>? instructionQueue;


bool issueInstruction (Instruction i ){
  return addStation.allocate(i) || multStation.allocate(i)|| divStation.allocate(i);
  
}

void regCall (){


bool issueInstruction(Instruction i) {
  return addStation.allocate(i) ||
      multStation.allocate(i) ||
      divStation.allocate(i);
}

void regCall() {}
void main() {}
