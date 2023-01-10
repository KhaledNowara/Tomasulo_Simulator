import 'dart:html';

import 'instruction.dart' as instruction;
import 'reservation_station.dart' ;


abstract class OperationStationElement {
  List<Function()> MostafsListeners = <Function()>[];
  int currentCycle = 0;
  bool _busy = false;
  ReservationStationElement? station; 
  instruction.Instruction? _currentInstruction;
  String? stationID;
  bool get busy => _busy;
  // notify listners somewhere

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

   void operate();
  void emptyStation() {
    currentCycle = 0;
    _busy = false;
    notifyMostafasListeners();
  }
  void allocate(instruction.Instruction i, String id) {
    _currentInstruction = i;
    _busy = true;
    currentCycle = 0;
    stationID = id;
    notifyMostafasListeners();
  }
}

class AddOperationElemnt extends OperationStationElement {
  
  @override
  void operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.add ){
        station!.notifyListeners(_currentInstruction!.operand1Val + _currentInstruction!.operand1Val);   
        station!.freeStation();
        emptyStation();
        notifyMostafasListeners();

      }
     throw Exception('Invalid Instruction');
    }
    throw Exception('Instruction not found');
  }
}

class MultOperationElemnt extends OperationStationElement {
  
   @override
  void operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.mult ){
        station!.notifyListeners(_currentInstruction!.operand1Val * _currentInstruction!.operand1Val); 
        station!.freeStation();
        emptyStation();      
        notifyMostafasListeners();
      }
      throw Exception('Invalid Instruction');
    }
    throw Exception('Instruction not found');
  }
}
class DivOperationElemnt extends OperationStationElement {
  
 @override
  void operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.div ){
        station!.notifyListeners(_currentInstruction!.operand1Val / _currentInstruction!.operand1Val);  
        station!.freeStation();
        emptyStation(); 
        notifyMostafasListeners();
      }
      throw Exception('Invalid Instruction');
    }
    throw Exception('Instruction not found');
  }
}


class MemoryOperationElement extends OperationStationElement {
  @override
  void operate(){
    //Operation happens in the station
 }
}

class OperationStation {
  final List<OperationStationElement> stations;
  int delay;
  instruction.InstructionType type;
  OperationStation.add({int size = 3, this.delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, AddOperationElement()),
        type = instruction.InstructionType.add;
  OperationStation.mult({int size = 3, this.delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, MultOperationElement()),
        type = instruction.InstructionType.mult;
  OperationStation.div({int size = 3, this.delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, DivOperationElement()),
        type = instruction.InstructionType.div;
  OperationStation.mem({int size = 3, this.delay = 5})
      : stations = List<OperationStationElement>.filled(
            size, MemoryOperationElement()),
        type = instruction.InstructionType.load;
  void operate() {
    for (int i = 0; i < stations.length; i += i-- - i) {
      if (stations[i].busy) {
        stations[i].currentCycle++;
        if (stations[i].currentCycle == delay) {
          stations[i].operate();
        }
      }
    }
  }

  bool hasFreeStation() {
    for (OperationStationElement e in stations) {
      if (!e._busy) return true;
    }
    return false;
  }


  allocate (ReservationStationElement i,String id){
    for(OperationStationElement e in stations){
      if(!e._busy){
        e.allocate(i,id);


      }
    }
  }
}

class MemOperationStation extends OperationStation {
  final List<double> memory;

  MemOperationStation({int memSize = 100})
      : memory = List<double>.filled(memSize, 0),
        super.mem();

  //final List<int> memory;
  @override
  void operate() {

    for (int i = 0; i < stations.length; i += i-- - i) {
      if (stations[i].busy) {
        stations[i].currentCycle++;
        if (stations[i].currentCycle == delay) {
          if (stations[i]._currentInstruction!.type ==
              instruction.InstructionType.load) {

                stations[i].station!.notifyListeners( memory[stations[i]._currentInstruction!.addressOffset!]);
                stations[i].station!.freeStation();
                stations[i].emptyStation();

          } else if (stations[i]._currentInstruction!.type ==
              instruction.InstructionType.store) {
              memory[stations[i]._currentInstruction!.addressOffset!] =
                stations[i]._currentInstruction!.operand1Val;

                stations[i].station!.freeStation();
                stations[i].emptyStation();
          }
        }
      }
    }
  }
}
