// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';

class Rechenmauer {
  List<List<int>> data;
  Random rand;
  dynamic sub_button;
  InputElement calc_upto;
  InputElement max_levels;
  DivElement content;
  int levels, maxval;

  Rechenmauer() {
    calc_upto = querySelector("#calc_upto");
    max_levels = querySelector("#max_levels");
    content = querySelector("#content");
    sub_button = ((querySelector("#new_game") as ButtonElement)
        .onClick
        .listen((event) => InitMauer()));
    rand = new Random(322124);
  }

  void UnbindDom() {
    sub_button.cancel();
  }

  void validateInput(Event ev) {
    var target = ev.target as InputElement;
    var splits = target.id.split('_');
    target.classes.clear();
    if (target.value != "") if (data[int.parse(splits[0])]
            [int.parse(splits[1])] ==
        target.valueAsNumber)
      target.classes.add("correct");
    else
      target.classes.add("wrong");
  }

  void initDom([bool debug = false]) {
    content.children.clear();
    for (int row = 0; row < levels; row++) {
      int picked_pos = rand.nextInt(row + 1);
      var par_elem = new ParagraphElement();
      content.children.add(par_elem);
      for (int col = 0; col <= row; col++) {
        var inp_elem = new NumberInputElement();
        if (picked_pos == col || debug) {
          inp_elem.valueAsNumber = data[row][col];
          inp_elem.readOnly = true;
          inp_elem.classes.add("correct");
        }
        inp_elem.min = "0";
        inp_elem.max = maxval.toString();
        inp_elem.id = row.toString() + "_" + col.toString();
        if (!debug) inp_elem.onInput.listen(validateInput);
        par_elem.children.add(inp_elem);
      }
    }
  }

  int factorial(int n, int k) {
    int value = 1;
    for (int i = 0; i < k; i++) {
      value *= (n - i);
      value ~/= (i + 1);
    }
    return value;
  }

  void InitMauer() {
    maxval = calc_upto.valueAsNumber;
    levels = max_levels.valueAsNumber;

    data = new List<List<int>>(levels);
    for (int i = 0; i < levels; i++) {
      data[i] = new List<int>(levels);
      data[i].fillRange(0, levels - 1, -37);
    }

    int remain = maxval;
    int left_pos = (levels - 1) ~/ 2;
    int right_pos = (levels - 1) ~/ 2;

    int fact = factorial(levels - 1, left_pos);

    data[levels - 1][left_pos] = rand.nextInt(maxval ~/ fact);
    remain -= fact * data[levels - 1][left_pos];

    while ((left_pos > 0) || (right_pos < levels - 1)) {
      if (right_pos < levels - 1) {
        right_pos++;
        fact = factorial(levels - 1, right_pos);
        data[levels - 1][right_pos] = rand.nextInt(remain ~/ fact);
        remain -= data[levels - 1][right_pos] * fact;
      }
      if (left_pos > 0) {
        left_pos--;
        fact = factorial(levels - 1, left_pos);
        data[levels - 1][left_pos] = rand.nextInt(remain ~/ fact);
        remain -= data[levels - 1][left_pos] * fact;
      }
    }
    for (int i = levels - 2; i >= 0; i--) {
      for (int j = 0; j <= i; j++) {
        data[i][j] = data[i + 1][j] + data[i + 1][j + 1];
      }
    }
    initDom();
  }
}

void main() {
  var rm = new Rechenmauer();
}
