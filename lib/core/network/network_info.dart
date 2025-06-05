import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker? connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    // No web, sempre retorna true pois o InternetConnectionChecker não funciona no web
    if (kIsWeb) {
      return true;
    }
    
    // Em plataformas móveis, usa o InternetConnectionChecker
    if (connectionChecker != null) {
      return await connectionChecker!.hasConnection;
    }
    
    return true;
  }
} 