import 'package:countersink/domain/formulas.dart';
import 'package:countersink/models/counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a total adds every counter up', () {
    expect(calculate(Formula.sum, first: 12, others: [8, 5]), 25);
    expect(calculate(Formula.sum, first: 12), 12);
    expect(calculate(Formula.sum, first: null, others: [8, 5]), 13);
    expect(calculate(Formula.sum, first: null), 0);
  });

  test('a total starts from the number it already stood at', () {
    expect(calculate(Formula.sum, first: 12, others: [8], startFrom: 100), 120);
    expect(calculate(Formula.sum, first: null, startFrom: 100), 100);
    expect(
      calculate(Formula.difference, first: 40, others: [25], startFrom: 100),
      15,
      reason: 'only a total has one',
    );
  });

  test('a difference is the first less the rest, and may go below zero', () {
    expect(calculate(Formula.difference, first: 40, others: [25]), 15);
    expect(calculate(Formula.difference, first: 40, others: [25, 10]), 5);
    expect(calculate(Formula.difference, first: 3, others: [5]), -2);
    expect(calculate(Formula.difference, first: 40), 40);
  });

  test('a share is the first out of everything together, in whole percent', () {
    expect(calculate(Formula.percent, first: 3, others: [1]), 75);
    expect(calculate(Formula.percent, first: 1, others: [1, 1]), 33);
    expect(calculate(Formula.percent, first: 2, others: [1]), 67);
    expect(calculate(Formula.percent, first: 5, others: [0]), 100);
    expect(calculate(Formula.percent, first: 0, others: [9]), 0);
  });

  test('a share of nothing counted yet is nought, not an error', () {
    expect(calculate(Formula.percent, first: 0, others: [0]), 0);
    expect(calculate(Formula.percent, first: 0), 0);
  });

  test('rounds are the whole ones only', () {
    expect(calculate(Formula.every, first: 240, roundSize: 108), 2);
    expect(calculate(Formula.every, first: 107, roundSize: 108), 0);
    expect(calculate(Formula.every, first: 108, roundSize: 108), 1);
    expect(calculate(Formula.every, first: 29, roundSize: 8), 3);
    expect(calculate(Formula.every, first: 0, roundSize: 8), 0);
  });

  test('a round of nothing is treated as a round of one', () {
    expect(calculate(Formula.every, first: 7, roundSize: 0), 7);
    expect(towardNextRound(7, 0), 0);
  });

  test('how far into the next round', () {
    expect(towardNextRound(29, 8), 5);
    expect(towardNextRound(240, 108), 24);
    expect(towardNextRound(16, 8), 0);
    expect(towardNextRound(0, 8), 0);
  });

  test('with the counter it starts from gone, there is nothing to show', () {
    expect(calculate(Formula.difference, first: null, others: [5]), 0);
    expect(calculate(Formula.percent, first: null, others: [5]), 0);
    expect(calculate(Formula.every, first: null, roundSize: 8), 0);
  });
}
