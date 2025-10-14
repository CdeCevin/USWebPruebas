import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:video_player/video_player.dart';

void _showMediaPopup({
  required BuildContext context,
  required List<String> urls,
  required IconData icon,
  required String title,
  required Widget Function(String url) buildWidget,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 36.0),
                    SizedBox(width: 8.0),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: urls.map((url) => buildWidget(url)).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: BotonGenerico(
                    text: 'Cerrar',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    widthFactor: 0.3,
                    heightFactor: 0.05,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class DialogUtils {
  static void showPhotoPopup(BuildContext context, List<String> imageUrls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo, size: 36.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Imagenes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            imageUrls
                                .map((url) => _buildImageWidget(url))
                                .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BotonGenerico(
                      text: 'Cerrar',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      widthFactor: 0.3,
                      heightFactor: 0.05,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showVideoPopup(BuildContext context, List<String> videoUrls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library, size: 36.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Videos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            videoUrls
                                .map((url) => _buildVideoWidget(url))
                                .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BotonGenerico(
                      text: 'Cerrar',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      widthFactor: 0.3,
                      heightFactor: 0.05,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildImageWidget(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Image.network(
        url,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error);
        },
      ),
    );
  }

  static Widget _buildVideoWidget(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: VideoPlayerWidget(url: url),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
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
