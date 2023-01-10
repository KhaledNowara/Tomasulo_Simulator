import 'dart:collection';

import 'package:tomasulo_simulator/operation_station.dart';

import 'instruction.dart';
import 'register.dart';
import 'reservation_station.dart';

//initialize thingies, its 7 am in the night, my comments are not going to make a lot of sense
Queue <Instruction> instructionQueue = Queue <Instruction> ();
RegisterFile registerFile = RegisterFile();
MemOperationStation memory = MemOperationStation();
ReservationStation addStation = ReservationStation.add(registers:registerFile,funitDelay: 4);
ReservationStation multStation = ReservationStation.mult(registers:registerFile,funitDelay: 6);
ReservationStation divStation = ReservationStation.div(registers:registerFile);
MemoryBuffer loadBuffer = MemoryBuffer.load(functionalUnit: memory, registers: registerFile);
MemoryBuffer storeBuffer = MemoryBuffer.store(functionalUnit: memory, registers: registerFile);
AddressUnit addressUnit = AddressUnit('AU', registerFile, loadBuffer, storeBuffer);







bool issueInstruction(Instruction i) {
  return addStation.allocate(i) ||
      multStation.allocate(i) ||
      divStation.allocate(i) ||
      addressUnit.allocate(i);
}


void onClockTick(){
  if(instructionQueue.isNotEmpty){
    if (issueInstruction(instructionQueue.first)){
      instructionQueue.removeFirst();
    }
  }
  addStation.onClockTick();
  multStation.onClockTick();
  divStation.onClockTick();
  addressUnit.onClockTick();
  storeBuffer.onClockTick();
  loadBuffer.onClockTick();

}
void regCall() {}

void main() {
  // instructionQueue.add(Instruction.mult(target: 'R3', operand1Reg: 'R1', operand2Reg:'R2'));
  instructionQueue.add(Instruction.add(target: 'R5', operand1Reg: 'R3', operand2Reg:'R4'));
  instructionQueue.add(Instruction.add(target: 'R7', operand1Reg: 'R8', operand2Reg:'R6'));
  instructionQueue.add(Instruction.add(target: 'R10', operand1Reg: 'R8', operand2Reg:'R9'));
  instructionQueue.add(Instruction.add(target: 'R11', operand1Reg: 'R7', operand2Reg:'R10'));
  instructionQueue.add(Instruction.add(target: 'R5', operand1Reg: 'R5', operand2Reg:'R11'));

//  apply add fix to rest of instructions 
// test ba2y el instructions


    while(instructionQueue.isNotEmpty){
      onClockTick();

      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('\n');
      print('End Cycle');

    }
  


}
