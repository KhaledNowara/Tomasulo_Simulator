import 'instruction.dart' as instruction;

class Register {
  double value = 0;
  instruction.Instruction? waitingOn;
}

Register boo = Register();

// Use the setter method for x.
