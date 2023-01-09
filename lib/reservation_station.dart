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
  bool _ready = false ;
  bool get ready => _ready;
  List<Function(double)> listeners = <Function(double)>[];
  RegisterFile registers;
  ReservationStationElement(this.ID,this.registers);
  void checkReady ();
 
  void freeStation (){
    _busy = false;
    _ready = false;
  }
  void allocate (instruction.Instruction i ){
    _currentInstruction = i;
    _busy = true;
    checkReady(); 
   }

  void addListener (Function(double) f ){
    listeners.add(f);
  }
  void notifyListeners (double data){
    for(Function(double) f in listeners){
      f(data);
    }
  }
  void removeListner (Function(double) f){
    listeners.remove(f);
  }
  void listenFirstOperand (double data){
    if (_currentInstruction!=null){
      _currentInstruction!.operand1Val = data;
      _currentInstruction!.operand1ID = null;
      checkReady();

    }
  }
    void listenSecondOperand (double data){
    if (_currentInstruction!=null){
      _currentInstruction!.operand2Val = data;
      _currentInstruction!.operand2ID = null;
      checkReady();

    }
  }
  void getData ();

  
}

class AluReservationElement extends ReservationStationElement{
  AluReservationElement(super.ID,super.registers);

  @override
  void checkReady (){
    if (_currentInstruction != null){
      _ready = _currentInstruction!.operand1ID == null && _currentInstruction!.operand2ID == null;  
    }
  }

  @override
   void getData (){
          registers.waitOn(_currentInstruction!.target, ID, addListener);
          Tuple2<double,String?>  res  = registers.getRegister(_currentInstruction!.operand1Reg, listenFirstOperand); 
          _currentInstruction!.operand1Val = res.item1;
          _currentInstruction!.operand1ID = res.item2;
          res  = registers.getRegister(_currentInstruction!.operand2Reg!, listenSecondOperand); 
          _currentInstruction!.operand2Val = res.item1;
          _currentInstruction!.operand2ID = res.item2;
          checkReady();
   }

}

class MemoryReservationElement extends ReservationStationElement{
  MemoryReservationElement(super.ID,super.registers);

  @override
  void checkReady (){
    if (_currentInstruction != null){
      _ready = _currentInstruction!.operand1ID == null;  
    }
  }


  @override
   void getData (){
          registers.waitOn(_currentInstruction!.target, ID, addListener);
          Tuple2<double,String?>  res  = registers.getRegister(_currentInstruction!.operand1Reg, listenFirstOperand); 
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


  static ReservationStationElement addStationFill (RegisterFile r){
    IDCounter++;
    return AluReservationElement('A$IDCounter',r);
  }

   static ReservationStationElement multStationFill (RegisterFile r){
    IDCounter++;
    return AluReservationElement('M$IDCounter',r);
  }  
  static ReservationStationElement divStationFill (RegisterFile r){
    IDCounter++;
    return AluReservationElement('D$IDCounter',r);
  }  

  // ReservationStation.memory({int size = 3}): stations =List<ReservationStationElement>.filled(size,MemoryReservationElement());  
  
  void execReady (){
    for(int i = 0;i< stations.length;i+=i---i){
      if (stations[i].ready){
        if (functionalUnit.hasFreeStation()){
          functionalUnit.allocate(stations[i]._currentInstruction!,stations[i].ID);
          stations[i].freeStation();
        }
      }
    }
  }



  bool allocate (instruction.Instruction i){
    if (i.type != type) return false ; 
    for(ReservationStationElement e in stations){
      if(!e._busy){
       e.allocate(i);
       return true;
      }
    }
    return false;
  }


}