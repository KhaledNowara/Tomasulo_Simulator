import 'instruction.dart' as instruction;

abstract class OperationStationElement {
  int currentCycle = 0;
  bool _busy = false;
  instruction.Instruction? _currentInstruction;
  bool get busy => _busy;
  // notify listners somewhere
   double operate();
   void emptyStation(){
    currentCycle = 0;
    _busy = false;
   }
   void allocate (instruction.Instruction i ){
    _currentInstruction = i;
    _busy = true;
    currentCycle = 0;
   }
}
class AddOperationElemnt extends OperationStationElement {
  
  @override
  double operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.add ){
        return _currentInstruction!.operand1Val + _currentInstruction!.operand1Val;   
      }
      return -1;
    }
      return -1;

  }
}

class MultOperationElemnt extends OperationStationElement {
  
  @override
  double operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.add ){
        return _currentInstruction!.operand1Val * _currentInstruction!.operand1Val;   
      }
      return -1;
    }
      return -1;

  }
}
class DivOperationElemnt extends OperationStationElement {
  
  @override
  double operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.add ){
        return _currentInstruction!.operand1Val / _currentInstruction!.operand1Val;   
      }
      return -1;
    }
      return -1;

  }
}
class OperationStation {
  final List<OperationStationElement> stations;
  int delay ;
  instruction.InstructionType type; 
  OperationStation.add({int size = 3, this.delay = 5}): stations =List<OperationStationElement>.filled(size,AddOperationElemnt()),type = instruction.InstructionType.add;  
  OperationStation.mult({int size = 3, this.delay = 5}): stations =List<OperationStationElement>.filled(size,MultOperationElemnt()),type = instruction.InstructionType.mult;  
  OperationStation.div({int size = 3, this.delay = 5}): stations =List<OperationStationElement>.filled(size,DivOperationElemnt()),type = instruction.InstructionType.div;  

  void operate(){
    for (int i = 0 ; i < stations.length; i+= i---i){
      if (stations[i].busy){
        stations[i].currentCycle ++;
        if (stations[i].currentCycle == delay){
          stations[i].operate();
        }
      
      }

    }
  }

  bool hasFreeStation (){
    for(OperationStationElement e in stations){
      if(!e._busy) return true ;
    }
    return false;

  }

  allocate (instruction.Instruction i){
    for(OperationStationElement e in stations){
      if(!e._busy){
        e.allocate(i);

      }
    }
  }

}