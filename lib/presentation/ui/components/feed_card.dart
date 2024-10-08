import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_readrss/presentation/ui/components/avatars.dart';
import 'package:flutter_readrss/presentation/ui/components/utils.dart';
import 'package:flutter_readrss/use_case/feeds/model/feed_item.dart';
import 'package:flutter_readrss/presentation/ui/styles/styles.dart';
import 'package:share_plus/share_plus.dart';

import '../const/screen_route.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.feedItem,
    required this.toggleBookmarked,
    required this.toggleLiked,
    required this.increaseViewCount,
    required this.isLoggedIn,
  });

  final FeedItem feedItem;
  final void Function() toggleBookmarked;
  final void Function() toggleLiked;
  final void Function() increaseViewCount;
  final bool Function() isLoggedIn;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  var _expanded = false;

  void toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void toggleBookmarked() {
    if (!widget.isLoggedIn()) {
      showAuthDialog(context, "You must be logged in to bookmark an item");
    }
    setState(() {
      widget.toggleBookmarked();
    });
  }

  void toggleLiked() {
    if (!widget.isLoggedIn()) {
      showAuthDialog(context, "You must be logged in to like an item.");
    }
    setState(() {
      widget.toggleLiked();
    });
  }

  void shareFeedItem() async {
    try {
      final uri = Uri.parse(widget.feedItem.articleUrl);
      await Share.shareUri(uri);
    } catch (e) {
      log("[UI] FeedCard: error while trying to share feed item", error: e);
      snackbarMessage(context, "Error while trying to share...");
    }
  }

  void navigateToWebViewPage() {
    widget.increaseViewCount();
    log("navigating to the article's web page");
    Navigator.of(context).pushNamed(
      ScreenRoute.webview.route,
      arguments: widget.feedItem.articleUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FeedCardHeader(
              feedItem: widget.feedItem,
              bookmarked: widget.feedItem.bookmarked,
              toggleBookmarked: toggleBookmarked,
              expanded: _expanded,
              toggleExpanded: toggleExpanded,
            ),
            FeedCardBody(
              feedItem: widget.feedItem,
              expanded: _expanded,
              toggleLiked: toggleLiked,
              openUrlInWebView: navigateToWebViewPage,
              shareFeedItem: shareFeedItem,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedCardHeader extends StatelessWidget {
  const FeedCardHeader(
      {super.key,
      required this.feedItem,
      required this.bookmarked,
      required this.toggleBookmarked,
      required this.expanded,
      required this.toggleExpanded});

  final FeedItem feedItem;
  final bool bookmarked;
  final void Function() toggleBookmarked;
  final bool expanded;
  final void Function() toggleExpanded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpanded,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                FeedAvatar(imageUrl: feedItem.sourceIconUrl),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Text(
                    feedItem.feedSourceTitle,
                    style: textTheme(context).bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: toggleBookmarked,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: colors(context).primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: toggleExpanded,
                  child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: colors(context).primary,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedCardBody extends StatelessWidget {
  const FeedCardBody({
    super.key,
    required this.feedItem,
    required this.expanded,
    required this.toggleLiked,
    required this.openUrlInWebView,
    required this.shareFeedItem,
  });

  final FeedItem feedItem;
  final bool expanded;
  final void Function() toggleLiked;
  final void Function() openUrlInWebView;
  final void Function() shareFeedItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4, right: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: GestureDetector(
              onTap: openUrlInWebView,
              child: Text(
                feedItem.title,
                style: textTheme(context)
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: expanded ? 4 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: FeedCardBodyExpandedSection(
                feedItem: feedItem,
                toggleLiked: toggleLiked,
                shareFeedItem: shareFeedItem,
              ),
            ),
          if (feedItem.pubDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Text(
                    feedItem.getDate(),
                    style: textTheme(context)
                        .bodySmall
                        ?.copyWith(color: colors(context).secondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FeedCardBodyExpandedSection extends StatelessWidget {
  const FeedCardBodyExpandedSection({
    super.key,
    required this.feedItem,
    required this.toggleLiked,
    required this.shareFeedItem,
  });

  final FeedItem feedItem;
  final void Function() toggleLiked;
  final void Function() shareFeedItem;

  bool feedItemHasDescription() {
    return feedItem.description != null && feedItem.description!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (feedItemHasDescription())
          Text(
            feedItem.description ?? "",
            style: textTheme(context).bodyMedium,
            maxLines: 20,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${feedItem.views} views",
              style: textTheme(context)
                  .bodySmall
                  ?.copyWith(color: colors(context).secondary),
            ),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: shareFeedItem,
                  icon: Icon(
                    Icons.share,
                    color: colors(context).primary,
                  ),
                ),
                const SizedBox(width: 8,),
                TextButton.icon(
                  icon: Icon(
                    feedItem.liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: colors(context).primary,
                  ),
                  label: Text(
                    "${feedItem.likes}",
                    style: textTheme(context).bodyMedium?.copyWith(
                        color: colors(context).primary,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: toggleLiked,
                  style: TextButton.styleFrom(
                    backgroundColor: colors(context)
                        .primary
                        .withOpacity(feedItem.liked ? 0.1 : 0.08),
                    foregroundColor: colors(context).primary,
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
