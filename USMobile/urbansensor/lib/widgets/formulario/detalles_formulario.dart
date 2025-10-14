import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:urbansensor/config/config.dart';

Widget buildDetailWidget({
  required String text,
  required int index,
  required List<String> imageUrls,
  required List<String> videoUrls,
  required AudioPlayer audioPlayer,
}) {
  bool isLatitude(String str) {
    final num? value = num.tryParse(str);
    return value != null && value >= -90 && value <= 90;
  }

  bool isLongitude(String str) {
    final num? value = num.tryParse(str);
    return value != null && value >= -180 && value <= 180;
  }

  bool isImageFile(String str) {
    final imageExtensions = ['.jpg', '.png', '.jpeg', '.gif'];
    return imageExtensions.any((ext) => str.toLowerCase().endsWith(ext));
  }

  bool isAudioFile(String str) {
    return str.toLowerCase().contains('/media/audio_');
  }

  bool isVideoFile(String str) {
    final videoExtensions = ['.mp4', '.mov', '.avi'];
    return videoExtensions.any((ext) => str.toLowerCase().endsWith(ext));
  }

  String buildFullUrl(String partialUrl) {
    return '${Config.baseUrl}$partialUrl';
  }

  if (isImageFile(text)) {
    imageUrls.add(buildFullUrl(text));
    return SizedBox.shrink();
  } else if (isAudioFile(text)) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              audioPlayer.play(UrlSource(buildFullUrl(text)));
            },
          ),
          Text('Reproducir audio'),
        ],
      ),
    );
  } else if (isVideoFile(text)) {
    videoUrls.add(buildFullUrl(text));
    return SizedBox.shrink();
  } else if (index == 6 && isLatitude(text)) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16.0),
        _buildTextWithDivider('Latitud:', text),
      ],
    );
  } else if (index == 7 && isLongitude(text)) {
    return _buildTextWithDivider('Longitud:', text);
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (index == 0)
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Detalles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
          ),
        FractionallySizedBox(widthFactor: 0.9, child: Text(text)),
      ],
    );
  }
}

Widget _buildTextWithDivider(String title, String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FractionallySizedBox(
        widthFactor: 0.9,
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ),
      SizedBox(height: 2.0),
      FractionallySizedBox(widthFactor: 0.9, child: Text(text)),
      FractionallySizedBox(widthFactor: 0.9, child: Divider()),
    ],
  );
}
