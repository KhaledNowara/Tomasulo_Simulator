
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


   void operate();
  void emptyStation() {
    currentCycle = 0;
    _busy = false;
    notifyMostafasListeners();
  }
  void allocate(ReservationStationElement i, String id) {
    station = i;
    _currentInstruction = i.currentInstruction;
    _busy = true;
    currentCycle = 0;
    stationID = id;
    notifyMostafasListeners();
  }

@override
  String toString (){
    return('busy : $busy, $_currentInstruction');
  }
 


  
}

class AddOperationElement extends OperationStationElement {
  
  @override
  void operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.add ){
        station!.notifyListeners(_currentInstruction!.operand1Val + _currentInstruction!.operand1Val);   
        station!.freeStation();
        emptyStation();
        notifyMostafasListeners();

      }else
     throw Exception('Invalid Instruction');
    }else
    throw Exception('Instruction not found');
  }
}

class MultOperationElement extends OperationStationElement {
  
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
      else{
        throw Exception('Invalid Instruction');
      }
    }else{
      throw Exception('Instruction not found');
    }
  }
}
class DivOperationElement extends OperationStationElement {
  
 @override
  void operate(){
    // should be throwing errors or some shit
    if(_currentInstruction !=null && _busy){
      if(_currentInstruction!.type == instruction.InstructionType.div ){
        station!.notifyListeners(_currentInstruction!.operand1Val / _currentInstruction!.operand1Val);  
        station!.freeStation();
        emptyStation(); 
        notifyMostafasListeners();
      }else
      throw Exception('Invalid Instruction');
    }else
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
  List<OperationStationElement> stations;
  int delay;
  instruction.InstructionType type;
  OperationStation.add({int size = 3, this.delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, AddOperationElement()),
        type = instruction.InstructionType.add {fillListAdd();}
  OperationStation.mult({int size = 3, this.delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, MultOperationElement()),
        type = instruction.InstructionType.mult{fillListMult();}
  OperationStation.div({int size = 3, this.delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, DivOperationElement()),
        type = instruction.InstructionType.div{fillListDiv();}
  OperationStation.mem({int size = 3, this.delay = 5})
      : stations = List<OperationStationElement>.filled(
            size, MemoryOperationElement()),
        type = instruction.InstructionType.load{fillListMem();}
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
@override
  String toString() {
    String s = '';
    for(OperationStationElement e in stations){
      s += e.toString();
      s += '\n'; 
    }
    s += '............';
    return s;
  }
 void fillListMem (){
    List<MemoryOperationElement> l  = <MemoryOperationElement>[];
    for(OperationStationElement e in stations ){
       l.add(MemoryOperationElement());
    }
    stations = l;
  }
void fillListAdd (){
    List<OperationStationElement> l  = <OperationStationElement>[];
    for(OperationStationElement e in stations ){
       l.add(AddOperationElement());
      
    }
    stations = l;
  }
  void fillListMult (){
    List<OperationStationElement> l  = <OperationStationElement>[];
    for(OperationStationElement e in stations ){
       l.add(MultOperationElement());
    }
    stations = l;
  }
    void fillListDiv (){
    List<OperationStationElement> l  = <OperationStationElement>[];
    for(OperationStationElement e in stations ){
       l.add(DivOperationElement());
    }
    stations = l;
  }
  bool hasFreeStation() {
    for (OperationStationElement e in stations) {
      if (!e._busy) return true;
    }
    return false;
  }


  bool allocate (ReservationStationElement i,String id){
    bool allocated = false;
    for(OperationStationElement e in stations){
      if(!e._busy){
        e.allocate(i,id);
        allocated =  true;
      }
    }
    return allocated;
  }

  void onClockTick (){
    operate();
    print(toString());
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
