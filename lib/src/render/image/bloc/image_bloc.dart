import "package:flutter_bloc/flutter_bloc.dart";
import 'package:file_picker/file_picker.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageSelectedEvent, ImageState> {
  ImageBloc() : super(ImageInitialState()) {
    on<ImageSelectedEvent>((event, emit) async {
      final imageFile = (await FilePicker.platform.pickFiles())?.files.first;
      emit(ImageLoadedState(imagePath: imageFile!.path.toString()));
    });
  }
}
