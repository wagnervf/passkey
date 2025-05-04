import 'dart:convert';
import 'package:flutter/material.dart';

class TipoRegisterModel {
  final int id;
  final String name;
  final String icon;
  final Color color;
  TipoRegisterModel({
    this.id = 0,
    this.name = '',
    required this.icon,
    required this.color,
  });

  TipoRegisterModel copyWith({
    int? id,
    String? name,
    String? icon,
    Color? color,
  }) {
    return TipoRegisterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.withValues(),
    };
  }

  factory TipoRegisterModel.fromMap(Map<String, dynamic> map) {
    return TipoRegisterModel(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: Color(map['color'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory TipoRegisterModel.fromJson(String source) =>
      TipoRegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TipoRegisterModel(id: $id, name: $name, icon: $icon, color: $color)';
  }
}
  final List<TipoRegisterModel> tipoRegisterList = [
    TipoRegisterModel(
        id: 7,
        name: 'AliExpress',
        icon: 'aliexpress',
        color: const Color(0xFFFF4500)),
    TipoRegisterModel(
        id: 3,
        name: 'Americanas',
        icon: 'americanas',
        color: const Color(0xFFE60014)),
    TipoRegisterModel(
        id: 2, name: 'Amazon Brasil', icon: 'amazon', color: const Color(0xFF232F3E)),
    TipoRegisterModel(
        id: 9, name: 'Carrefour', icon: 'carrefour', color: const Color(0xFF003087)),
    TipoRegisterModel(
        id: 6,
        name: 'Casas Bahia',
        icon: 'casasbahia',
        color: const Color(0xFF004AAD)),
    TipoRegisterModel(
        id: 20, name: 'Centauro', icon: 'centauro', color: const Color(0xFFDA291C)),
    TipoRegisterModel(
        id: 14, name: 'Dafiti', icon: 'dafiti', color: const Color(0xFF000000)),
    TipoRegisterModel(
        id: 19, name: 'Elo7', icon: 'elo7', color: const Color(0xFFFFB347)),
    TipoRegisterModel(
        id: 11, name: 'Extra', icon: 'extra', color: const Color(0xFFEC1C24)),
    TipoRegisterModel(
        id: 13, name: 'Fast Shop', icon: 'fastshop', color: const Color(0xFFE30613)),
    TipoRegisterModel(
        id: 1,
        name: 'Mercado Livre',
        icon: 'mercadolivre',
        color: const Color(0xFFFFDF00)),
    TipoRegisterModel(
        id: 10, name: 'Netshoes', icon: 'netshoes', color: const Color(0xFF5A2D82)),
    TipoRegisterModel(
        id: 12,
        name: 'Ponto Frio',
        icon: 'pontofrio',
        color: const Color(0xFFE60014)),
    TipoRegisterModel(
        id: 5, name: 'Shopee', icon: 'shopee', color: const Color(0xFFFF5722)),
    TipoRegisterModel(
        id: 8, name: 'Submarino', icon: 'submarino', color: const Color(0xFF0078D7)),
    TipoRegisterModel(
        id: 17, name: 'Zattini', icon: 'zattini', color: const Color(0xFF000000)),

    TipoRegisterModel(
        id: 21, name: 'Discord', icon: 'discord', color: const Color(0xFF5865F2)),
    TipoRegisterModel(
        id: 22, name: 'Facebook', icon: 'facebook', color: const Color(0xFF1877F2)),
    TipoRegisterModel(
        id: 23, name: 'Instagram', icon: 'instagram', color: const Color(0xFFC13584)),
    TipoRegisterModel(
        id: 26, name: 'LinkedIn', icon: 'linkedin', color: const Color(0xFF0A66C2)),
    TipoRegisterModel(
        id: 29, name: 'Pinterest', icon: 'pinterest', color: const Color(0xFFE60023)),
    TipoRegisterModel(
        id: 28, name: 'Reddit', icon: 'reddit', color: const Color(0xFFFF4500)),
    TipoRegisterModel(
        id: 24, name: 'Snapchat', icon: 'snapchat', color: const Color(0xFFFFFC00)),
    TipoRegisterModel(
        id: 25, name: 'Telegram', icon: 'telegram', color: const Color(0xFF0088CC)),
    TipoRegisterModel(
        id: 4, name: 'TikTok', icon: 'tiktok', color: const Color(0xFF000000)),
    TipoRegisterModel(
        id: 27, name: 'Tumblr', icon: 'tumblr', color: const Color(0xFF35465C)),
    TipoRegisterModel(
        id: 5, name: 'Twitter (X)', icon: 'twitter', color: const Color(0xFF1DA1F2)),
    TipoRegisterModel(
        id: 6, name: 'WhatsApp', icon: 'whatsapp', color: const Color(0xFF25D366)),
    TipoRegisterModel(
        id: 31, name: 'YouTube', icon: 'youtube', color: const Color(0xFFFF0000)),

    // 🏦 BANCOS
    TipoRegisterModel(
        id: 61, name: 'Banco do Brasil', icon: 'bb', color: const Color(0xFFFFD700)),
    TipoRegisterModel(
        id: 63, name: 'Bradesco', icon: 'bradesco', color: const Color(0xFFE30613)),
    TipoRegisterModel(
        id: 62, name: 'Itaú', icon: 'itau', color: const Color(0xFFF58220)),
    TipoRegisterModel(
        id: 65, name: 'Nubank', icon: 'nubank', color: const Color(0xFF820AD1)),
    TipoRegisterModel(
        id: 64, name: 'Santander', icon: 'santander', color: const Color(0xFFE30613)),

    TipoRegisterModel(
        id: 10000,
        name: 'Outros',
        icon: 'key',
        color: const Color.fromARGB(255, 250, 112, 0)),
    TipoRegisterModel(
        id: 100,
        name: 'Google',
        icon: 'google',
        color: const Color(0xFF4285F4)), // Azul do Google

    TipoRegisterModel(
        id: 106,
        name: 'Netflix',
        icon: 'film',
        color: const Color(0xFFE50914)), // Vermelho do Netflix

    TipoRegisterModel(
        id: 108,
        name: 'Apple',
        icon: 'apple',
        color: const Color(0xFF000000)), // Preto do Apple
    TipoRegisterModel(
        id: 109,
        name: 'Spotify',
        icon: 'spotify',
        color: const Color(0xFF1DB954)), // Verde do Spotify
    TipoRegisterModel(
        id: 110,
        name: 'Microsoft',
        icon: 'microsoft',
        color: const Color(0xFFF25022)), // Laranja do Microsoft
    TipoRegisterModel(
        id: 111,
        name: 'PayPal',
        icon: 'paypal',
        color: const Color(0xFF003087)), // Azul do PayPal
    TipoRegisterModel(
        id: 112,
        name: 'Dropbox',
        icon: 'dropbox',
        color: const Color(0xFF0061FF)), // Azul do Dropbox
    TipoRegisterModel(
        id: 113,
        name: 'GitHub',
        icon: 'github',
        color: const Color(0xFF171515)), // Preto do GitHub
    TipoRegisterModel(
        id: 114,
        name: 'Slack',
        icon: 'slack',
        color: const Color(0xFF4A154B)), // Roxo do Slack
    TipoRegisterModel(
        id: 115,
        name: 'Zoom',
        icon: 'video',
        color: const Color(0xFF2D8CFF)), // Azul do Zoom

    TipoRegisterModel(
        id: 117,
        name: 'Reddit',
        icon: 'reddit',
        color: const Color(0xFFFF4500)), // Laranja do Reddit
    TipoRegisterModel(
        id: 118,
        name: 'Pinterest',
        icon: 'pinterest',
        color: const Color(0xFFE60023)), // Vermelho do Pinterest
    TipoRegisterModel(
        id: 119,
        name: 'Twitch',
        icon: 'twitch',
        color: const Color(0xFF6441A5)), // Roxo do Twitch

    TipoRegisterModel(
        id: 122,
        name: 'eBay',
        icon: 'shoppingCart',
        color: const Color(0xFFE53238)), // Vermelho do eBay
    TipoRegisterModel(
        id: 123,
        name: 'Discord',
        icon: 'discord',
        color: const Color(0xFF7289DA)), // Azul do Discord
    TipoRegisterModel(
        id: 124,
        name: 'WhatsApp',
        icon: 'whatsapp',
        color: const Color(0xFF25D366)), // Verde do WhatsApp
    TipoRegisterModel(
        id: 125,
        name: 'Telegram',
        icon: 'telegram',
        color: const Color(0xFF0088CC)), // Azul do Telegram
    TipoRegisterModel(
        id: 126,
        name: 'Uber',
        icon: 'car',
        color: const Color(0xFF000000)), // Preto do Uber
    TipoRegisterModel(
        id: 127,
        name: 'Airbnb',
        icon: 'house',
        color: const Color(0xFFFF5A5F)), // Rosa do Airbnb
    TipoRegisterModel(
        id: 129,
        name: 'Hulu',
        icon: 'tv',
        color: const Color(0xFF1CE783)), // Verde do Hulu
    TipoRegisterModel(
        id: 130,
        name: 'Steam',
        icon: 'gamepad',
        color: const Color(0xFF171A21)), // Preto do Steam

    TipoRegisterModel(
        id: 131,
        name: 'Wi-Fi Doméstico',
        icon: 'wifi',
        color: const Color(0xFF4CAF50)),
    TipoRegisterModel(
        id: 132,
        name: 'Admin Roteador',
        icon: 'router',
        color: const Color(0xFF607D8B)),
    TipoRegisterModel(
        id: 133, name: 'Steam', icon: 'steam', color: const Color(0xFF000000)),
    TipoRegisterModel(
        id: 134,
        name: 'Google Drive',
        icon: 'google_drive',
        color: const Color(0xFF4285F4)),
    TipoRegisterModel(
        id: 135, name: 'Netflix', icon: 'netflix', color: const Color(0xFFE50914)),

    TipoRegisterModel(
        id: 405,
        name: '99 Táxi',
        icon: '99',
        color: const Color(0xFFFFCC00)), // Amarelo
    
    TipoRegisterModel(
        id: 408, name: 'Uber', icon: 'uber', color: const Color(0xFF000000)), // Preto
    TipoRegisterModel(
        id: 409,
        name: 'Waze',
        icon: 'waze',
        color: const Color(0xFF1CA1F1)), // Azul Claro

    TipoRegisterModel(
        id: 410,
        name: 'Apple Pay',
        icon: 'apple_pay',
        color: const Color(0xFF000000)), // Preto
    TipoRegisterModel(
        id: 411,
        name: 'Google Pay',
        icon: 'google_pay',
        color: const Color(0xFF4285F4)), // Azul
    TipoRegisterModel(
        id: 412,
        name: 'Mercado Pago',
        icon: 'mercadopago',
        color: const Color(0xFF009EE3)), // Azul
    TipoRegisterModel(
        id: 413,
        name: 'PagSeguro',
        icon: 'pagseguro',
        color: const Color(0xFFFFC400)), // Amarelo
    TipoRegisterModel(
        id: 414,
        name: 'PayPal',
        icon: 'paypal',
        color: const Color(0xFF003087)), // Azul Escuro
    TipoRegisterModel(
        id: 415,
        name: 'PicPay',
        icon: 'picpay',
        color: const Color(0xFF21C25E)), // Verde
    TipoRegisterModel(
        id: 416,
        name: 'Bluehost',
        icon: 'bluehost',
        color: const Color(0xFF0066FF)), // Azul
    TipoRegisterModel(
        id: 417,
        name: 'Cloudflare',
        icon: 'cloudflare',
        color: const Color(0xFFFF7300)), // Laranja
    TipoRegisterModel(
        id: 418,
        name: 'GoDaddy',
        icon: 'godaddy',
        color: const Color(0xFF7DB701)), // Verde
    TipoRegisterModel(
        id: 419,
        name: 'HostGator',
        icon: 'hostgator',
        color: const Color(0xFF002D5E)), // Azul Escuro
    TipoRegisterModel(
        id: 420,
        name: 'SiteGround',
        icon: 'siteground',
        color: const Color(0xFF00A855)), // Verde

    TipoRegisterModel(
        id: 421,
        name: 'Claro',
        icon: 'claro',
        color: const Color(0xFFE60012)), // Vermelho
    TipoRegisterModel(
        id: 422, name: 'Oi', icon: 'oi', color: const Color(0xFFFF6600)), // Laranja
    TipoRegisterModel(
        id: 423,
        name: 'Sky',
        icon: 'sky',
        color: const Color(0xFFDC0000)), // Vermelho
    TipoRegisterModel(
        id: 424, name: 'Tim', icon: 'tim', color: const Color(0xFF0048B0)), // Azul
    TipoRegisterModel(
        id: 425, name: 'Vivo', icon: 'vivo', color: const Color(0xFF6E1E9D)), // Roxo

    TipoRegisterModel(
        id: 426,
        name: 'Detran',
        icon: 'detran',
        color: const Color(0xFF003399)), // Azul
    TipoRegisterModel(
        id: 427,
        name: 'Gov.br',
        icon: 'govbr',
        color: const Color(0xFF005DAA)), // Azul
    TipoRegisterModel(
        id: 428,
        name: 'INSS',
        icon: 'inss',
        color: const Color(0xFF1B75BB)), // Azul Claro
    TipoRegisterModel(
        id: 429,
        name: 'Receita Federal',
        icon: 'receita',
        color: const Color(0xFF003399)), // Azul
    TipoRegisterModel(
        id: 430,
        name: 'Amazon Prime Video',
        icon: 'primevideo',
        color: const Color(0xFF00A8E1)), // Azul
    TipoRegisterModel(
        id: 431,
        name: 'Disney+',
        icon: 'disney',
        color: const Color(0xFF113CCF)), // Azul Escuro
    TipoRegisterModel(
        id: 432,
        name: 'Netflix',
        icon: 'netflix',
        color: const Color(0xFFE50914)), // Vermelho
    TipoRegisterModel(
        id: 433,
        name: 'Spotify',
        icon: 'spotify',
        color: const Color(0xFF1DB954)), // Verde

    TipoRegisterModel(
        id: 434,
        name: 'Microsoft Teams',
        icon: 'teams',
        color: const Color(0xFF464EB8)), // Roxo

    TipoRegisterModel(
        id: 435, name: 'Dropbox', icon: 'dropbox', color: const Color(0xFF0061FF)),

// 🎮 Games
    TipoRegisterModel(
        id: 437,
        name: 'PlayStation Network',
        icon: 'psn',
        color: const Color(0xFF00439C)),
    TipoRegisterModel(
        id: 438, name: 'Steam', icon: 'steam', color: const Color(0xFF000000)),

    TipoRegisterModel(
        id: 400,
        name: 'Alexa',
        icon: 'alexa',
        color: const Color(0xFF0F9D58)), // Verde
    TipoRegisterModel(
        id: 401,
        name: 'Google Home',
        icon: 'google_home',
        color: const Color(0xFF4285F4)), // Azul
    TipoRegisterModel(
        id: 402,
        name: 'Philips Hue',
        icon: 'philips_hue',
        color: const Color(0xFFFFA000)), // Laranja
    TipoRegisterModel(
        id: 403,
        name: 'SmartThings',
        icon: 'smartthings',
        color: const Color(0xFF1C8EF9)), // Azul Claro
    TipoRegisterModel(
        id: 404,
        name: 'Xiaomi Home',
        icon: 'xiaomi_home',
        color: const Color(0xFFFF6600)), // Laranja
  ];

