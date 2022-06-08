import 'dart:ui';

class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> white = [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)];
  static List<Color> blue = [const Color.fromARGB(255, 97, 162, 254), const Color.fromARGB(255, 99, 255, 213)];
  static List<Color> yellow = [const Color.fromARGB(255, 255, 217, 45), const Color.fromARGB(255, 255, 234, 113)];
  static List<Color> red = [const Color.fromARGB(255, 255, 65, 65), const Color.fromARGB(255, 255, 132, 132)];
}

class GradientTemplate {
  static List<GradientColors> gradientTemplate = [
    GradientColors(GradientColors.white),
    GradientColors(GradientColors.blue),
    GradientColors(GradientColors.yellow),
    GradientColors(GradientColors.red),
  ];
}
