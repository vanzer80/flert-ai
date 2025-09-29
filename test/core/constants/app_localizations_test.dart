import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flerta_ai/core/constants/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('should have correct default locale', () {
      expect(AppLocalizations.defaultLocale, equals(const Locale('pt', 'BR')));
    });

    test('should support Brazilian Portuguese', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('pt', 'BR')));
    });

    test('should format currency correctly', () {
      const value = 99.99;
      final formatted = AppLocalizations.formatCurrency(value);
      expect(formatted, equals('R\$ 99,99'));
    });

    test('should format date correctly', () {
      final date = DateTime(2024, 3, 15);
      final formatted = AppLocalizations.formatDate(date);
      expect(formatted, equals('15/03/2024'));
    });

    test('should format time correctly', () {
      final time = DateTime(2024, 3, 15, 14, 30);
      final formatted = AppLocalizations.formatTime(time);
      expect(formatted, equals('14:30'));
    });

    test('should validate CPF format correctly', () {
      expect(AppLocalizations.isValidCPFFormat('12345678901'), isTrue);
      expect(AppLocalizations.isValidCPFFormat('123.456.789-01'), isTrue);
      expect(AppLocalizations.isValidCPFFormat('123456789'), isFalse);
      expect(AppLocalizations.isValidCPFFormat('abc'), isFalse);
    });

    test('should format CPF correctly', () {
      const cpf = '12345678901';
      final formatted = AppLocalizations.formatCPF(cpf);
      expect(formatted, equals('123.456.789-01'));
    });

    test('should validate Brazilian phone correctly', () {
      expect(AppLocalizations.isValidBrazilianPhone('1199999999'), isTrue);
      expect(AppLocalizations.isValidBrazilianPhone('11999999999'), isTrue);
      expect(AppLocalizations.isValidBrazilianPhone('119999999'), isFalse);
      expect(AppLocalizations.isValidBrazilianPhone('abc'), isFalse);
    });

    test('should format Brazilian phone correctly', () {
      const phone10 = '1199999999';
      const phone11 = '11999999999';
      
      expect(AppLocalizations.formatBrazilianPhone(phone10), equals('(11) 9999-9999'));
      expect(AppLocalizations.formatBrazilianPhone(phone11), equals('(11) 99999-9999'));
    });

    test('should have Brazilian expressions', () {
      expect(AppLocalizations.brazilianExpressions, isNotEmpty);
      expect(AppLocalizations.brazilianExpressions, contains('que massa'));
      expect(AppLocalizations.brazilianExpressions, contains('que legal'));
    });

    test('should have Brazilian greetings', () {
      expect(AppLocalizations.brazilianGreetings, isNotEmpty);
      expect(AppLocalizations.brazilianGreetings, contains('E aí'));
      expect(AppLocalizations.brazilianGreetings, contains('Oi'));
    });

    test('should have Brazilian cultural references', () {
      expect(AppLocalizations.brazilianCulturalReferences, isNotEmpty);
      expect(AppLocalizations.brazilianCulturalReferences, contains('praia'));
      expect(AppLocalizations.brazilianCulturalReferences, contains('carnaval'));
    });

    test('should have Brazilian states', () {
      expect(AppLocalizations.brazilianStates, isNotEmpty);
      expect(AppLocalizations.brazilianStates['SP'], equals('São Paulo'));
      expect(AppLocalizations.brazilianStates['RJ'], equals('Rio de Janeiro'));
    });

    test('should have popular Brazilian cities', () {
      expect(AppLocalizations.popularBrazilianCities, isNotEmpty);
      expect(AppLocalizations.popularBrazilianCities, contains('São Paulo'));
      expect(AppLocalizations.popularBrazilianCities, contains('Rio de Janeiro'));
    });

    test('should have correct currency settings', () {
      expect(AppLocalizations.currencySymbol, equals('R\$'));
      expect(AppLocalizations.currencyCode, equals('BRL'));
      expect(AppLocalizations.countryCode, equals('BR'));
    });

    test('should have correct timezone', () {
      expect(AppLocalizations.timeZone, equals('America/Sao_Paulo'));
    });
  });
}
