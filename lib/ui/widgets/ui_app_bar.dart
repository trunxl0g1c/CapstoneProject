import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../provider/theme_provider.dart';

class UiAppBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onSearch;

  const UiAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title),
          leading: [
            if (showBack)
              OutlineButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                density: ButtonDensity.icon,
                child: const Icon(Icons.home),
              ),
          ],
          trailing: [
            OutlineButton(
              onPressed:
                  onSearch ??
                  () {
                    Navigator.pushNamed(context, '/search');
                  },
              density: ButtonDensity.icon,
              child: const Icon(Icons.search),
            ),

            IconButton.outline(
              icon: Icon(
                context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
