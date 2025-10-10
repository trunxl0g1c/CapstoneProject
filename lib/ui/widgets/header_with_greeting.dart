import 'package:shadcn_flutter/shadcn_flutter.dart';

class HeaderWithGreeting extends StatefulWidget {
  const HeaderWithGreeting({super.key});

  @override
  State<HeaderWithGreeting> createState() => _HeaderWithGreetingState();
}

class _HeaderWithGreetingState extends State<HeaderWithGreeting> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 15) {
      return "Selamat Siang";
    } else if (hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${getGreeting()}, Rafi',
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ).h4;
  }
}
