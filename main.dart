import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const RBTopUpApp());

class RBTopUpApp extends StatelessWidget {
  const RBTopUpApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RB TOP UP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const HomePage(),
    );
  }
}

class Package {
  final int diamonds;
  final int price;
  const Package(this.diamonds, this.price);
}

const packages = [
  Package(100, 85), Package(310, 245), Package(520, 395),
  Package(1060, 780), Package(2180, 1520),
];

class Order {
  final String id, game, playerId, payment;
  final int diamonds, price;
  String status;
  Order(this.id, this.game, this.playerId, this.payment, this.diamonds, this.price, this.status);
}

final orders = <Order>[];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  String game = 'Free Fire';
  String payment = 'bKash';
  final player = TextEditingController();

  void createOrder() {
    if (player.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player ID দিন')),
      );
      return;
    }
    final p = packages[selected];
    final id = 'RB${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}${Random().nextInt(90)+10}';
    orders.insert(0, Order(id, game, player.text.trim(), payment, p.diamonds, p.price, 'Pending'));
    player.clear();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Order Created ✅'),
      content: Text('Order ID: $id\n\nPayment: $payment\nAmount: ৳${p.price}\n\nDemo mode: payment যাচাই করার পর admin থেকে order complete করতে হবে।'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ঠিক আছে'))],
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RB TOP UP', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Orders',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
            icon: const Icon(Icons.receipt_long),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF7E57C2)]),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('💎 RB TOP UP', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
              SizedBox(height: 6),
              Text('Fast & simple diamond top-up', style: TextStyle(color: Colors.white70, fontSize: 15)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Game', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: game,
            decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            items: const [DropdownMenuItem(value: 'Free Fire', child: Text('Free Fire')), DropdownMenuItem(value: 'Other Game', child: Text('Other Game'))],
            onChanged: (v) => setState(() => game = v!),
          ),
          const SizedBox(height: 16),
          const Text('Player ID', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: player,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'আপনার Player ID লিখুন', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('Diamond Package', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...List.generate(packages.length, (i) {
            final p = packages[i];
            return Card(
              elevation: selected == i ? 3 : 0,
              child: RadioListTile<int>(
                value: i, groupValue: selected, onChanged: (v) => setState(() => selected = v!),
                title: Text('💎 ${p.diamonds} Diamonds', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('৳${p.price}'),
              ),
            );
          }),
          const SizedBox(height: 12),
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: payment,
            decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            items: const [DropdownMenuItem(value: 'bKash', child: Text('bKash')), DropdownMenuItem(value: 'Nagad', child: Text('Nagad'))],
            onChanged: (v) => setState(() => payment = v!),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: createOrder,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Create Top-Up Order')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
            icon: const Icon(Icons.history), label: const Text('Order History'),
          ),
        ],
      ),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override State<OrdersPage> createState() => _OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orders.isEmpty
        ? const Center(child: Text('এখনও কোনো order নেই'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.diamond)),
                  title: Text('${o.diamonds} Diamonds • ৳${o.price}'),
                  subtitle: Text('${o.game} • ID: ${o.playerId}\nOrder: ${o.id} • ${o.payment}'),
                  isThreeLine: true,
                  trailing: Chip(label: Text(o.status)),
                ),
              );
            },
          ),
    );
  }
}
