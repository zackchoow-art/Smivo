/// Responsive layout breakpoints for adaptive UI.
///
/// Used with LayoutBuilder or MediaQuery to switch between
/// mobile, tablet, and desktop layouts.
class Breakpoints {
  Breakpoints._();

  /// Below this width → mobile layout.
  static const double mobile = 600;

  /// Between mobile and desktop → tablet layout.
  static const double tablet = 1024;

  /// Above tablet → desktop layout.
  static const double desktop = 1024;

  /// Returns true if [width] is in mobile range.
  static bool isMobile(double width) => width < mobile;

  /// Returns true if [width] is in tablet range.
  static bool isTablet(double width) =>
      width >= mobile && width < desktop;

  /// Returns true if [width] is in desktop range.
  static bool isDesktop(double width) => width >= desktop;
}
