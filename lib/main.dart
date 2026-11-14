import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ExcessBaggageApp());
}

class ExcessBaggageApp extends StatelessWidget {
  const ExcessBaggageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Estimator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const AboutScreen(),
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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String _ticketClass = 'Economy'; // Economy = 20kg, Business = 40kg[cite: 1]

  String _excessWeightResult = '';
  String _excessChargeResult = '';
  String _totalPayableResult = '';

  void _calculateFee() {
    if (_weightController.text.isEmpty || _rateController.text.isEmpty) {
      setState(() {
        _excessWeightResult = 'Please fill in all inputs';
        _excessChargeResult = '';
        _totalPayableResult = '';
      });
      return;
    }

    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double rate = double.tryParse(_rateController.text) ?? 0.0;

    // X is 20 kg for economy and 40 kg for business[cite: 1]
    double allowance = (_ticketClass == 'Economy') ? 20.0 : 40.0;

    // Excess baggage weight (never negative)[cite: 1]
    double excessWeight = weight - allowance;
    if (excessWeight < 0) {
      excessWeight = 0.0;
    }

    // Excess baggage charge = excess weight * rate[cite: 1]
    double excessCharge = excessWeight * rate;

    // Total amount payable = excess charge + (8% * excess charge)[cite: 1]
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
        title: const Text('Excess Baggage Estimator'), // Visible app title[cite: 2]
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

            // Input 1: Checked Baggage Weight[cite: 1]
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Checked Baggage Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Input 2: Ticket Class Dropdown[cite: 1, 2]
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
                    DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg allowance)[cite: 1]')),
                    DropdownMenuItem(value: 'Business', child: Text('Business (40 kg allowance)[cite: 1]')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _ticketClass = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input 3: Rate per kg[cite: 1]
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Excess Baggage Rate per kg (RM)[cite: 1]',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _calculateFee,
              child: const Text('Calculate Fee', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // Outputs[cite: 1]
            const Text(
              'Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),

            Text('1. Excess Baggage Weight: $_excessWeightResult',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('2. Excess Baggage Charge: $_excessChargeResult',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('3. Total Amount Payable (inc. 8% tax): $_totalPayableResult',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  // Function to launch the GitHub URL in the external browser
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.luggage, size: 80, color: Colors.blue), // Application Icon[cite: 2]
            ),
            const SizedBox(height: 20),
            const Text('Author Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text('• Name: Nazreen'), // Author Info[cite: 2]
            const Text('• Matric No: [Insert Matric Number]'), // Author Info[cite: 2]
            const Text('• Course: Mobile Technology'), // Author Info[cite: 2]
            const SizedBox(height: 20),
            const Text('GitHub Repository', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            // Clickable GitHub Repository URL[cite: 2]
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
              child: Text('© 2026 Nazreen. All rights reserved.', // Copyright Notice[cite: 2]
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}