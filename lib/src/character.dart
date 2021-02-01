class IntegerGenerationException implements Exception {}

class Character {
  Character._();

  static int getInteger(String value) {
    assert(value != null && value != '');
    try {
      final onlyNumerics = _replaceCharToNumeric(value);
      final onlyNumericsFixed = onlyNumerics.length > 10
          ? onlyNumerics.substring(1, 10)
          : onlyNumerics;

      return int.parse(onlyNumericsFixed);
    } catch (e) {
      throw IntegerGenerationException();
    }
  }

  static String _replaceCharToNumeric(String value) {
    assert(value != null && value != '');
    var unionStr = '';
    void _union(int value) => unionStr = '$unionStr$value';

    value.runes.forEach(_union);

    return unionStr;
  }
}
