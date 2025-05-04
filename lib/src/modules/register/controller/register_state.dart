import 'package:equatable/equatable.dart';
import 'package:keezy/src/modules/register/model/registro_model.dart';

abstract class RegisterState extends Equatable {}

class RegisterInitial extends RegisterState {
  @override
  List<Object?> get props => [];
}

class RegisterLoading extends RegisterState {
 

@override
List<Object?> get props => [];
}

class RegisterLoaded extends RegisterState {
  late final List<RegisterModel> register;
  RegisterLoaded({required this.register});

  @override
  List<RegisterModel> get props => register;
}


class RegisterError extends RegisterState {
  final String message;

  RegisterError(this.message);
  
  @override
  List<Object?> get props => [message];
}