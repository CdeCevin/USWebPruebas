import 'package:flutter/material.dart';
import 'package:urbansensor/widgets/boton_generico.dart';


class BotonesMultimedia extends StatelessWidget {
  final List<String> imageUrls;
  final List<String> videoUrls;
  final VoidCallback onShowPhotoPopup;
  final VoidCallback onShowVideoPopup;

  BotonesMultimedia({
    required this.imageUrls,
    required this.videoUrls,
    required this.onShowPhotoPopup,
    required this.onShowVideoPopup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (videoUrls.isNotEmpty)
            BotonGenerico(
              text: '',
              icon: Icon(Icons.video_library),
              iconColor: Colors.white,
              widthFactor: 0.2,
              heightFactor: 0.055,
              onPressed: onShowVideoPopup,
            ),
          SizedBox(width: videoUrls.isNotEmpty ? 16.0 : 0),
          BotonGenerico(
            text: '',
            icon: Icon(Icons.photo),
            iconColor: Colors.white,
            widthFactor: 0.2,
            heightFactor: 0.055,
            onPressed: onShowPhotoPopup,
          ),
        ],
      ),
    );
  }
}









