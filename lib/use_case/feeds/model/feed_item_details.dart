
// user-specific feed item details
class FeedItemDetails {
  String feedItemId;
  bool liked;
  bool bookmarked;

  FeedItemDetails(
      {required this.feedItemId,
      required this.liked,
      required this.bookmarked});
}