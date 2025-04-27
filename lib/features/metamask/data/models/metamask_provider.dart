// data/models/metamask_provider.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:developer' as developer;
import '../../../../core/network/graphql_client.dart';

class MetamaskProvider extends ChangeNotifier {
  bool _isMetaMaskAvailable = false;
  String _currentAddress = '';
  String _chainId = '';
  bool _hasListeners = false;
  bool _isLoading = false;
  String _error = '';
  bool _success = false;
  String _publicKey = '';

  // Constructor
  MetamaskProvider() {
    developer.log('MetamaskProvider: Initializing');
    _checkMetaMaskAvailability();
    if (_isMetaMaskAvailable) {
      developer.log('MetamaskProvider: MetaMask available, setting up listeners');
      _setupListeners();
    } else {
      developer.log('MetamaskProvider: MetaMask not available');
    }
  }

  // Getters
  bool get isMetaMaskAvailable => _isMetaMaskAvailable;
  String get currentAddress => _currentAddress;
  String get chainId => _chainId;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get success => _success;
  String get publicKey => _publicKey;

  // Check if MetaMask is available in the browser
  void _checkMetaMaskAvailability() {
    try {
      developer.log('MetamaskProvider: Checking MetaMask availability');
      
      // Debug: log window.ethereum object
      if (js.context.hasProperty('ethereum')) {
        developer.log('MetamaskProvider: ethereum object exists in window');
      } else {
        developer.log('MetamaskProvider: ethereum object does NOT exist in window');
      }
      
      final ethereum = js.context.hasProperty('ethereum') ? js.context['ethereum'] : null;
      _isMetaMaskAvailable = ethereum != null && ethereum.hasProperty('isMetaMask');
      
      developer.log('MetamaskProvider: MetaMask available: $_isMetaMaskAvailable');
      
      // If MetaMask is available, check if already connected
      if (_isMetaMaskAvailable) {
        // Try to get accounts to see if already connected
        isConnected().then((connected) {
          developer.log('MetamaskProvider: Already connected: $connected');
          if (connected) {
            developer.log('MetamaskProvider: Connected to address: $_currentAddress');
          }
        });
      }
    } catch (e) {
      developer.log('MetamaskProvider: Error checking availability: $e');
      _isMetaMaskAvailable = false;
    }
  }

  // Set up event listeners for MetaMask
  void _setupListeners() {
    if (!_isMetaMaskAvailable || _hasListeners) return;

    try {
      final ethereum = js.context['ethereum'];
      
      // Listen for account changes
      developer.log('MetamaskProvider: Setting up accountsChanged listener');
      ethereum.callMethod('on', [
        'accountsChanged',
        js.allowInterop((accounts) {
          developer.log('MetamaskProvider: Accounts changed: $accounts');
          if (accounts.length > 0) {
            _currentAddress = accounts[0];
            developer.log('MetamaskProvider: New account: $_currentAddress');
          } else {
            _currentAddress = '';
            developer.log('MetamaskProvider: No accounts');
          }
          notifyListeners();
        })
      ]);

      // Listen for chain changes
      developer.log('MetamaskProvider: Setting up chainChanged listener');
      ethereum.callMethod('on', [
        'chainChanged',
        js.allowInterop((chainId) {
          developer.log('MetamaskProvider: Chain changed: $chainId');
          _chainId = chainId;
          notifyListeners();
        })
      ]);

      // Listen for disconnect
      developer.log('MetamaskProvider: Setting up disconnect listener');
      ethereum.callMethod('on', [
        'disconnect',
        js.allowInterop((error) {
          developer.log('MetamaskProvider: Disconnected: $error');
          _currentAddress = '';
          notifyListeners();
        })
      ]);

      _hasListeners = true;
      developer.log('MetamaskProvider: Listeners set up successfully');
    } catch (e) {
      developer.log('MetamaskProvider: Error setting up listeners: $e');
    }
  }

