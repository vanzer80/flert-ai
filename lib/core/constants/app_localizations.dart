import 'package:flutter/material.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'), // Português brasileiro
  ];

  static const Locale defaultLocale = Locale('pt', 'BR');

  // Configurações de localização específicas do Brasil
  static const String currencySymbol = 'R\$';
  static const String currencyCode = 'BRL';
  static const String countryCode = 'BR';
  static const String timeZone = 'America/Sao_Paulo';

  // Formatação de números e moeda
  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Formatação de data brasileira
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formatação de hora brasileira
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Gírias e expressões brasileiras para as sugestões de IA
  static const List<String> brazilianExpressions = [
    'que massa',
    'que show',
    'que legal',
    'que incrível',
    'que fofo',
    'que lindo',
    'que demais',
    'que top',
    'que da hora',
    'que bacana',
    'que maneiro',
    'que sensacional',
    'que perfeito',
    'que maravilhoso',
    'que espetacular',
  ];

  static const List<String> brazilianGreetings = [
    'E aí',
    'Oi',
    'Olá',
    'Tudo bem?',
    'Tudo joia?',
    'Beleza?',
    'Como vai?',
    'Opa',
    'Salve',
    'Fala aí',
  ];

  static const List<String> brazilianCompliments = [
    'você é um arraso',
    'você é demais',
    'você é incrível',
    'você é maravilhosa',
    'você é linda demais',
    'você tem um sorriso lindo',
    'você é muito fofa',
    'você é perfeita',
    'você é sensacional',
    'você é um amor',
  ];

  // Contextos culturais brasileiros
  static const List<String> brazilianCulturalReferences = [
    'praia',
    'carnaval',
    'futebol',
    'churrasco',
    'açaí',
    'caipirinha',
    'samba',
    'forró',
    'festa junina',
    'feijoada',
    'brigadeiro',
    'pão de açúcar',
    'cristo redentor',
    'copacabana',
    'ipanema',
  ];

  // Atividades populares no Brasil
  static const List<String> brazilianActivities = [
    'ir à praia',
    'fazer um churrasco',
    'tomar uma caipirinha',
    'assistir um jogo',
    'ir num show',
    'fazer uma trilha',
    'ir no cinema',
    'passear no shopping',
    'ir numa festa',
    'fazer um piquenique',
    'ir numa balada',
    'fazer um passeio de bike',
    'ir num restaurante',
    'fazer uma viagem',
    'ir numa feira',
  ];

  // Emojis populares no Brasil
  static const List<String> brazilianEmojis = [
    '😍',
    '😘',
    '🥰',
    '😊',
    '😉',
    '🔥',
    '💕',
    '❤️',
    '💖',
    '🌟',
    '✨',
    '🎉',
    '🏖️',
    '🌴',
    '☀️',
  ];

  // Validação de CPF (apenas formato)
  static bool isValidCPFFormat(String cpf) {
    final cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCPF.length == 11;
  }

  // Formatação de CPF
  static String formatCPF(String cpf) {
    final cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCPF.length == 11) {
      return '${cleanCPF.substring(0, 3)}.${cleanCPF.substring(3, 6)}.${cleanCPF.substring(6, 9)}-${cleanCPF.substring(9, 11)}';
    }
    return cpf;
  }

  // Validação de telefone brasileiro
  static bool isValidBrazilianPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanPhone.length == 10 || cleanPhone.length == 11;
  }

  // Formatação de telefone brasileiro
  static String formatBrazilianPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6, 10)}';
    } else if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7, 11)}';
    }
    return phone;
  }

  // Estados brasileiros
  static const Map<String, String> brazilianStates = {
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  // Cidades populares para sugestões de viagem
  static const List<String> popularBrazilianCities = [
    'Rio de Janeiro',
    'São Paulo',
    'Salvador',
    'Brasília',
    'Fortaleza',
    'Belo Horizonte',
    'Manaus',
    'Curitiba',
    'Recife',
    'Goiânia',
    'Belém',
    'Porto Alegre',
    'Guarulhos',
    'Campinas',
    'São Luís',
    'São Gonçalo',
    'Maceió',
    'Duque de Caxias',
    'Natal',
    'Teresina',
  ];
}
