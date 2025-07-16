import 'package:flutter/material.dart';
import 'package:pilots_lounge/services/data_seeder.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';
import 'package:pilots_lounge/widgets/enhanced_cards.dart';

class DataSeederPage extends StatefulWidget {
  const DataSeederPage({super.key});

  @override
  State<DataSeederPage> createState() => _DataSeederPageState();
}

class _DataSeederPageState extends State<DataSeederPage> {
  final DataSeeder _dataSeeder = DataSeeder();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  Future<void> _seedAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Seeding all data...';
      _isSuccess = false;
    });

    try {
      await _dataSeeder.seedAllData();
      setState(() {
        _statusMessage = '✅ All data seeded successfully!';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error seeding data: $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all data...';
      _isSuccess = false;
    });

    try {
      await _dataSeeder.clearAllData();
      setState(() {
        _statusMessage = '✅ All data cleared successfully!';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error clearing data: $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Seeder'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _statusMessage,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilots Lounge Data Seeder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This tool will populate your Firestore database with realistic aviation data for the Phoenix area.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Status Message
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess ? Colors.green[200]! : Colors.red[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.error,
                        color: _isSuccess ? Colors.green[600] : Colors.red[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Cards
              ActionCard(
                title: 'Seed All Data',
                subtitle: 'Add realistic aircraft, instructors, mechanics, flight schools, and airports',
                icon: Icons.cloud_upload,
                color: Colors.blue,
                onTap: _seedAllData,
              ),
              const SizedBox(height: 12),
              ActionCard(
                title: 'Clear All Data',
                subtitle: 'Remove all seeded data (use with caution)',
                icon: Icons.delete_forever,
                color: Colors.red,
                isDestructive: true,
                onTap: _clearAllData,
              ),
              const SizedBox(height: 24),

              // Data Overview
              const Text(
                'Data Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Aircraft',
                      value: '5',
                      subtitle: 'Rentals, Sales, Charters',
                      icon: Icons.flight,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Instructors',
                      value: '4',
                      subtitle: 'CFIs & DPEs',
                      icon: Icons.school,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Mechanics',
                      value: '3',
                      subtitle: 'A&P Technicians',
                      icon: Icons.build,
                      color: Colors.red,
                    ),
                    StatCard(
                      title: 'Flight Schools',
                      value: '4',
                      subtitle: 'Training Programs',
                      icon: Icons.account_balance,
                      color: Colors.teal,
                    ),
                    StatCard(
                      title: 'Airports',
                      value: '5',
                      subtitle: 'Phoenix Area',
                      icon: Icons.place,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 