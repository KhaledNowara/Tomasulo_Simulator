import 'instruction.dart' as instruction;
import 'operation_station.dart' as operation_station;

abstract class ReservationStationElement {
  bool _busy = false;
  bool get busy => _busy;
  instruction.Instruction? _currentInstruction;
  bool _ready = false ;
  bool get ready => _ready;
  void checkReady ();
 
  void FreeStation(){
    _busy = false;
    _ready = false;
  }
  void allocate (instruction.Instruction i ){
    _currentInstruction = i;
    _busy = true;
    checkReady(); 
   }

  // Listener thingies 
  
}

class AluReservationElement extends ReservationStationElement{
  @override
  void checkReady (){
    if (_currentInstruction != null){
      _ready = _currentInstruction!.operand1ID == null && _currentInstruction!.operand2ID == null;  
    }
  }

}

class MemoryReservationElement extends ReservationStationElement{
  @override
  void checkReady (){
    if (_currentInstruction != null){
      _ready = _currentInstruction!.operand1ID == null;  
    }
  }
}

class ReservationStation {
  operation_station.OperationStation functionalUnit;
  instruction.InstructionType type; 
  List<ReservationStationElement> stations;
  ReservationStation.add({int size = 3,int funitSize = 3,int funitDelay = 5}): stations =List<ReservationStationElement>.filled(size,AluReservationElement()),
  functionalUnit= operation_station.OperationStation.add(size :funitSize,delay: funitDelay ),
  type = instruction.InstructionType.add;  

  ReservationStation.mult({int size = 3,int funitSize = 3,int funitDelay = 5}): stations =List<ReservationStationElement>.filled(size,AluReservationElement()),
  functionalUnit= operation_station.OperationStation.mult(size :funitSize,delay: funitDelay ),
  type = instruction.InstructionType.mult;  

  ReservationStation.div({int size = 3,int funitSize = 3,int funitDelay = 5}): stations =List<ReservationStationElement>.filled(size,AluReservationElement()),
  functionalUnit= operation_station.OperationStation.div(size :funitSize,delay: funitDelay ),
  type = instruction.InstructionType.div;  



  // ReservationStation.memory({int size = 3}): stations =List<ReservationStationElement>.filled(size,MemoryReservationElement());  
  
  void execReady (){
    for(int i = 0;i< stations.length;i+=i---i){
      if (stations[i].ready){
        if (functionalUnit.hasFreeStation()){
          functionalUnit.allocate(stations[i]._currentInstruction!);
          stations[i].FreeStation();
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