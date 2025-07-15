import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:pilots_lounge/services/auth/auth_service.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSigningIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    final userCred = await AuthService().signInWithGoogle();
    if (userCred != null) {
      // Ensure user profile exists in Firestore
      await FirestoreService().ensureUserProfile();
    }
    setState(() => _isSigningIn = false);
    if (userCred == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in cancelled or failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return AppScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Section
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Replace 'assets/images/logo.png' with your actual logo file path
                  Image.asset(
                    'assets/images/logo.png',
                    height: 160,
                    width: 400,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if logo is not found
                      return Container(
                        height: 160,
                        width: 400,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flight,
                          size: 80,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to Pilots Lounge',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your comprehensive aviation marketplace',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (user == null) ...[
              _isSigningIn
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _handleGoogleSignIn,
                      ),
                    ),
              const SizedBox(height: 24),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL ?? ''),
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Text('Welcome, ${user.displayName ?? 'User'}!',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sign out',
                    onPressed: () async {
                      await AuthService().signOut();
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('My Profile'),
                onPressed: () => context.go('/profile'),
              ),
              const SizedBox(height: 24),
            ],
            // Feature Cards
            _buildFeatureCard(
              context,
              'Aircraft Rentals',
              'Find aircraft for rent with detailed specs, avionics, and insurance requirements',
              Icons.flight,
              Colors.blue,
              () => context.go('/rentals'),
            ),
            _buildFeatureCard(
              context,
              'Charter Services',
              'Book charter flights with locations, pricing, and time information',
              Icons.airplane_ticket,
              Colors.green,
              () => context.go('/charters'),
            ),
            _buildFeatureCard(
              context,
              'CFIs & DPEs',
              'Connect with certified flight instructors and designated pilot examiners',
              Icons.school,
              Colors.orange,
              () => context.go('/instructors'),
            ),
            _buildFeatureCard(
              context,
              'Aircraft for Sale',
              'Browse aircraft listings with owner reviews and pre-buy connections',
              Icons.sell,
              Colors.purple,
              () => context.go('/airplanes-sale'),
            ),
            _buildFeatureCard(
              context,
              'Flight Schools',
              'Compare flight schools with honest reviews and transparent pricing',
              Icons.account_balance,
              Colors.teal,
              () => context.go('/flight-schools'),
            ),
            _buildFeatureCard(
              context,
              'Mechanics',
              'Find A&P mechanics with specializations and average quotes',
              Icons.build,
              Colors.red,
              () => context.go('/mechanics'),
            ),
            _buildFeatureCard(
              context,
              'Airport Reviews',
              'Discover airport amenities, restaurants, and services for pilots',
              Icons.place,
              Colors.indigo,
              () => context.go('/airports'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFeatureList('• Zillow-style mapping for all services'),
            _buildFeatureList('• Honest reviews from real users'),
            _buildFeatureList('• Transparent pricing with no hidden fees'),
            _buildFeatureList('• Owner responses to reviews'),
            _buildFeatureList('• Time-based listings (auto-removal if not updated)'),
            _buildFeatureList('• Pre-buy inspection connections'),
            _buildFeatureList('• Ferry pilot services'),
            _buildFeatureList('• International flight support'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, 
                           IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
