import '../../../config/presentation/app_palette.dart';

enum DialogType {
  info(AppPalette.blueS9),
  alert(AppPalette.red),
  error(AppPalette.red),
  help(AppPalette.blueS9),
  success(AppPalette.greenS9);

  final dynamic color;
  const DialogType(this.color);
}
