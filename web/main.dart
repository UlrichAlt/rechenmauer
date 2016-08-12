// Copyright (c) 2016, Ulrich Alt All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library rechenmauer;

import 'dart:html';
import 'dart:math';

/// Webapp for Rechenmauern
class Rechenmauer {
  /// The data for the tiles.
  List<List<int>> data;

  /// DOM reference to calUpTo field
  InputElement calcUpTo;

  /// DOM reference to maxLevels field
  InputElement maxLevels;

  /// DOM reference to Content.
  DivElement content;

  /// DOM attribute name for correct value.
  static const String domAttributeName = "correct_value";

  /// Constructor empty.
  Rechenmauer();

  /// Create DOM bindings
  void bindToDom() {
    calcUpTo = querySelector("#calc_upto");
    maxLevels = querySelector("#max_levels");
    maxLevels.onInput.listen((Event ev) => updateCalcUpto());
    content = querySelector("#content");
    querySelector("#new_game").onClick.listen((Event ev) => initMauer());
  }

  /// Update Max Value field depending on number of levels
  void updateCalcUpto() {
    int minimum =
        factorial(maxLevels.valueAsNumber - 1, maxLevels.valueAsNumber ~/ 2) *
            2;
    calcUpTo.min = minimum.toString();
    if (!calcUpTo.checkValidity()) calcUpTo.valueAsNumber = minimum;
  }

  /// Update style class if entered guess is correct or not.
  void validateInput(Event ev) {
    InputElement target = ev.target;
    target.classes.clear();
    if (target.value != "" &&
        target.getAttribute(domAttributeName) == target.value)
      target.classes.add("correct");
    else
      target.classes.add("wrong");
  }

  /// Create and initialize DOM nodes with correct values.
  void initDom(int levels, [bool debug = false]) {
    Random rand = new Random();
    content.children.clear();
    for (int row = 0; row < levels; row++) {
      int pickedPos = rand.nextInt(row + 1);
      ParagraphElement parElem = new ParagraphElement();
      content.children.add(parElem);
      for (int col = 0; col <= row; col++) {
        NumberInputElement inpElem = new NumberInputElement();
        if (pickedPos == col || debug) {
          inpElem.valueAsNumber = data[row][col];
          inpElem.readOnly = true;
          inpElem.classes.add("correct");
        }
        inpElem.min = "0";
        inpElem.setAttribute(domAttributeName, data[row][col].toString());
        inpElem.max = calcUpTo.value;
        if (!debug) inpElem.onInput.listen(validateInput);
        parElem.children.add(inpElem);
      }
    }
  }

  /// Compute binomial coefficient (n over k).
  int factorial(int n, int k) {
    int value = 1;
    for (int i = 0; i < k; i++) {
      value *= (n - i);
      value ~/= (i + 1);
    }
    return value;
  }

  /// Compute values of tiles.
  void initMauer() {
    Random rand = new Random();
    int maxval = calcUpTo.valueAsNumber;
    int levels = maxLevels.valueAsNumber;

    data = new List<List<int>>(levels);
    for (int i = 0; i < levels; i++) data[i] = new List<int>(levels);

    int remain = maxval;
    int leftPos = (levels - 1) ~/ 2;
    int rightPos = (levels - 1) ~/ 2;

    int fact = factorial(levels - 1, leftPos);

    if (maxval >= fact * 2) {
      data[levels - 1][leftPos] = rand.nextInt(maxval ~/ fact);

      remain -= fact * data[levels - 1][leftPos];

      while ((leftPos > 0) || (rightPos < levels - 1)) {
        if (rightPos < levels - 1) {
          rightPos++;
          fact = factorial(levels - 1, rightPos);
          data[levels - 1][rightPos] = rand.nextInt(remain ~/ fact);
          remain -= data[levels - 1][rightPos] * fact;
        }
        if (leftPos > 0) {
          leftPos--;
          fact = factorial(levels - 1, leftPos);
          data[levels - 1][leftPos] = rand.nextInt(remain ~/ fact);
          remain -= data[levels - 1][leftPos] * fact;
        }
      }
      for (int i = levels - 2; i >= 0; i--) {
        for (int j = 0; j <= i; j++) {
          data[i][j] = data[i + 1][j] + data[i + 1][j + 1];
        }
      }
      initDom(levels);
    } else
      window.alert("Bitte wähle einen größeren Wert bei Rechnen bis");
  }
}

void main() {
  Rechenmauer rm = new Rechenmauer();
  rm.bindToDom();
}
