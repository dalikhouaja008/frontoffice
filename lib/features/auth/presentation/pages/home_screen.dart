import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/two_factor_dialog.dart';
import '../../../land/presentation/pages/add_land_page.dart';
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
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    final secureStorage = context.read<SecureStorageService>();
    final remoteDataSource = AuthRemoteDataSourceImpl(
      client: GraphQLService.client,
      secureStorage: secureStorage,
    );

    _twoFactorAuthRepository = TwoFactorAuthRepositoryImpl(remoteDataSource);

    _pages.addAll([
      _buildHomePage(),
      AddLandPage(),
    ]);

    if (!widget.user.isTwoFactorEnabled) {
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
            Navigator.of(context).pop(); // Close dialog
            Future.delayed(Duration.zero, () {
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
              setState(() {});  // Refresh HomeScreen without navigation
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            "Hello, ${widget.user.username}!",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.user.username}"),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Land',
          ),
        ],
      ),
    );
  }
}
