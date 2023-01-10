import 'dart:collection';

import 'package:tomasulo_simulator/tomasulo_simulator.dart';

import 'instruction.dart' as instruction;
import 'register.dart';

import 'operation_station.dart' as operation_station;
import 'package:tuple/tuple.dart';

abstract class ReservationStationElement {
  final String ID;
  bool _busy = false;
  bool get busy => _busy;
  instruction.Instruction? _currentInstruction;
  instruction.Instruction? get currentInstruction => _currentInstruction;
  bool _ready = false ;
  bool get ready => _ready;
  List<Function(double)> listeners = <Function(double)>[];
  List<Function()> MostafsListeners = <Function()>[];
  RegisterFile registers;

  ReservationStationElement(this.ID,this.registers);
  void checkReady ();

  instruction.InstructionType? getType (){
    return _currentInstruction?.type;
  }
 
  void freeStation (){
    _busy = false;
    _ready = false;
    notifyMostafasListeners();
  }

  void allocate(instruction.Instruction i) {
    _currentInstruction = i;
    _busy = true;
    checkReady();
    notifyMostafasListeners();
  }

  void addListener(Function(double) f) {
    listeners.add(f);
  }

  void addMostafasListener(Function() f) {
    MostafsListeners.add(f);
  }

  void notifyListeners(double data) {
    for (Function(double) f in listeners) {
      f(data);
      removeListner(f);
    }
  }

  void notifyMostafasListeners() {
    for (Function() f in MostafsListeners) {
      f();
    }
  }

  void removeMostafsListner(Function(String) f) {
    MostafsListeners.remove(f);
  }

  void removeListner(Function(double) f) {
    listeners.remove(f);
  }

  void listenFirstOperand(double data) {
    if (_currentInstruction != null) {
      _currentInstruction!.operand1Val = data;
      _currentInstruction!.operand1ID = null;
      notifyMostafasListeners();
      checkReady();
    }
  }

  void listenSecondOperand(double data) {
    if (_currentInstruction != null) {
      _currentInstruction!.operand2Val = data;
      _currentInstruction!.operand2ID = null;
      notifyMostafasListeners();
      checkReady();
    }
  }

  void getData();
}


class AddressUnit extends ReservationStationElement{
MemoryBuffer loadBuffer;
MemoryBuffer storeBuffer;
int? address;

  AddressUnit(super.ID, super.registers,this.loadBuffer, this.storeBuffer); 


  @override
  void checkReady() {
      _ready = _currentInstruction!.operand2ID !=null;
  }

  @override
  void getData() {
         Tuple2<double,String?> res  = registers.getRegister(_currentInstruction!.operand2Reg!, listenSecondOperand); 
          _currentInstruction!.operand2Val = res.item1;
          _currentInstruction!.operand2ID = res.item2;
          
  }
  @override
  void listenSecondOperand (double data){
    if (_currentInstruction!=null){
      _currentInstruction!.operand2Val = data;
      _currentInstruction!.operand2ID = null;
      address = (data + _currentInstruction!.addressOffset!).round();
      checkReady();
      issue(); 

    }
  }

  void issue (){
    switch (_currentInstruction!.type){
      case instruction.InstructionType.load :issueLoad(); break;
      case instruction.InstructionType.store :issueStore(); break;
      
      case instruction.InstructionType.add:
        // TODO: Handle this case.
        break;
      case instruction.InstructionType.sub:
        // TODO: Handle this case.
        break;
      case instruction.InstructionType.mult:
        // TODO: Handle this case.
        break;
      case instruction.InstructionType.div:
        // TODO: Handle this case.
        break;
      case instruction.InstructionType.load:
        // TODO: Handle this case.
        break;
      case instruction.InstructionType.store:
        // TODO: Handle this case.
        break;
    }
  }
  bool issueStore (){
    if(!storeBuffer.checkConflict(address!) &&loadBuffer.checkConflict(address!)){
      return storeBuffer.allocate(_currentInstruction!);
    }
    return false;
  }
  bool issueLoad (){
    if (!storeBuffer.checkConflict(address!)){
      return loadBuffer.allocate(_currentInstruction!);
    }
    return false;

  }

}
class AluReservationElement extends ReservationStationElement{
  AluReservationElement(super.ID,super.registers);

  @override
  void checkReady() {
    if (_currentInstruction != null) {
      _ready = _currentInstruction!.operand1ID == null &&
          _currentInstruction!.operand2ID == null;
    }
  }

  @override
   void getData (){
          registers.waitOn(_currentInstruction!.target!, ID, addListener);
          Tuple2<double,String?>  res  = registers.getRegister(_currentInstruction!.operand1Reg!, listenFirstOperand); 
          _currentInstruction!.operand1Val = res.item1;
          _currentInstruction!.operand1ID = res.item2;
          res  = registers.getRegister(_currentInstruction!.operand2Reg!, listenSecondOperand); 
          _currentInstruction!.operand2Val = res.item1;
          _currentInstruction!.operand2ID = res.item2;
          checkReady();
   }

}

