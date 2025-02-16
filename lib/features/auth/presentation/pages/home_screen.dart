import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/two_factor_dialog.dart';
import '../../domain/entities/user.dart';
import '../bloc/2FA/two_factor_auth_bloc.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TwoFactorAuthRepository _twoFactorAuthRepository;

@override
void initState() {
  super.initState();
  print('[HomeScreen: 🚀 Initializing HomeScreen state'
        '\n└─ User: raednas');

  // Récupérer les services via Provider
  final secureStorage = context.read<SecureStorageService>();
  final remoteDataSource = AuthRemoteDataSourceImpl(
    client: GraphQLService.client,
    secureStorage: secureStorage,
  );

  print('HomeScreen: 🏭 Creating TwoFactorAuthRepository');
        
  _twoFactorAuthRepository = TwoFactorAuthRepositoryImpl(remoteDataSource);

  if (!widget.user.isTwoFactorEnabled) {
    print('HomeScreen: 🔔 Scheduling 2FA dialog');
          
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _show2FADialog();
    });
  }
}

  void _show2FADialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => TwoFactorAuthBloc(
          repository: _twoFactorAuthRepository,
        ),
        child: TwoFactorDialog(
          user: widget.user,
          onSkip: () {
            Navigator.of(context).pop(); // Ferme le dialogue
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Vous pouvez activer la 2FA à tout moment via le menu de sécurité',
                ),
                action: SnackBarAction(
                  label: 'Activate',
                  onPressed: _show2FADialog,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.user.username}"),
        actions: [
          if (!widget.user.isTwoFactorEnabled)
            IconButton(
              icon: const Icon(Icons.security_outlined),
              onPressed: _show2FADialog,
              tooltip: 'Activate 2FA',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  "Hello, ${widget.user.username}!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Email: ${widget.user.email}",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                Text(
                  "Role: ${widget.user.role}",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                if (!widget.user.isTwoFactorEnabled)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.security),
                    label: const Text("Activer 2FA"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _show2FADialog,
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Déconnexion"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Badge de sécurité si 2FA non activé
          if (!widget.user.isTwoFactorEnabled)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange.shade900,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '2FA non activé',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}