import 'package:flutter/material.dart';

// for the settings page
class FeedSource {

  final String title;
  final String? description;
  final String link;

  final Image? image;
  final int ttl;

  FeedSource({
    required this.title,
    this.description,
    required this.link,
    this.image,
    this.ttl = 10,
  });
}