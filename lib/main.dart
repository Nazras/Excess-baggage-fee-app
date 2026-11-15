import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ExcessBaggageApp());
}

class ExcessBaggageApp extends StatelessWidget {
  const ExcessBaggageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Estimator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String _ticketClass = 'Economy';

  String _excessWeightResult = '';
  String _excessChargeResult = '';
  String _totalPayableResult = '';

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculateFee() {
    if (_weightController.text.isEmpty || _rateController.text.isEmpty) {
      setState(() {
        _excessWeightResult = 'Please fill in all inputs';
        _excessChargeResult = '';
        _totalPayableResult = '';
      });
      return;
    }

    double? weight = double.tryParse(_weightController.text);
    double? rate = double.tryParse(_rateController.text);

    if (weight == null || rate == null || weight < 0 || rate < 0) {
      setState(() {
        _excessWeightResult = 'Please enter valid positive numbers';
        _excessChargeResult = '';
        _totalPayableResult = '';
      });
      return;
    }

    // Allowance: 20 kg for Economy, 40 kg for Business
    double allowance = (_ticketClass == 'Economy') ? 20.0 : 40.0;

    // Excess baggage weight (minimum 0)
    double excessWeight = weight - allowance;
    if (excessWeight < 0) {
      excessWeight = 0.0;
    }

    // Excess baggage charge
    double excessCharge = excessWeight * rate;

    // Total amount payable including 8% service tax
    double tax = excessCharge * 0.08;
    double totalPayable = excessCharge + tax;

    setState(() {
      _excessWeightResult = '${excessWeight.toStringAsFixed(1)} kg';
      _excessChargeResult = 'RM ${excessCharge.toStringAsFixed(2)}';
      _totalPayableResult = 'RM ${totalPayable.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excess Baggage Estimator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Travel Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Input 1: Checked Baggage Weight
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Checked Baggage Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Input 2: Ticket Class Dropdown
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ticket Class',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _ticketClass,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'Economy',
                      child: Text('Economy (20 kg allowance)'),
                    ),
                    DropdownMenuItem(
                      value: 'Business',
                      child: Text('Business (40 kg allowance)'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _ticketClass = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input 3: Rate per kg
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Excess Baggage Rate per kg (RM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _calculateFee,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Calculate Fee', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // Results Section
            const Text(
              'Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),

            Text(
              '1. Excess Baggage Weight: $_excessWeightResult',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '2. Excess Baggage Charge: $_excessChargeResult',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '3. Total Amount Payable (inc. 8% tax): $_totalPayableResult',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchGitHubURL() async {
    final Uri url = Uri.parse('https://github.com/Nazras/Excess-baggage-fee-app');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/icon/app_icon.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Author Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Text('• Name: Nazreen Asyraaf bin Arman'),
            const SizedBox(height: 4),
            const Text('• Matric No: 2024670682'),
            const SizedBox(height: 4),
            const Text('• Course: ICT602 - MOBILE TECHNOLOGY AND DEVELOPMENT'),
            const SizedBox(height: 20),
            const Text(
              'GitHub Repository',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            InkWell(
              onTap: _launchGitHubURL,
              child: const Text(
                'https://github.com/Nazras/Excess-baggage-fee-app',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                '© 2026 Nazreen Asyraaf bin Arman. All rights reserved.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}