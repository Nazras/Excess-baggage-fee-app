import 'package:flutter/material.dart';

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

  // Pages for Bottom Navigation Bar
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
  // Controllers for inputs
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String _ticketClass = 'Economy'; // Options: Economy, Business[cite: 1]

  // Outputs[cite: 1]
  String _excessWeightResult = '';
  String _excessChargeResult = '';
  String _totalPayableResult = '';

  void _calculateFee() {
    // Basic validation
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

    // Excess baggage weight calculation[cite: 1]
    double excessWeight = weight - allowance;
    if (excessWeight < 0) {
      excessWeight = 0.0; // Never negative[cite: 1]
    }

    // Excess baggage charge calculation[cite: 1]
    double excessCharge = excessWeight * rate;

    // Total amount payable with 8% service tax[cite: 1]
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

            // Input 1: Baggage Weight[cite: 1]
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Checked Baggage Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Input 2: Ticket Class (Dropdown widget)
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
                    DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg allowance)')),
                    DropdownMenuItem(value: 'Business', child: Text('Business (40 kg allowance)')),
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Excess Baggage Rate per kg (RM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Calculate Button
            ElevatedButton(
              onPressed: _calculateFee,
              child: const Text('Calculate Fee', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // Outputs Section[cite: 1]
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
          children: const [
            Center(
              child: Icon(Icons.luggage, size: 80, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Text('Author Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Text('• Name: Nazreen Asyraaf bin Arman'),
            Text('• Matric No: 2024670682'),
            Text('• ICT602 - MOBILE TECHNOLOGY AND DEVELOPMENT'),
            SizedBox(height: 20),
            Text('GitHub Repository', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Text('https://github.com/nazreen/excess-baggage-estimator',
                style: TextStyle(color: Colors.blue)),
            SizedBox(height: 20),
            Center(
              child: Text('© 2026 Nazreen. All rights reserved.',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}