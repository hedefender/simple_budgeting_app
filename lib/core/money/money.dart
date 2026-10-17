import 'package:flutter/foundation.dart';

/// An amount of money stored as an integer number of minor units
/// (cents for EUR/USD). Never use `double` to store or add money.
///
/// Phase 0 keeps this currency-agnostic: the currency is a display concern
/// taken from the device. Later phases will store a currency code next to
/// every persisted amount.
@immutable
class Money implements Comparable<Money> {
  const Money(this.minorUnits);

  static const Money zero = Money(0);

  final int minorUnits;

  bool get isNegative => minorUnits < 0;

  Money operator +(Money other) => Money(minorUnits + other.minorUnits);

  Money operator -(Money other) => Money(minorUnits - other.minorUnits);

  Money operator -() => Money(-minorUnits);

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minorUnits == minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  String toString() => 'Money($minorUnits)';
}
