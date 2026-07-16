import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class OwnerEvent extends Equatable {
  const OwnerEvent();

  @override
  List<Object?> get props => [];
}

class GetMyCarsEvent extends OwnerEvent {}

class AddCarEvent extends OwnerEvent {
  final String name;
  final String brand;
  final double pricePerDay;
  final String type;
  final String fuelType;
  final String transmission;
  final String location;
  final String description;
  final int seats;
  final XFile carImage;
  final XFile docFrontImage;
  final XFile docBackImage;

  const AddCarEvent({
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.type,
    required this.fuelType,
    required this.transmission,
    required this.location,
    required this.description,
    required this.seats,
    required this.carImage,
    required this.docFrontImage,
    required this.docBackImage,
  });

  @override
  List<Object?> get props => [
        name,
        brand,
        pricePerDay,
        type,
        fuelType,
        transmission,
        location,
        description,
        seats,
        carImage,
        docFrontImage,
        docBackImage,
      ];
}

class DeleteCarEvent extends OwnerEvent {
  final String carId;
  const DeleteCarEvent(this.carId);
  @override
  List<Object?> get props => [carId];
}

class UpdateCarStatusEvent extends OwnerEvent {
  final String carId;
  final String status;
  const UpdateCarStatusEvent(this.carId, this.status);
  @override
  List<Object?> get props => [carId, status];
}
