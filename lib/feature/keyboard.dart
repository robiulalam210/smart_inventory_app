import '../core/configs/configs.dart';

class KeyboardGuard extends StatefulWidget {
  final Widget child;
  const KeyboardGuard({super.key, required this.child});

  @override
  State<KeyboardGuard> createState() => _KeyboardGuardState();
}

class _KeyboardGuardState extends State<KeyboardGuard> {
  final Set<PhysicalKeyboardKey> _pressedKeys = {};

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        final key = event.physicalKey;

        if (event is KeyDownEvent) {
          // Resilient: don't throw, just skip if already down
          if (_pressedKeys.contains(key)) {
            return KeyEventResult.handled;
          }
          _pressedKeys.add(key);
        } else if (event is KeyUpEvent) {
          _pressedKeys.remove(key);
        }

        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
