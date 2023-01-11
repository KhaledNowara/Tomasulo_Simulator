import 'package:flutter/cupertino.dart';

import 'instruction.dart' as instruction;
import 'reservation_station.dart';

abstract class OperationStationElement extends ChangeNotifier {
  int currentCycle = 0;
  bool _busy = false;
  ReservationStationElement? station;
  instruction.Instruction? _currentInstruction;
  String? stationID;
  bool get busy => _busy;
  // notify listners somewhere

  void operate();
  void emptyStation() {
    currentCycle = 0;
    _busy = false;
    notifyListeners();
  }

  void allocate(ReservationStationElement i, String id) {
    station = i;
    _currentInstruction = i.currentInstruction;
    _busy = true;
    currentCycle = 0;
    stationID = id;
    notifyListeners();
  }

  @override
  String toString() {
    return ('busy : $busy, $_currentInstruction');
  }
}

class AddOperationElement extends OperationStationElement {
  @override
  void operate() {
    // should be throwing errors or some shit
    if (_currentInstruction != null && _busy) {
      if (_currentInstruction!.type == instruction.InstructionType.add) {
        station!.notifyDataListeners(_currentInstruction!.operand1Val +
            _currentInstruction!.operand1Val);
        station!.freeStation();
        emptyStation();
        notifyListeners();
      } else if (_currentInstruction!.type == instruction.InstructionType.sub) {
        station!.notifyDataListeners(_currentInstruction!.operand1Val -
            _currentInstruction!.operand1Val);
        station!.freeStation();
        emptyStation();
        notifyListeners();
      } else
        throw Exception(
            'Invalid Instruction ' + _currentInstruction!.type.toString());
    } else
      throw Exception('Instruction not found');
  }
}

class MultOperationElement extends OperationStationElement {
  @override
  void operate() {
    // should be throwing errors or some shit
    if (_currentInstruction != null && _busy) {
      if (_currentInstruction!.type == instruction.InstructionType.mult) {
        station!.notifyDataListeners(_currentInstruction!.operand1Val *
            _currentInstruction!.operand1Val);
        station!.freeStation();
        emptyStation();
        notifyListeners();
      } else if (_currentInstruction!.type == instruction.InstructionType.div) {
        station!.notifyDataListeners(_currentInstruction!.operand1Val /
            _currentInstruction!.operand2Val);
        station!.freeStation();
        emptyStation();
        notifyListeners();
      } else {
        throw Exception('Invalid Instruction');
      }
    } else {
      throw Exception('Instruction not found');
    }
  }
}

class MemoryOperationElement extends OperationStationElement {
  @override
  void operate() {
    //Operation happens in the station
  }
}

class OperationStation {
  List<OperationStationElement> stations;
  int delay;
  instruction.InstructionType type;
  OperationStation.add({int size = 3, delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, AddOperationElement()),
        type = instruction.InstructionType.add,
        this.delay = delay + 1 {
    fillListAdd();
  }
  OperationStation.mult({int size = 3, delay = 5})
      : stations =
            List<OperationStationElement>.filled(size, MultOperationElement()),
        type = instruction.InstructionType.mult,
        this.delay = delay + 1 {
    fillListMult();
  }

  OperationStation.mem({int size = 3, int delay = 5})
      : stations = List<OperationStationElement>.filled(
            size, MemoryOperationElement()),
        type = instruction.InstructionType.load,
        this.delay = delay + 1 {
    fillListMem();
  }
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
    for (OperationStationElement e in stations) {
      s += e.toString();
      s += '\n';
    }
    s += '............';
    return s;
  }

  void fillListMem() {
    List<MemoryOperationElement> l = <MemoryOperationElement>[];
    for (OperationStationElement e in stations) {
      l.add(MemoryOperationElement());
    }
    stations = l;
  }

  void fillListAdd() {
    List<OperationStationElement> l = <OperationStationElement>[];
    for (OperationStationElement e in stations) {
      l.add(AddOperationElement());
    }
    stations = l;
  }

  void fillListMult() {
    List<OperationStationElement> l = <OperationStationElement>[];
    for (OperationStationElement e in stations) {
      l.add(MultOperationElement());
    }
    stations = l;
  }

  bool hasFreeStation() {
    for (OperationStationElement e in stations) {
      if (!e._busy) return true;
    }
    return false;
  }

  bool allocate(ReservationStationElement i, String id) {
    bool allocated = false;
    for (OperationStationElement e in stations) {
      if (!e._busy) {
        e.allocate(i, id);
        allocated = true;
        break;
      }
    }
    return allocated;
  }

  void onClockTick() {
    operate();
  }
}

class MemOperationStation extends OperationStation {
  final List<double> memory;

  MemOperationStation({int memSize = 100, super.delay = 2})
      : memory = List<double>.filled(memSize, 0),
        super.mem() {
    double value = 0;
    for (int i = 0; i < memory.length; i++) {
      memory[i] = value;
      value++;
    }
  }

  @override
  void onClockTick() {
    operate();
  }

  //final List<int> memory;
  @override
  void operate() {
    for (int i = 0; i < stations.length; i += i-- - i) {
      if (stations[i].busy) {
        stations[i].currentCycle++;
        if (stations[i].currentCycle == delay) {
          int address = (stations[i]._currentInstruction!.addressOffset! +
                  stations[i]._currentInstruction!.operand2Val)
              .round();
          if (address >= memory.length) {
            String s = stations[i]._currentInstruction.toString();
            throw Exception("Index out of bounds of the memory, $s");
          }
          if (stations[i]._currentInstruction!.type ==
              instruction.InstructionType.load) {
            stations[i].station!.notifyDataListeners(memory[address]);
            stations[i].station!.freeStation();
            stations[i].emptyStation();
          } else if (stations[i]._currentInstruction!.type ==
              instruction.InstructionType.store) {
            memory[address] = stations[i]._currentInstruction!.operand1Val;

            stations[i].station!.freeStation();
            stations[i].emptyStation();
          }
        }
      }
    }
  }
}
