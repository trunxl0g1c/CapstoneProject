import 'package:shadcn_flutter/shadcn_flutter.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert),
            const SizedBox(height: 16),

            Text("Oops, terjadi kesalahan", textAlign: TextAlign.center).h1,
            const SizedBox(height: 8),

            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),

            PrimaryButton(onPressed: onRetry, child: const Text("Coba Lagi")),
          ],
        ),
      ),
    );
  }
}