abstract class MemoryOperationElement extends ReservationStationElement {
    double? address;

  MemoryOperationElement(super.ID, super.registers);
    
    
}
class LoadReservationElement extends MemoryOperationElement{

  LoadReservationElement(super.ID,super.registers);

  @override
  void checkReady (){
  }


  @override
   void getData (){
          registers.waitOn(_currentInstruction!.target!, ID, addListener);
          _ready = true; 
   }

}
class StoreReservationElement extends MemoryOperationElement{
  StoreReservationElement(super.ID,super.registers);


  @override
  void checkReady() {
    if (_currentInstruction != null) {
      _ready = _currentInstruction!.operand1ID == null;
    }
  }

  @override

   void getData (){
          Tuple2<double,String?>  res  = registers.getRegister(_currentInstruction!.operand1Reg!, listenFirstOperand); 
          _currentInstruction!.operand1Val = res.item1;
          _currentInstruction!.operand1ID = res.item2;
          checkReady();
   }

}

class ReservationStation {
  operation_station.OperationStation functionalUnit;
  instruction.InstructionType type;
  List<ReservationStationElement> stations;

  RegisterFile registers; 
  static int IDCounter = -1; 
  ReservationStation.add({int size = 3,int funitSize = 3,int funitDelay = 5,required this.registers}): stations =List<ReservationStationElement>.filled(size,addStationFill(registers)),
  functionalUnit= operation_station.OperationStation.add(size :funitSize,delay: funitDelay ),
  
  type = instruction.InstructionType.add;  

  ReservationStation.mult({int size = 3,int funitSize = 3,int funitDelay = 5,required this.registers}): stations =List<ReservationStationElement>.filled(size,multStationFill(registers)),
  functionalUnit= operation_station.OperationStation.mult(size :funitSize,delay: funitDelay ),
  type = instruction.InstructionType.mult;  

  ReservationStation.div({int size = 3,int funitSize = 3,int funitDelay = 5,required this.registers}): stations =List<ReservationStationElement>.filled(size,divStationFill(registers)),
  functionalUnit= operation_station.OperationStation.div(size :funitSize,delay: funitDelay ),
  type = instruction.InstructionType.div;  

  ReservationStation.load({int size = 3,required this.functionalUnit,required this.registers}): stations =List<ReservationStationElement>.empty(),
  type = instruction.InstructionType.load;

  ReservationStation.store({int size = 3,required this.functionalUnit,required this.registers}): stations =List<ReservationStationElement>.empty(),
  type = instruction.InstructionType.load;  

  static ReservationStationElement addStationFill (RegisterFile r){

    IDCounter++;
    return AluReservationElement('A$IDCounter', r);
  }

  static ReservationStationElement multStationFill(RegisterFile r) {
    IDCounter++;
    return AluReservationElement('M$IDCounter', r);
  }

  static ReservationStationElement divStationFill(RegisterFile r) {
    IDCounter++;
    return AluReservationElement('D$IDCounter', r);
  }



  
  void execReady (){
    for(int i = 0;i< stations.length;i+=i---i){
      if (stations[i].ready){
        if (functionalUnit.hasFreeStation()){
          functionalUnit.allocate(stations[i],stations[i].ID);


  void execReady() {
    for (int i = 0; i < stations.length; i += i-- - i) {
      if (stations[i].ready) {
        if (functionalUnit.hasFreeStation()) {
          functionalUnit.allocate(
              stations[i]._currentInstruction!, stations[i].ID);
        }
      }
    }
  }

  bool allocate(instruction.Instruction i) {
    if (i.type != type) return false;
    for (ReservationStationElement e in stations) {
      if (!e._busy) {
        e.allocate(i);
        return true;
      }
    }
    return false;
  }

}
class MemoryBuffer extends ReservationStation{
  List<MemoryOperationElement> real_stations;

  MemoryBuffer.load({int size = 3,required super.functionalUnit, required super.registers}) :real_stations =List<MemoryOperationElement>.filled(size,loadStationFill(registers)), super.load();
  MemoryBuffer.store({int size = 3,required super.functionalUnit, required super.registers}) : real_stations =List<MemoryOperationElement>.filled(size,storeStationFill(registers)),super.store();

  static MemoryOperationElement loadStationFill (RegisterFile r){
    ReservationStation.IDCounter++;
    return LoadReservationElement('L$ReservationStation.IDCounter',r);
  }
  static MemoryOperationElement storeStationFill (RegisterFile r){
    ReservationStation.IDCounter++;
    return StoreReservationElement('S$ReservationStation.IDCounter',r);
  }  
  
  bool checkConflict (int c_address){
    for(MemoryOperationElement e in real_stations){
      if (e.address ==c_address){
        return true;
      }
    }
    return false;
  }
}

