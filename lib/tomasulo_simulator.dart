import 'instruction.dart';
import 'register.dart';
import 'reservation_station.dart';


//initialize thingies, its 7 am in the night, my comments are not going to make a lot of sense 
ReservationStation addStation = ReservationStation.add();
ReservationStation multStation = ReservationStation.mult();
ReservationStation divStation = ReservationStation.div();


bool issueInstruction (Instruction i ){
  return addStation.allocate(i) || multStation.allocate(i)|| divStation.allocate(i);
  
}

void regCall (){

}
void main(){

}