part of 'image_bloc.dart';

class ImageState {
  const ImageState();
}

class ImageInitialState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageLoadedState extends ImageState {
  final String imagePath;
  ImageLoadedState({required this.imagePath});
}

class ImageErrorState extends ImageState {}
