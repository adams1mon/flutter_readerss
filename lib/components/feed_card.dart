import 'package:flutter/material.dart';
import 'package:flutter_readrss/components/avatars.dart';
import 'package:flutter_readrss/model/feed_item.dart';
import 'package:flutter_readrss/styles/styles.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.feedItem,
    required this.toggleBookmarked,
  });

  final FeedItem feedItem;
  final void Function() toggleBookmarked;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  var _expanded = false;
  var _liked = false;

  void toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void toggleBookmarked() {
    setState(() {
      widget.toggleBookmarked();
    });
  }

  void toggleLiked() {
    // TODO: call liking service
    setState(() => _liked = !_liked);
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
              liked: _liked,
              toggleLiked: toggleLiked,
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
                FeedAvatar(image: feedItem.sourceIcon),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Text(
                    feedItem.feedSourceTitle,
                    style: textTheme(context)
                        .bodyMedium,
                        // ?.copyWith(fontWeight: FontWeight.bold),
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
    required this.liked,
    required this.toggleLiked,
  });

  final FeedItem feedItem;
  final bool expanded;
  final bool liked;
  final void Function() toggleLiked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4, right: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              feedItem.title,
              style: textTheme(context).bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: expanded ? 4 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: FeedCardBodyExpandedSection(
                  feedItem: feedItem, liked: liked, toggleLiked: toggleLiked),
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
    required this.liked,
    required this.toggleLiked,
  });

  final FeedItem feedItem;
  final bool liked;
  final void Function() toggleLiked;

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
            TextButton.icon(
              icon: Icon(
                liked ? Icons.thumb_up : Icons.thumb_up_outlined,
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
                backgroundColor:
                    colors(context).primary.withOpacity(liked ? 0.1 : 0.08),
                foregroundColor: colors(context).primary,
              ),
            )
          ],
        )
      ],
    );
  }
}