  // Check if already connected to MetaMask
  Future<bool> isConnected() async {
    if (!_isMetaMaskAvailable) return false;

    try {
      developer.log('MetamaskProvider: Checking if already connected');
      final ethereum = js.context['ethereum'];
      
      // Debug direct JS call
      js.context.callMethod('eval', ['''
        console.log("Direct JS: Checking eth_accounts");
        console.log("ethereum object:", window.ethereum);
      ''']);
      
      final accounts = await js_util.promiseToFuture<List<dynamic>>(
        ethereum.callMethod('request', [js_util.jsify({'method': 'eth_accounts'})]),
      );

      developer.log('MetamaskProvider: eth_accounts returned: $accounts');

      if (accounts.isNotEmpty) {
        _currentAddress = accounts[0] as String;
        developer.log('MetamaskProvider: Connected to address: $_currentAddress');
        
        // Get chain ID
        _chainId = await js_util.promiseToFuture<String>(
          ethereum.callMethod('request', [js_util.jsify({'method': 'eth_chainId'})]),
        );
        developer.log('MetamaskProvider: Current chain ID: $_chainId');
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      developer.log('MetamaskProvider: Error checking connection: $e');
      return false;
    }
  }

  // Connect to MetaMask
  Future<bool> connect() async {
    developer.log('MetamaskProvider: Connect method called');
    
    if (!_isMetaMaskAvailable) {
      _error = 'MetaMask not available. Please install the MetaMask extension.';
      developer.log('MetamaskProvider: $_error');
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      developer.log('MetamaskProvider: Requesting accounts...');
      
      // Try direct JavaScript approach first
      js.context.callMethod('eval', ['''
        console.log("Direct JS: Requesting accounts");
        window.ethereum.request({ method: 'eth_requestAccounts' })
          .then(accounts => {
            console.log("Direct JS: Accounts received:", accounts);
          })
          .catch(error => {
            console.error("Direct JS: Error requesting accounts:", error);
          });
      ''']);
      
      final ethereum = js.context['ethereum'];
      
      // Request accounts
      final accounts = await js_util.promiseToFuture<List<dynamic>>(
        ethereum.callMethod('request', [js_util.jsify({'method': 'eth_requestAccounts'})]),
      );

      developer.log('MetamaskProvider: eth_requestAccounts returned: $accounts');
      
      if (accounts.isNotEmpty) {
        _currentAddress = accounts[0] as String;
        developer.log('MetamaskProvider: Connected to address: $_currentAddress');
        
        // Get chain ID
        _chainId = await js_util.promiseToFuture<String>(
          ethereum.callMethod('request', [js_util.jsify({'method': 'eth_chainId'})]),
        );
        developer.log('MetamaskProvider: Current chain ID: $_chainId');
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      developer.log('MetamaskProvider: No accounts returned');
      _isLoading = false;
      _error = 'No accounts found in MetaMask';
      notifyListeners();
      return false;
    } catch (e) {
      developer.log('MetamaskProvider: Error connecting: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Disconnect from MetaMask
  Future<void> disconnect() async {
    developer.log('MetamaskProvider: Disconnecting');
    _currentAddress = '';
    _publicKey = '';
    _success = false;
    _error = '';
    notifyListeners();
    return;
  }
  
  // Get encryption public key
  Future<bool> getEncryptionPublicKey() async {
    developer.log('MetamaskProvider: Getting encryption public key');
    
    if (!_isMetaMaskAvailable || _currentAddress.isEmpty) {
      _error = 'MetaMask not available or not connected';
      developer.log('MetamaskProvider: $_error');
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      developer.log('MetamaskProvider: Requesting encryption public key for $_currentAddress');
      final ethereum = js.context['ethereum'];
      
      // Try direct JavaScript approach first
      js.context.callMethod('eval', ['''
        console.log("Direct JS: Requesting encryption public key");
        window.ethereum.request({
          method: 'eth_getEncryptionPublicKey',
          params: ["${_currentAddress}"]
        })
          .then(result => {
            console.log("Direct JS: Public key received:", result);
          })
          .catch(error => {
            console.error("Direct JS: Error requesting public key:", error);
          });
      ''']);
      
      // Get encryption public key
      final result = await js_util.promiseToFuture<String>(
        ethereum.callMethod('request', [
          js_util.jsify({
            'method': 'eth_getEncryptionPublicKey',
            'params': [_currentAddress],
          })
        ]),
      );
      
      developer.log('MetamaskProvider: Public key received: ${result.substring(0, 20)}...');
      _publicKey = result;
      
      // In getEncryptionPublicKey method after receiving the result
      developer.log('Received public key from MetaMask: $result');
      // Save to backend
      developer.log('MetamaskProvider: Saving public key to backend');
      final saved = await savePublicKeyToBackend();
      _isLoading = false;
      notifyListeners();
      
      developer.log('MetamaskProvider: Save result: $saved');
      return saved;
    } catch (e) {
      developer.log('MetamaskProvider: Error getting public key: $e');
      _isLoading = false;
      _error = 'Failed to get encryption public key: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Save public key to backend
  Future<bool> savePublicKeyToBackend() async {
    developer.log('MetamaskProvider: Saving public key to backend');
    
    if (_currentAddress.isEmpty || _publicKey.isEmpty) {
      _error = 'Address or public key not available';
      developer.log('MetamaskProvider: $_error');
      notifyListeners();
      return false;
    }
    
    try {
      // Define GraphQL mutation - Updated to include both ethereumAddress and publicKey
      const String mutation = r'''
      mutation SaveMetamaskPublicKey($input: SaveMetamaskKeyInput!) {
        saveMetamaskPublicKey(input: $input) {
          _id
          username
          email
          publicKey
        }
      }
      ''';

      developer.log('MetamaskProvider: Getting GraphQL client');
      // Use the GraphQLService to get a client
      final client = GraphQLService.client;
      
      // Log what we're sending to help with debugging
      developer.log('MetamaskProvider: Ethereum Address: $_currentAddress');
      developer.log('MetamaskProvider: Public Key (first 30 chars): ${_publicKey.substring(0, _publicKey.length > 30 ? 30 : _publicKey.length)}...');
      
      // Use direct JavaScript for debugging
      js.context.callMethod('eval', ['''
        console.log("Direct JS: Saving public key");
        console.log("Ethereum Address:", "${_currentAddress}");
        console.log("Public Key:", "${_publicKey.substring(0, 30)}...");
      ''']);
      
      developer.log('MetamaskProvider: Sending GraphQL mutation');
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'ethereumAddress': _currentAddress,
              'publicKey': _publicKey,
            },
          },
        ),
      );
      
      if (result.hasException) {
        developer.log('MetamaskProvider: GraphQL error: ${result.exception}');
        _error = 'Failed to save public key: ${result.exception.toString()}';
        notifyListeners();
        return false;
      }
      
      // Log the successful result
      developer.log('MetamaskProvider: Public key saved successfully');
      developer.log('MetamaskProvider: GraphQL response: ${result.data}');
      
      // Check if the publicKey in the returned user is set
      final returnedUser = result.data?['saveMetamaskPublicKey'];
      if (returnedUser != null) {
        developer.log('MetamaskProvider: Returned user data: $returnedUser');
        final returnedPublicKey = returnedUser['publicKey'];
        developer.log('MetamaskProvider: Returned publicKey: $returnedPublicKey');
      }
      
      _success = true;
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('MetamaskProvider: Network error: $e');
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Sign a message with MetaMask
  Future<String?> signMessage(String message) async {
    developer.log('MetamaskProvider: Signing message');
    
    if (!_isMetaMaskAvailable || _currentAddress.isEmpty) {
      developer.log('MetamaskProvider: Cannot sign, not connected');
      return null;
    }

    try {
      developer.log('MetamaskProvider: Requesting personal_sign');
      final ethereum = js.context['ethereum'];
      
      final signature = await js_util.promiseToFuture<String>(
        ethereum.callMethod('request', [
          js_util.jsify({
            'method': 'personal_sign',
            'params': [
              message,
              _currentAddress,
            ],
          })
        ]),
      );
      
      developer.log('MetamaskProvider: Message signed successfully');
      return signature;
    } catch (e) {
      developer.log('MetamaskProvider: Error signing message: $e');
      _error = 'Failed to sign message: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
  
  // Switch chain
  Future<bool> switchChain(String chainId) async {
    developer.log('MetamaskProvider: Switching to chain $chainId');
    
    if (!_isMetaMaskAvailable || _currentAddress.isEmpty) {
      _error = 'MetaMask not available or not connected';
      developer.log('MetamaskProvider: $_error');
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      developer.log('MetamaskProvider: Requesting wallet_switchEthereumChain');
      final ethereum = js.context['ethereum'];
      
      await js_util.promiseToFuture(
        ethereum.callMethod('request', [
          js_util.jsify({
            'method': 'wallet_switchEthereumChain',
            'params': [{'chainId': chainId}],
          })
        ]),
      );
      
      _chainId = chainId;
      _isLoading = false;
      developer.log('MetamaskProvider: Chain switched successfully');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('MetamaskProvider: Error switching chain: $e');
      _isLoading = false;
      
      // Check if the error is because the chain hasn't been added
      // In that case, you might want to call addChain method
      _error = 'Failed to switch chain: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Add chain
  Future<bool> addChain({
    required String chainId,
    required String chainName,
    required String rpcUrl,
    required String currencyName,
    required String currencySymbol,
    int currencyDecimals = 18,
    String? blockExplorerUrl,
  }) async {
    developer.log('MetamaskProvider: Adding chain $chainName ($chainId)');
    
    if (!_isMetaMaskAvailable || _currentAddress.isEmpty) {
      _error = 'MetaMask not available or not connected';
      developer.log('MetamaskProvider: $_error');
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      developer.log('MetamaskProvider: Requesting wallet_addEthereumChain');
      final ethereum = js.context['ethereum'];
      
      final params = {
        'chainId': chainId,
        'chainName': chainName,
        'rpcUrls': [rpcUrl],
        'nativeCurrency': {
          'name': currencyName,
          'symbol': currencySymbol,
          'decimals': currencyDecimals
        },
      };
      
      if (blockExplorerUrl != null && blockExplorerUrl.isNotEmpty) {
        params['blockExplorerUrls'] = [blockExplorerUrl];
      }
      
      developer.log('MetamaskProvider: Chain params: $params');
      
      await js_util.promiseToFuture(
        ethereum.callMethod('request', [
          js_util.jsify({
            'method': 'wallet_addEthereumChain',
            'params': [params],
          })
        ]),
      );
      
      _isLoading = false;
      developer.log('MetamaskProvider: Chain added successfully');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('MetamaskProvider: Error adding chain: $e');
      _isLoading = false;
      _error = 'Failed to add chain: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}