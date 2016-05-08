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
    rand = new Random();
  }

  void UnbindDom() {
    sub_button.cancel();
  }

  int balancedRandom(int maxval) =>
      rand.nextInt(maxval ~/ 2 + 1) + (maxval ~/ 2);

  void validateInput(Event ev) {
    var target = ev.target as InputElement;
    var splits = target.id.split('_');
      target.classes.clear();
      if (target.value != "")
    if (data[int.parse(splits[0])][int.parse(splits[1])] ==
        target.valueAsNumber)
      target.classes.add("correct");
    else
      target.classes.add("wrong");
  }

  void initDom() {
    content.children.clear();
    for (int row = 0; row < levels; row++) {
      int picked_pos = rand.nextInt(row + 1);
      var par_elem = new ParagraphElement();
      content.children.add(par_elem);
      for (int col = 0; col <= row; col++) {
        var inp_elem = new NumberInputElement();
        if (picked_pos == col) {
          inp_elem.valueAsNumber = data[row][col];
          inp_elem.readOnly = true;
          inp_elem.classes.add("correct");
        }
        inp_elem.min = 0;
        inp_elem.max = maxval;
        inp_elem.id = row.toString() + "_" + col.toString();
        inp_elem.onInput.listen(validateInput);
        par_elem.children.add(inp_elem);
      }
    }
  }

  void InitMauer() {
    maxval = int.parse(calc_upto.value);
    levels = int.parse(max_levels.value);

    data = new List<List<int>>(levels);
    for (int i = 0; i < levels; i++) data[i] = new List<int>(levels);
    for (int i = 0; i < levels; i++) data[i].fillRange(0, i, -1);

    data[0][0] = rand.nextInt(maxval+1);
    int minimum_pos = 0;

    for (int row = 1; row < levels; row++) {
      var picked_pos = minimum_pos + rand.nextInt(2);
      // data[row][picked_pos] = rand.nextInt(data[row - 1][minimum_pos] + 1);
      data[row][picked_pos] = balancedRandom(data[row - 1][minimum_pos]);
      for (int col = picked_pos - 1; col >= 0; col--)
        data[row][col] = data[row - 1][col] - data[row][col + 1];
      for (int col = picked_pos + 1; col <= row; col++)
        data[row][col] = data[row - 1][col - 1] - data[row][col - 1];

      int min_value = 99999;
      for (int col = 0; col <= row; col++)
        if (data[row][col] < min_value) {
        min_value = data[row][col];
        minimum_pos = col;
      }
    }
    initDom();
  }
}

void main() {
  var rm = new Rechenmauer();
}
