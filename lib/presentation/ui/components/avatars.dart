
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
  const UserAvatar({super.key, required image})
      : super(image: image, width: userAvatarWidth);
}

class FeedAvatar extends Avatar {
  const FeedAvatar({super.key, required image})
      : super(image: image, width: feedAvatarWidth);
}