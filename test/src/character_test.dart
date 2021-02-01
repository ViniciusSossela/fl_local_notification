import 'package:fl_local_notification/src/character.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate same int from string', () async {
    final id = '845a0078-fb80-4195-94d1-b72eab1249d9';
    final id1 = Character.getInteger(id);
    final id2 = Character.getInteger(id);
    expect(id1, id2);
  });
  test('generate different int from string', () async {
    final fakeId1 = '845a0078-fb80-4195-94d1-b72eab1249d9';
    final fakeId2 = '312312';
    final fakeId3 = '845a1078-fb80-4195-94d1-b72eab1249d9';
    final fakeId4 = '99999999-9b80-4195-94d1-b72eab1249d9';
    final fakeId5 = 'ZZZZZZZZ-ZZ80-4195-94d1-b72eab1249d9';
    final id1 = Character.getInteger(fakeId1);
    final id2 = Character.getInteger(fakeId2);
    final id3 = Character.getInteger(fakeId3);
    final id4 = Character.getInteger(fakeId4);
    final id5 = Character.getInteger(fakeId5);
    expect(id1 != id2, true);
    expect(id1 != id3, true);
    expect(id4 != id3, true);
    expect(id4 != id5, true);
  });
  test('generate int from null string', () async {
    expect(() => Character.getInteger(null), throwsAssertionError);
  });
  test('generate int from empty string', () async {
    expect(() => Character.getInteger(''), throwsAssertionError);
  });
}
