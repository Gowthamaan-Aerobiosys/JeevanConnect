import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/config/presentation/app_palette.dart';

import '../../../config/presentation/layout_config.dart';
import '../components/white_space.dart';
import '../components/widget_decoration.dart';

class SlidingPage extends StatefulWidget {
  final Widget child;
  const SlidingPage({super.key, required this.child});

  @override
  SlidingPageState createState() => SlidingPageState();
}

class SlidingPageState extends State<SlidingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: LayoutConfig().setFractionWidth(80),
          child: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              Card(
                color: AppPalette.white,
                shape: WidgetDecoration.roundedEdge5,
                margin: WhiteSpace.zero,
                child: SizedBox(
                    width: LayoutConfig().setFractionWidth(77),
                    child: widget.child),
              ),
              Positioned(
                top: -8,
                left: -10,
                child: IconButton(
                  padding: WhiteSpace.zero,
                  icon: Icon(
                    Icons.close,
                    color: AppPalette.greyC3,
                    size: Theme.of(context).textTheme.headlineLarge!.fontSize,
                  ),
                  onPressed: () {
                    _controller.reverse().then((_) {
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
