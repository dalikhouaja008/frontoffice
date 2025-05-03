import 'package:flutter/foundation.dart';
import '../features/metamask/data/models/metamask_provider.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error
}

class AuthService extends ChangeNotifier {
  final MetamaskProvider _metamaskProvider;
  
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _currentAddress = '';
  String _chainId = '';
  bool _isConnected = false;

  // Constructor that takes the MetaMask provider
  AuthService(this._metamaskProvider) {
    // Listen to MetaMask connection changes
    _metamaskProvider.addListener(_onMetaMaskChanged);
    
    // Check if already connected
    _checkInitialConnection();
  }

  // Getters
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get currentAddress => _currentAddress;
  String get chainId => _chainId;
  bool get isConnected => _isConnected;
  bool get isMetaMaskAvailable => _metamaskProvider.isMetaMaskAvailable;

  // Check if there's an existing connection
  Future<void> _checkInitialConnection() async {
    try {
      final isConnected = await _metamaskProvider.isConnected();
      if (isConnected) {
        _currentAddress = _metamaskProvider.currentAddress;
        _chainId = _metamaskProvider.chainId;
        _isConnected = true;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Connect to MetaMask
  Future<bool> connectWithMetaMask() async {
    if (!_metamaskProvider.isMetaMaskAvailable) {
      _errorMessage = 'MetaMask is not available in this browser';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final success = await _metamaskProvider.connect();
      
      if (success) {
        _currentAddress = _metamaskProvider.currentAddress;
        _chainId = _metamaskProvider.chainId;
        _isConnected = true;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to connect to MetaMask';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error connecting to MetaMask: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Disconnect from MetaMask
  Future<void> disconnect() async {
    await _metamaskProvider.disconnect();
    _isConnected = false;
    _currentAddress = '';
    _chainId = '';
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Sign message with MetaMask (for authentication purposes)
  Future<String?> signMessage(String message) async {
    try {
      return await _metamaskProvider.signMessage(message);
    } catch (e) {
      _errorMessage = 'Error signing message: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Verify if we're on the correct network
  Future<bool> verifyNetwork(String requiredChainId) async {
    return _metamaskProvider.chainId == requiredChainId;
  }

  // Switch network if needed
  Future<bool> switchNetwork(String chainId) async {
    try {
      return await _metamaskProvider.switchChain(chainId);
    } catch (e) {
      _errorMessage = 'Error switching network: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Listen to MetaMask provider changes
  Future<void> _onMetaMaskChanged() async {
    if (await _metamaskProvider.isConnected()) {
      _currentAddress = _metamaskProvider.currentAddress;
      _chainId = _metamaskProvider.chainId;
      _isConnected = true;
      _status = AuthStatus.authenticated;
    } else {
      _isConnected = false;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _metamaskProvider.removeListener(_onMetaMaskChanged);
    super.dispose();
  }
}