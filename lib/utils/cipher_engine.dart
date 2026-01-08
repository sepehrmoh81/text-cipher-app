// Cipher Engine - Direct port from Python
import 'dart:math';

class CipherEngine {
  static final Random _random = Random();

  static const Map<String, List<String>> _enToFaMap = {
    // Lowercase letters
    'a': ['اا', 'اب', 'اپ'],
    'b': ['ات', 'اث', 'اج'],
    'c': ['اچ', 'اح', 'اخ'],
    'd': ['اد', 'اذ', 'ار'],
    'e': ['از', 'اژ', 'اس'],
    'f': ['اش', 'اص', 'اض'],
    'g': ['اط', 'اظ', 'اع'],
    'h': ['اغ', 'اف', 'اق'],
    'i': ['اک', 'اگ', 'ال'],
    'j': ['ام', 'ان', 'او'],
    'k': ['اه', 'ای', 'آآ'],
    'l': ['آب', 'آپ', 'آت'],
    'm': ['آث', 'آج', 'آچ'],
    'n': ['آح', 'آخ', 'آد'],
    'o': ['آذ', 'آر', 'آز'],
    'p': ['آژ', 'آس', 'آش'],
    'q': ['آص', 'آض', 'آط'],
    'r': ['آظ', 'آع', 'آغ'],
    's': ['آف', 'آق', 'آک'],
    't': ['آگ', 'آل', 'آم'],
    'u': ['آن', 'آو', 'آه'],
    'v': ['آی', 'بب', 'بپ'],
    'w': ['بت', 'بث', 'بج'],
    'x': ['بچ', 'بح', 'بخ'],
    'y': ['بد', 'بذ', 'بر'],
    'z': ['بز', 'بژ', 'بس'],

    // Uppercase letters
    'A': ['بشش', 'بصص', 'بضض'],
    'B': ['بطط', 'بظظ', 'بعع'],
    'C': ['بغغ', 'بفف', 'بقق'],
    'D': ['بکک', 'بگگ', 'بلل'],
    'E': ['بمم', 'بنن', 'بوو'],
    'F': ['بهه', 'بیی', 'پاا'],
    'G': ['پبب', 'پپپ', 'پتت'],
    'H': ['پثث', 'پجج', 'پچچ'],
    'I': ['پحح', 'پخخ', 'پدد'],
    'J': ['پذذ', 'پرر', 'پزز'],
    'K': ['پژژ', 'پسس', 'پشش'],
    'L': ['پصص', 'پضض', 'پطط'],
    'M': ['پظظ', 'پعع', 'پغغ'],
    'N': ['پفف', 'پقق', 'پکک'],
    'O': ['پگگ', 'پلل', 'پمم'],
    'P': ['پنن', 'پوو', 'پهه'],
    'Q': ['پیی', 'تاا', 'تبب'],
    'R': ['تپپ', 'تتت', 'تثث'],
    'S': ['تجج', 'تچچ', 'تحح'],
    'T': ['تخخ', 'تدد', 'تذذ'],
    'U': ['ترر', 'تزز', 'تژژ'],
    'V': ['تسس', 'تشش', 'تصص'],
    'W': ['تضض', 'تطط', 'تظظ'],
    'X': ['تعع', 'تغغ', 'تفف'],
    'Y': ['تقق', 'تکک', 'تگگ'],
    'Z': ['تلل', 'تمم', 'تنن'],

    // Digits
    '0': ['توو', 'تهه', 'تیی'],
    '1': ['ثاا', 'ثبب', 'ثپپ'],
    '2': ['ثتت', 'ثثث', 'ثجج'],
    '3': ['ثچچ', 'ثحح', 'ثخخ'],
    '4': ['ثدد', 'ثذذ', 'ثرر'],
    '5': ['ثزز', 'ثژژ', 'ثسس'],
    '6': ['ثشش', 'ثصص', 'ثضض'],
    '7': ['ثطط', 'ثظظ', 'ثعع'],
    '8': ['ثغغ', 'ثفف', 'ثقق'],
    '9': ['ثکک', 'ثگگ', 'ثلل'],

    // Common punctuation
    ' ': ['ثمم', 'ثنن', 'ثوو'],
    '.': ['ثهه', 'ثیی', 'جاا'],
    ',': ['جبب', 'جپپ', 'جتت'],
    '!': ['جثث', 'ججج', 'جچچ'],
    '?': ['جحح', 'جخخ', 'جدد'],
    '-': ['جذذ', 'جرر', 'جزز'],
    ':': ['جژژ', 'جسس', 'جشش'],
    ';': ['جصص', 'جضض', 'جطط'],
    "'": ['جظظ', 'جعع', 'جغغ'],
    '"': ['جفف', 'جقق', 'جکک'],
    '(': ['جگگ', 'جلل', 'جمم'],
    ')': ['جنن', 'جوو', 'جهه'],
    '/': ['جیی', 'چاا', 'چبب'],
    '\\': ['چپپ', 'چتت', 'چثث'],
    '@': ['چجج', 'چچچ', 'چحح'],
    '#': ['چخخ', 'چدد', 'چذذ'],
    '\$': ['چرر', 'چزز', 'چژژ'],
    '%': ['چسس', 'چشش', 'چصص'],
    '&': ['چضض', 'چطط', 'چظظ'],
    '*': ['چعع', 'چغغ', 'چفف'],
  };

  // Build reverse mapping
  static final Map<String, String> _faToEnMap = _buildReverseMap();

  static Map<String, String> _buildReverseMap() {
    final reverseMap = <String, String>{};
    _enToFaMap.forEach((enChar, faSequences) {
      for (final faSeq in faSequences) {
        reverseMap[faSeq] = enChar;
      }
    });
    return reverseMap;
  }

  static String encodeToPersian(String text) {
    final encoded = StringBuffer();
    for (final char in text.split('')) {
      if (_enToFaMap.containsKey(char)) {
        final sequences = _enToFaMap[char]!;
        final chosen = sequences[_random.nextInt(sequences.length)];
        encoded.write(chosen);
      } else {
        encoded.write(char);
      }
    }
    return encoded.toString();
  }

  static String decodeFromPersian(String text) {
    final decoded = StringBuffer();
    int i = 0;

    // Find max sequence length
    int maxSeqLength = 0;
    for (final seq in _faToEnMap.keys) {
      if (seq.length > maxSeqLength) {
        maxSeqLength = seq.length;
      }
    }

    while (i < text.length) {
      bool matched = false;

      // Try matching from longest to shortest
      for (int length = maxSeqLength; length > 0; length--) {
        if (i + length <= text.length) {
          final substring = text.substring(i, i + length);
          if (_faToEnMap.containsKey(substring)) {
            decoded.write(_faToEnMap[substring]);
            i += length;
            matched = true;
            break;
          }
        }
      }

      if (!matched) {
        decoded.write(text[i]);
        i++;
      }
    }

    return decoded.toString();
  }
}