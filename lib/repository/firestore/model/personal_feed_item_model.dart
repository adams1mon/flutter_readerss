
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalFeedItemModel {
  final String feedItemId;
  final bool liked;
  final bool bookmarked;

  PersonalFeedItemModel({
    required this.feedItemId,
    required this.liked,
    required this.bookmarked,
  });

  factory PersonalFeedItemModel.fromFirebaseDoc(
    DocumentSnapshot<Map<String, dynamic>> firebaseDoc,
  ) {
    
    return PersonalFeedItemModel(
      feedItemId: firebaseDoc.get("feedItemId"),
      bookmarked: firebaseDoc.data()?.containsKey("bookmarked") == true ? firebaseDoc.get("bookmarked") : false,
      liked: firebaseDoc.data()?.containsKey("liked") == true ? firebaseDoc.get("liked") : false,
    );
  }

  Map<String, dynamic> toFirestoreDoc() {
    return <String, dynamic>{
      "feedItemId": feedItemId,
      if (liked) "liked": true,
      if (bookmarked) "bookmarked": true,
    };
  }
}