import 'package:flutter/material.dart';

class FeedItem {
  final String title;
  final String? description;
  final String link;
  final String? author;
  final Image? sourceIcon;

  final DateTime? pubDate;

  final int views;
  final int likes;

  FeedItem({
    required this.title,
    this.description,
    required this.link,
    this.author,
    this.sourceIcon,
    this.pubDate,
    required this.views,
    required this.likes,
  });
}