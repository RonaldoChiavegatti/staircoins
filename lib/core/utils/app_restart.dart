import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:staircoins/core/utils/app_restart_io.dart'
    if (dart.library.html) 'package:staircoins/core/utils/app_restart_web.dart';

/// Classe utilitária para reiniciar o aplicativo
class AppRestart {
  /// Chave global para reiniciar o aplicativo
  static final GlobalKey<RestartWidgetState> restartKey =
      GlobalKey<RestartWidgetState>();

  /// Reinicia o aplicativo
  static void restartApp(BuildContext context) {
    if (kIsWeb) {
      restartAppWeb();
    } else {
      // Em dispositivos móveis, usar o widget RestartWidget
      final state = restartKey.currentState;
      if (state != null) {
        state.restartApp();
      }
    }
  }
}

/// Widget que permite reiniciar o aplicativo
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  @override
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
