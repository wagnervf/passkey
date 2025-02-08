import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:passkey/src/core/components/show_messeger.dart';

class Utils {
  static bool isDarkMode(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark;
  }

  static textTheme(context) => Theme.of(context).textTheme;

  static height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }


  static Padding titleCard(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  static Color getColor(int id) {
    switch (id) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.teal;
      case 6:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  

  static Color? getColorPlus(int id) {
    switch (id) {
      case 0:
        return Colors.blue[100];
      case 1:
        return Colors.orange[100];
      case 2:
        return Colors.green[100];
      case 3:
        return Colors.red[100];
      case 4:
        return Colors.purple[100];
      case 5:
        return Colors.teal[100];
      case 6:
        return Colors.brown[100];
      default:
        return Colors.grey[300];
    }
  }

  static Column formField(String label, String hint, IconData icon,
      TextEditingController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: decorationField(
              hint,
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              )),
        ),
      ],
    );
  }

  static InputDecoration decorationField(String description, Widget icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(20),
      hintText: description,
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      errorStyle: const TextStyle(color: Colors.cyan),
    );
  }

  static void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ShowMessager.show(context, 'Copiado!');
  }

  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'google':
        return FontAwesomeIcons.google;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'key':
        return FontAwesomeIcons.key; // For 'Outros'
      case 'film':
        return FontAwesomeIcons.film; // Netflix
      case 'amazon':
        return FontAwesomeIcons.amazon;
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'spotify':
        return FontAwesomeIcons.spotify;
      case 'microsoft':
        return FontAwesomeIcons.microsoft;
      case 'paypal':
        return FontAwesomeIcons.paypal;
      case 'dropbox':
        return FontAwesomeIcons.dropbox;
      case 'github':
        return FontAwesomeIcons.github;
      case 'slack':
        return FontAwesomeIcons.slack;
      case 'video':
        return FontAwesomeIcons.video; // Zoom
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'reddit':
        return FontAwesomeIcons.reddit;
      case 'pinterest':
        return FontAwesomeIcons.pinterest;
      case 'twitch':
        return FontAwesomeIcons.twitch;
      case 'snapchat':
        return FontAwesomeIcons.snapchat;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'shoppingCart':
        return FontAwesomeIcons.shoppingCart; // eBay
      case 'discord':
        return FontAwesomeIcons.discord;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'telegram':
        return FontAwesomeIcons.telegram;
      case 'car':
        return FontAwesomeIcons.car; // Uber
      case 'house':
        return FontAwesomeIcons.house; // Airbnb
      case 'tv':
        return FontAwesomeIcons.tv; // Hulu
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'telegram':
        return FontAwesomeIcons.telegram;
      case 'spotify':
        return FontAwesomeIcons.spotify;
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'amazon':
        return FontAwesomeIcons.amazon;
      case 'github':
        return FontAwesomeIcons.github;

      // 🛍️ E-commerce
      case 'mercadolivre':
        return FontAwesomeIcons.shoppingCart;
      case 'shopee':
        return FontAwesomeIcons.store;
      case 'aliexpress':
      case 'zattini':
      case 'submarino':
      case 'pontofrio':
      case 'extra':
      case 'fastshop':
      case 'elo7':
      case 'centauro':
      case 'casasbahia':
      case 'americanas':
      case 'dafiti':
      case 'carrefour':
        return FontAwesomeIcons.cartShopping;
      case 'netshoes':
        return FontAwesomeIcons.shoePrints;
      case 'amazon_prime':
        return FontAwesomeIcons.amazonPay;

      // 🎮 Games
      case 'steam':
        return FontAwesomeIcons.steam;
      case 'psn':
        return FontAwesomeIcons.playstation;
      case 'xbox':
        return FontAwesomeIcons.xbox;

      // 🏦 Bancos e Pagamentos
      case 'paypal':
        return FontAwesomeIcons.paypal;
      case 'nubank':
        return FontAwesomeIcons.university;
      case 'bradesco':
        return FontAwesomeIcons.buildingColumns;
      case 'itau':
        return FontAwesomeIcons.landmark;
      case 'picpay':
        return FontAwesomeIcons.moneyBill;

      // ☁️ Nuvem
      case 'google_drive':
        return FontAwesomeIcons.googleDrive;
      case 'google_home':
        return FontAwesomeIcons.googlePlus;
      case 'google_pay':
        return FontAwesomeIcons.googlePay;
      case 'apple_pay':
        return FontAwesomeIcons.applePay;
      case 'mercadopago':
      case 'pagseguro':
        return FontAwesomeIcons.buildingColumns;

      case 'primevideo':
      case 'alexa':
        return FontAwesomeIcons.amazon;

      case 'dropbox':
        return FontAwesomeIcons.dropbox;

      // 📶 Redes e Wi-Fi
      case 'wifi':
        return FontAwesomeIcons.wifi;
      case 'router':
        return FontAwesomeIcons.networkWired;

      // 🎥 Streaming
      case 'netflix':
        return FontAwesomeIcons.film;
      case 'disney':
        return FontAwesomeIcons.tv;
      case 'hulu':
        return FontAwesomeIcons.video;

      // 🛠️ Outros
      case 'key':
        return FontAwesomeIcons.key;
      case 'lock':
        return FontAwesomeIcons.lock;
      case 'unlock':
        return FontAwesomeIcons.unlock;

      case 'detran':
      case 'uber':
      case 'waze':
      case '99':
        return FontAwesomeIcons.car;
      case 'govbr':
      case 'inss':
      case 'receita':
        return FontAwesomeIcons.handshake;

      case 'claro':
      case 'oi':
      case 'vivo':
      case 'tim':
      case 'sky':
        return FontAwesomeIcons.tty;

      case 'siteground':
      case 'hostgator':
      case 'godaddy':
      case 'bluehost':
      case 'philips_hue':
      case 'smartthings':
      case 'xiaomi_home':
        return FontAwesomeIcons.globe;
      case 'teams':
        return FontAwesomeIcons.microsoft;

      default:
        return Icons.help_outline; // Ícone padrão para nomes desconhecidos
    }
  }
}
