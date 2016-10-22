// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:charcode/charcode.dart';

import '../util/character.dart';
import 'parser.dart';

/// A parser for `@keyframes` block selectors.
class KeyframeSelectorParser extends Parser {
  KeyframeSelectorParser(String contents, {url}) : super(contents, url: url);

  List<String> parse() {
    return wrapSpanFormatException(() {
      whitespace();

      var selectors = <String>[];
      do {
        if (lookingAtIdentifier()) {
          if (scanIdentifier("from")) {
            selectors.add("from");
          } else {
            expectIdentifier("to", name: '"to" or "from"');
            selectors.add("to");
          }
        } else {
          selectors.add(_percentage());
        }
        whitespace();
      } while (scanner.scanChar($comma));

      return selectors;
    });
  }

  String _percentage() {
    var buffer = new StringBuffer();
    if (scanner.scanChar($plus)) buffer.writeCharCode($plus);

    var second = scanner.peekChar();
    if (!isDigit(second) && second != $dot) {
      scanner.error("Expected number.");
    }

    while (isDigit(scanner.peekChar())) {
      buffer.writeCharCode(scanner.readChar());
    }

    if (scanner.peekChar() == $dot) {
      buffer.writeCharCode(scanner.readChar());

      while (isDigit(scanner.peekChar())) {
        buffer.writeCharCode(scanner.readChar());
      }
    }

    if (scanIdentifier("e", ignoreCase: true)) {
      buffer.write(scanner.readChar());
      var next = scanner.peekChar();
      if (next == $plus || next == $minus) buffer.write(scanner.readChar());
      if (!isDigit(scanner.peekChar())) scanner.error("Expected digit.");

      while (isDigit(scanner.peekChar())) {
        buffer.writeCharCode(scanner.readChar());
      }
    }

    scanner.expectChar($percent);
    buffer.writeCharCode($percent);
    return buffer.toString();
  }
}