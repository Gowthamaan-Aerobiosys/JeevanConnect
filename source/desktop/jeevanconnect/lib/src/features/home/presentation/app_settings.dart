import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../shared/presentation/components/white_space.dart';

enum ApplicationThemes { light, dark, system }

class ApplicationSettings extends StatelessWidget {
  const ApplicationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WhiteSpace.h50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WhiteSpace.b32,
          Text(
            "General",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          WhiteSpace.b16,
          Padding(
            padding: WhiteSpace.h30,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Choose theme - Changes will reflect globally after restarting the app",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: AppPalette.greyS4),
                    ),
                    WhiteSpace.spacer,
                    const ThemeOptions()
                  ],
                ),
              ],
            ),
          ),
          WhiteSpace.b56,
          Text(
            "Update",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          WhiteSpace.b16,
          Padding(
            padding: WhiteSpace.h30,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Choose theme - Changes will reflect globally after restarting the app",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: AppPalette.greyS4),
                    ),
                    WhiteSpace.spacer,
                    const ThemeOptions()
                  ],
                ),
              ],
            ),
          ),
          WhiteSpace.b56,
          Text(
            "About",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          WhiteSpace.b16,
          Padding(
            padding: WhiteSpace.h30,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Choose theme - Changes will reflect globally after restarting the app",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: AppPalette.greyS4),
                    ),
                    WhiteSpace.spacer,
                    const ThemeOptions()
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeOptions extends StatefulWidget {
  const ThemeOptions({super.key});

  @override
  State<ThemeOptions> createState() => _ThemeOptionsState();
}

class _ThemeOptionsState extends State<ThemeOptions> {
  ApplicationThemes currentTheme = ApplicationThemes.dark;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ApplicationThemes>(
      segments: const <ButtonSegment<ApplicationThemes>>[
        ButtonSegment<ApplicationThemes>(
            value: ApplicationThemes.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode_outlined)),
        ButtonSegment<ApplicationThemes>(
            value: ApplicationThemes.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode_outlined)),
        ButtonSegment<ApplicationThemes>(
            value: ApplicationThemes.system,
            label: Text('System'),
            icon: Icon(Icons.phone_iphone_outlined)),
      ],
      selected: <ApplicationThemes>{currentTheme},
      onSelectionChanged: (Set<ApplicationThemes> newSelection) {
        setState(() {
          currentTheme = newSelection.first;
        });
      },
    );
  }
}
