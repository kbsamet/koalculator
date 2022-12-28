import 'package:flutter/src/widgets/framework.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowcaseWidget extends StatelessWidget {
  final Widget child;
  final String description;
  final GlobalKey? globalKey;
  const CustomShowcaseWidget({
    super.key,
    required this.child,
    required this.description,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    if (globalKey == null) {
      return child;
    }
    return Showcase(
      key: globalKey!,
      description: description,
      child: child,
    );
  }
}
