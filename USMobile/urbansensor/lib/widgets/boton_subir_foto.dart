import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class SubirFoto extends StatefulWidget {
  final Function(List<XFile>) onFilesChanged;
  final List<String> camposDinamicos;

  SubirFoto({
    required this.onFilesChanged,
    required this.camposDinamicos,
  });

  @override
  _SubirFotoState createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _files = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _optionsDialogBox(),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.fromARGB(255, 234, 236, 240),
                width: 2.0,
              ),
              color: Color.fromARGB(255, 29, 53, 91),
            ),
            child: Icon(
              Icons.photo_camera,
              color: Color.fromARGB(255, 230, 233, 236),
              size: 30,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(
              color: Color.fromARGB(255, 234, 236, 240),
              width: 2.0,
            ),
            color: Color.fromARGB(255, 29, 53, 91),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: _files.isEmpty ? null : () => _showFilesPopup(),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo,
                  color: Color.fromARGB(255, 230, 233, 236),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Ver',
                  style: TextStyle(
                    color: Color.fromARGB(255, 230, 233, 236),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _optionsDialogBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (widget.camposDinamicos.contains('Imagen'))
                  GestureDetector(
                    child: Text('Tomar foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _openCamera(isImage: true);
                    },
                  ),
                if (widget.camposDinamicos.contains('Video'))
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                if (widget.camposDinamicos.contains('Video'))
                  GestureDetector(
                    child: Text('Grabar video'),
                    onTap: () {
                      Navigator.pop(context);
                      _openCamera(isImage: false);
                    },
                  ),
                if (widget.camposDinamicos.contains('Imagen'))
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                if (widget.camposDinamicos.contains('Imagen'))
                  GestureDetector(
                    child: Text('Seleccionar fotos de galería'),
                    onTap: () {
                      Navigator.pop(context);
                      _openGallery(isImage: true, multiSelect: true);
                    },
                  ),
                if (widget.camposDinamicos.contains('Video'))
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                if (widget.camposDinamicos.contains('Video'))
                  GestureDetector(
                    child: Text('Seleccionar video de galería'),
                    onTap: () {
                      Navigator.pop(context);
                      _openGallery(isImage: false, multiSelect: false);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openGallery({required bool isImage, bool multiSelect = false}) async {
    if (_files.length >= 5) {
      _showLimitReachedDialog();
      return;
    }

    List<XFile> selectedFiles = [];

    if (isImage && multiSelect) {
      selectedFiles = await _picker.pickMultiImage() ?? [];
    } else {
      final XFile? file = await (isImage
          ? _picker.pickImage(source: ImageSource.gallery)
          : _picker.pickVideo(source: ImageSource.gallery));
      if (file != null) {
        selectedFiles = [file];
      }
    }

    selectedFiles.removeWhere(
        (file) => _files.any((existingFile) => existingFile.path == file.path));

    if (selectedFiles.isNotEmpty) {
      setState(() {
        _files.addAll(selectedFiles);
      });
      widget.onFilesChanged(_files);
    }
  }

  void _openCamera({required bool isImage}) async {
    if (_files.length >= 5) {
      _showLimitReachedDialog();
      return;
    }

    final XFile? file = await (isImage
        ? _picker.pickImage(source: ImageSource.camera)
        : _picker.pickVideo(source: ImageSource.camera));
    if (file != null) {
      setState(() {
        _files.add(file);
      });
      widget.onFilesChanged(_files);
    }
  }

  void _showFilesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: _files.isEmpty
              ? Text('No hay archivos disponibles')
              : Container(
                  width: double.maxFinite,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: _files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _showFullScreenMedia(index),
                            child: _files[index].path.endsWith('.mp4')
                                ? AspectRatio(
                                    aspectRatio: 1,
                                    child:
                                        VideoPlayerWidget(file: _files[index]),
                                  )
                                : Image.file(
                                    File(_files[index].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _files.removeAt(index);
                                });
                                widget.onFilesChanged(_files);
                                Navigator.of(context).pop();
                                _showFilesPopup();
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          actionsAlignment:
              MainAxisAlignment.center, // Center align the actions
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF3B69AE), // Background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12), // Padding
              ),
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenMedia(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMedia(file: _files[index]),
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Límite alcanzado'),
          content: Text('No puedes subir más de 5 archivos.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class FullScreenMedia extends StatelessWidget {
  final XFile file;

  FullScreenMedia({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: file.path.endsWith('.mp4')
            ? VideoPlayerWidget(file: file)
            : Image.file(File(file.path)),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final XFile file;

  VideoPlayerWidget({required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }
}
