import 'dart:mirrors';

import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';

const nonIterableBuiltins = [int, double, String, bool, Record, Map, Symbol, null];

String spaces(int depth) {
  return "    " * depth;
}

void printFieldsAndValues(dynamic object) {
  printFieldsAndValuesRec(object, 0);
}

void printFieldsAndValuesRec(dynamic object, int depth) {
  final clazz = reflect(object);

  clazz.type.declarations.forEach((symbol, declaration) {
    if (declaration is VariableMirror) {

      final fieldType = declaration.type.reflectedType;
      final fieldName = MirrorSystem.getName(symbol);

      final decl = '$fieldName: $fieldType';
    
      final fieldReflectee = clazz.getField(symbol).reflectee;

      print('${spaces(depth)} $decl: $fieldReflectee');

      if (fieldReflectee is Enum || fieldReflectee is DateTime) {
        return;
      }

      // iterate through iterables, call recursively
      if (fieldReflectee is Iterable) {
        print('${spaces(depth)} $decl is an iterable, iterating through its values');
        fieldReflectee.forEach((element) {
          printFieldsAndValuesRec(element, depth + 1);
        });
        return;
      } 
      
      // call recursively for non standard types
      if (!nonIterableBuiltins.contains(fieldType)) {
        print('${spaces(depth)} $decl is not a standard type, calling recursively');
        if (fieldReflectee != null) {
          printFieldsAndValuesRec(fieldReflectee, depth + 1);
        }
        return;
      }
    } 
  });  
}

void main() async {

  final rssUri = Uri.parse('https://feeds.bbci.co.uk/news/world/europe/rss.xml');
  final res = await http.get(rssUri);
  if (res.statusCode != 200) {
    print('Failed to fetch rss');
    return;
  }
  // print(res.body);

  var rssFeed = RssFeed.parse(res.body); // for parsing RSS feed

  printFieldsAndValues(rssFeed);
}