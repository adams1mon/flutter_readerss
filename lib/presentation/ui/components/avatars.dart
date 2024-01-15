import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';

// TODO: set default image so it doesn't break
class Avatar extends StatelessWidget {
  const Avatar({super.key, required image, width = 40.0})
      : _image = image,
        _width = width;

  final Image _image;
  final double _width;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: _width / 2,
      foregroundImage: _image.image,
    );
  }
}

class UserAvatar extends Avatar {
  UserAvatar({super.key, required String? imageUrl})
      : super(
          image: imageUrl != null
              ? Image.network(imageUrl)
              : Image.asset("assets/avatar.jpg"),
          width: userAvatarWidth,
        );
}

class FeedAvatar extends Avatar {
  FeedAvatar({super.key, required String? imageUrl})
      : super(
          image: imageUrl != null ? Image.network(imageUrl) : defaultFeedImage,
          width: feedAvatarWidth,
        );
}
