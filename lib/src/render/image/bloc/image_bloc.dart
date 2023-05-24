import 'package:file_picker/file_picker.dart';
import "package:flutter_bloc/flutter_bloc.dart";

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageSelectedEvent, ImageState> {
  ImageBloc() : super(ImageState.inital()) {
    on<ImageSelectedEvent>((event, emit) async {
      final imageFile = (await FilePicker.platform.pickFiles())?.files.first;
      emit(ImageState(imageFile: state.imageFile + imageFile.toString()));
    });
  }
}
