import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:pilots_lounge/models/user_profile.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  UserProfile? _profile;
  List<Aircraft> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _loadListings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadListings(); // Refresh listings when app resumes
    }
  }

  Future<void> _loadProfile() async {
    final profile = await FirestoreService().getCurrentUserProfile();
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _loadListings() async {
    final listings = await FirestoreService().getCurrentUserListings();
    setState(() {
      _listings = listings;
    });
  }

  void _showEditListingDialog(Aircraft listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${listing.make} ${listing.model}'),
        content: const Text('Edit functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteListing(Aircraft listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete ${listing.make} ${listing.model}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirestoreService().deleteAircraftListing(listing.id);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted successfully!')));
        await _loadListings(); // Refresh the list
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting listing: $e')));
      }
    }
  }

  Future<void> _deleteAllListings() async {
    if (_listings.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Listings'),
        content: Text('Are you sure you want to delete all ${_listings.length} listings? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete all listings
        for (final listing in _listings) {
          await FirestoreService().deleteAircraftListing(listing.id);
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All listings deleted successfully!')));
        await _loadListings(); // Refresh the list
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting listings: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return AppScaffold(
      currentIndex: 0,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('No profile found.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user?.photoURL ?? ''),
                        radius: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(_profile!.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(_profile!.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Listing'),
                        onPressed: () => context.go('/listing-type-selection'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('My Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_listings.isNotEmpty)
                            TextButton.icon(
                              onPressed: _deleteAllListings,
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              label: const Text('Delete All', style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_listings.isEmpty)
                        const Text('No listings yet. Create your first one!', style: TextStyle(color: Colors.grey))
                      else
                        ...(_listings.map((listing) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('${listing.make} ${listing.model}'),
                            subtitle: Text('${listing.registration} • \$${listing.price}/hr • ${listing.location}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditListingDialog(listing);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteListing(listing);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ))),
                    ],
                  ),
                ),
    );
  }
} 
