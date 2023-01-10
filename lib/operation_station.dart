import 'instruction.dart' as instruction;

abstract class OperationStationElement {
  List<Function()> MostafsListeners = <Function()>[];
  int currentCycle = 0;
  bool _busy = false;
  instruction.Instruction? _currentInstruction;
  String? stationID;
  bool get busy => _busy;
  // notify listners somewhere
  double operate();
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

class AddOperationElement extends OperationStationElement {
  @override
  double operate() {
    // should be throwing errors or some shit
    if (_currentInstruction != null && _busy) {
      if (_currentInstruction!.type == instruction.InstructionType.add) {
        notifyMostafasListeners();
        return _currentInstruction!.operand1Val +
            _currentInstruction!.operand1Val;
      }
      return -1;
    }
    return -1;
  }
}

class MultOperationElement extends OperationStationElement {
  @override
  double operate() {
    // should be throwing errors or some shit
    if (_currentInstruction != null && _busy) {
      if (_currentInstruction!.type == instruction.InstructionType.mult) {
        notifyMostafasListeners();
        return _currentInstruction!.operand1Val *
            _currentInstruction!.operand1Val;
      }
      return -1;
    }
    return -1;
  }
}

class DivOperationElement extends OperationStationElement {
  @override
  double operate() {
    // should be throwing errors or some shit
    if (_currentInstruction != null && _busy) {
      if (_currentInstruction!.type == instruction.InstructionType.mult) {
        notifyMostafasListeners();
        return _currentInstruction!.operand1Val /
            _currentInstruction!.operand1Val;
      }
      return -1;
    }
    return -1;
  }
}

class MemoryOperationElement extends OperationStationElement {
  @override
  double operate() {
    // TODO: implement operate
    throw UnimplementedError();
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

  allocate(instruction.Instruction i, String id) {
    for (OperationStationElement e in stations) {
      if (!e._busy) {
        e.allocate(i, id);
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
    double result = 0.0;
    for (int i = 0; i < stations.length; i += i-- - i) {
      if (stations[i].busy) {
        stations[i].currentCycle++;
        if (stations[i].currentCycle == delay) {
          if (stations[i]._currentInstruction!.type ==
              instruction.InstructionType.load) {
            result = memory[stations[i]._currentInstruction!.addressOffset!];
            stations[i].notifyMostafasListeners();
            // publish result
          } else if (stations[i]._currentInstruction!.type ==
              instruction.InstructionType.store) {
            memory[stations[i]._currentInstruction!.addressOffset!] =
                stations[i]._currentInstruction!.operand1Val;
            stations[i].notifyMostafasListeners();
          }
        }
      }
    }
  }
}
