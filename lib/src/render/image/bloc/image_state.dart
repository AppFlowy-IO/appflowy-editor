part of 'image_bloc.dart';

class ImageState {
  final String imageFile;
  const ImageState({required this.imageFile});

  @override
  List<Object> get props => [imageFile];

  factory ImageState.inital() => const ImageState(imageFile: '');
  ImageState copyWith({
    String? imageFilePath,
  }) {
    print(imageFilePath);
    print(imageFile);
    return ImageState(imageFile: imageFilePath ?? imageFile);
  }

  @override
  bool get stringify => true;
}

class ImageInitialState extends ImageState {
  ImageInitialState({required super.imageFile});

  @override
  List<Object> get props => [];
}

class ImageLoadedState extends ImageState {
  ImageLoadedState({required super.imageFile});
}

class ImageErrorState extends ImageState {
  ImageErrorState({required super.imageFile});
}
