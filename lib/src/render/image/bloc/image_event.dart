part of 'image_bloc.dart';

abstract class ImageEvent {
  const ImageEvent();

  @override
  List<Object> get props => [];
}

class ImageSelectedEvent extends ImageEvent {
  const ImageSelectedEvent();
  @override
  List<Object> get props => [];
}
