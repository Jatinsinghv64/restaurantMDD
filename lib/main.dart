import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null ? const LoginScreen() : const MainScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
// auth_service.dart

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to track user authentication state
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final auth = Provider.of<AuthService>(context, listen: false);
      final user = await auth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }
}
class RestaurantAdminApp extends StatelessWidget {
  const RestaurantAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const MenuManagementScreen(),
    const OrdersScreen(),
    const RidersScreen(),
    const AnalyticsScreen(),
  ];

  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Riders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // First row of stat cards
          Row(
            children: [
              // Today's Orders card
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Orders')
                      .where('timestamps.placed',
                      isGreaterThan: Timestamp.fromDate(
                          DateTime.now().subtract(const Duration(days: 1)))
                  )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading data'));
                    }
                    final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _StatCard(
                      title: "Today's Orders",
                      value: count.toString(),
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Active Riders card
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Riders')
                      .where('isAvailable', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading data'));
                    }
                    final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _StatCard(
                      title: 'Active Riders',
                      value: count.toString(),
                      icon: Icons.delivery_dining,
                      color: Colors.green,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Second row of stat cards
          Row(
            children: [
              // Revenue card
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Orders')
                      .where('timestamps.placed',
                      isGreaterThan: Timestamp.fromDate(
                          DateTime.now().subtract(const Duration(days: 1)))
                  )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading data'));
                    }
                    double totalRevenue = 0;
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        totalRevenue += (doc['totalAmount'] as num).toDouble();
                      }
                    }
                    return _StatCard(
                      title: 'Revenue',
                      value: '\$${totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Menu Items card
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('menu_items')
                      .where('isAvailable', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading data'));
                    }
                    final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return _StatCard(
                      title: 'Menu Items',
                      value: count.toString(),
                      icon: Icons.restaurant,
                      color: Colors.purple,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Orders section
          const Text(
            'Recent Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .orderBy('timestamps.placed', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No recent orders'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    return _OrderListItem(order: order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final data = order.data() as Map<String, dynamic>;
    final items = data['menu_items'] as Map<String, dynamic>;
    final itemNames = items.keys.join(', ');
    final total = data['totalAmount'] ?? 0;
    final status = data['status'] ?? 'placed';
    final timestamp = (data['timestamps']?['placed'] as Timestamp?)?.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.shopping_bag, color: Colors.blue),
        title: Text(itemNames),
        subtitle: Text(
            '${DateFormat('MMM dd, hh:mm a').format(timestamp!)} • \$$total'),
        trailing: Chip(
          label: Text(
            status,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _getStatusColor(status),
        ),
        onTap: () {
          // Navigate to order details
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.blue;
      case 'prepared':
        return Colors.orange;
      case 'pickedup':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}





class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Delivery'),
            Tab(text: 'Takeaway'),
            Tab(text: 'Dine-in'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status filter chips
          _buildStatusFilterBar(),

          // Orders list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('delivery'),
                _buildOrdersList('take_away'),
                _buildOrdersList('dine-in'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip('All', 'all'),
            _buildStatusChip('Placed', 'pending'),
            _buildStatusChip('Prepared', 'prepared'),
            _buildStatusChip('Picked Up', 'pickedUp'),
            _buildStatusChip('Delivered', 'delivered'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedStatus == value,
        onSelected: (selected) => setState(() => _selectedStatus = selected ? value : 'all'),
      ),
    );
  }

  Widget _buildOrdersList(String orderType) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getOrdersStream(orderType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final orderDoc = snapshot.data!.docs[index];
            return _OrderCard(
              order: orderDoc,
              orderType: orderType,
              onStatusChange: _updateOrderStatus,
              onAssigned: _assignRider,
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getOrdersStream(String orderType) {
    final baseQuery = FirebaseFirestore.instance
        .collection('Orders')
        .where('Order_type', isEqualTo: orderType)
        .orderBy('timestamp', descending: true);

    return _selectedStatus == 'all'
        ? baseQuery.snapshots()
        : baseQuery.where('status', isEqualTo: _selectedStatus).snapshots();
  }

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _assignRider(BuildContext context, String orderId) async {
    final rider = await showDialog<String>(
      context: context,
      builder: (context) => const _RiderSelectionDialog(),
    );

    if (rider != null && rider.isNotEmpty) {
      try {
        final updateMap = {
          'status': 'pickedUp',
          'riderId': rider,
          'timestamps': {'pickedUp': FieldValue.serverTimestamp()},
        };
        await FirebaseFirestore.instance
            .collection('Orders')
            .doc(orderId)
            .update(updateMap);

        // Also update rider's assigned order
        await FirebaseFirestore.instance
            .collection('Riders')
            .doc(rider)
            .update({'assignedOrderId': orderId});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rider "$rider" assigned to order $orderId.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign rider: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _OrderCard extends StatelessWidget {
  final DocumentSnapshot order;
  final String orderType;
  final Function(BuildContext, String, String) onStatusChange;
  final Function(BuildContext, String) onAssigned;

  const _OrderCard({
    required this.order,
    required this.orderType,
    required this.onStatusChange,
    required this.onAssigned,
  });

  @override
  Widget build(BuildContext context) {
    final data = order.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final status = data['status']?.toString() ?? 'pending';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final orderNumber = data['dailyOrderNumber'] ?? '';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('Order #$orderNumber'),
        subtitle: Text(
          timestamp != null
              ? DateFormat('MMM dd, hh:mm a').format(timestamp)
              : 'No date',
        ),
        trailing: Chip(
          label: Text(status.toUpperCase()),
          backgroundColor: _getStatusColor(status),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order type specific details
                if (orderType == 'delivery') ...[
                  _buildDetailRow(Icons.person, data['customerName'] ?? 'No name'),
                  _buildDetailRow(Icons.phone, data['customerPhone'] ?? 'No phone'),
                  _buildDetailRow(Icons.location_on,
                      '${data['deliveryAddress']?['street'] ?? ''}, ${data['deliveryAddress']?['city'] ?? ''}'),
                  if (data['riderId']?.isNotEmpty == true)
                    _buildDetailRow(Icons.delivery_dining, 'Rider assigned: ${data['riderId']}'),
                ],
                if (orderType == 'take_away') ...[
                  _buildDetailRow(Icons.directions_car, 'Pickup type: ${data['pickupDetails']?['type'] ?? 'Not specified'}'),
                  if (data['pickupDetails']?['type'] == 'by_car') ...[
                    _buildDetailRow(Icons.directions_car, 'Car number: ${data['pickupDetails']?['carNumber'] ?? ''}'),
                    _buildDetailRow(Icons.directions_car, 'Car model: ${data['pickupDetails']?['carModel'] ?? ''}'),
                    _buildDetailRow(Icons.color_lens, 'Car color: ${data['pickupDetails']?['carColor'] ?? ''}'),
                  ],
                ],
                if (orderType == 'dine-in') ...[
                  _buildDetailRow(Icons.group, 'Guests: ${data['numberOfGuests'] ?? ''}'),
                  _buildDetailRow(Icons.table_restaurant, 'Tables: ${data['numberOfTables'] ?? ''}'),
                  if (data['orderTime'] != null)
                    _buildDetailRow(Icons.access_time,
                        'Reservation time: ${DateFormat('hh:mm a').format((data['orderTime'] as Timestamp).toDate())}'),
                ],

                const Divider(),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...items.map((item) => ListTile(
                  leading: item['imageUrl'] != null
                      ? Image.network(item['imageUrl'], width: 50, height: 50)
                      : const Icon(Icons.fastfood),
                  title: Text(item['name'] ?? 'Unnamed item'),
                  subtitle: Text('Qty: ${item['quantity']} × \$${item['price']}'),
                  trailing: Text('\$${item['total']}'),
                )).toList(),

                const Divider(),
                _buildTotalRow('Subtotal:', data['subtotal']),
                _buildTotalRow('Tax:', data['tax']),
                _buildTotalRow('Total:', data['totalAmount'], isBold: true),

                const SizedBox(height: 16),
                if (status == 'pending')
                  ElevatedButton(
                    onPressed: () => onStatusChange(context, order.id, 'prepared'),
                    child: const Text('Mark as Prepared'),
                  ),
                if (status == 'prepared' && orderType == 'delivery')
                  ElevatedButton(
                    onPressed: () => onAssigned(context, order.id),
                    child: const Text('Assign Rider'),
                  ),
                if (status == 'prepared' && orderType != 'delivery')
                  ElevatedButton(
                    onPressed: () => onStatusChange(context, order.id, 'pickedUp'),
                    child: const Text('Mark as Ready for Pickup'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, dynamic amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(
            '\$${(amount is num ? amount.toStringAsFixed(2) : amount?.toString() ?? '0.00')}',
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.blue;
      case 'prepared': return Colors.orange;
      case 'pickedup': return Colors.purple;
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }
}

class _RiderSelectionDialog extends StatelessWidget {
  const _RiderSelectionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Rider'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Drivers')
              .where('isAvailable', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No available riders'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var rider = snapshot.data!.docs[index];
                var data = rider.data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['profileImageUrl'] ?? ''),
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['email']),
                  onTap: () {
                    Navigator.pop(context, data['email']);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}





class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  String _selectedOrderType = 'all'; // 'all', 'delivery', 'take_away', 'dine-in'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOrderTypeTabs(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRangeSelector(),
                const SizedBox(height: 20),
                const Text(
                  'Sales Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildSalesChart(),
                const SizedBox(height: 20),
                const Text(
                  'Top Menu Items',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildTopItemsList(),
                const SizedBox(height: 20),
                const Text(
                  'Order Status Distribution',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildOrderStatusChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeTabs() {
    return TabBar(
      controller: _tabController,
      onTap: (index) {
        setState(() {
          _selectedOrderType = index == 0
              ? 'all'
              : index == 1
              ? 'delivery'
              : index == 2
              ? 'take_away'
              : 'dine-in';
        });
      },
      tabs: const [
        Tab(text: 'All Orders'),
        Tab(text: 'Delivery'),
        Tab(text: 'Takeaway'),
        Tab(text: 'Dine-in'),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final newRange = await showDateRangePicker(
                context: context,
                initialDateRange: _dateRange,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (newRange != null) {
                setState(() {
                  _dateRange = newRange;
                });
              }
            },
            child: Text(
              '${DateFormat('MMM dd, yyyy').format(_dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange.end)}',
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              _dateRange = DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return SizedBox(
      height: 300,
      child: StreamBuilder<QuerySnapshot>(
        stream: _getOrdersQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders in selected range'));
          }

          // Group orders by day and type
          final ordersByDay = <DateTime, double>{};
          final ordersByType = <String, double>{'delivery': 0, 'take_away': 0, 'dine-in': 0};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp;
            final date = timestamp.toDate();
            final day = DateTime(date.year, date.month, date.day);
            final total = (data['totalAmount'] as num?)?.toDouble() ?? 0;
            final orderType = data['Order_type'] as String? ?? 'unknown';

            ordersByDay.update(day, (value) => value + total, ifAbsent: () => total);

            if (ordersByType.containsKey(orderType)) {
              ordersByType[orderType] = ordersByType[orderType]! + total;
            }
          }

          // Fill in missing days with 0
          final daysInRange = _dateRange.end.difference(_dateRange.start).inDays;
          final allDays = List.generate(daysInRange + 1, (index) {
            return DateTime(
              _dateRange.start.year,
              _dateRange.start.month,
              _dateRange.start.day + index,
            );
          });

          final chartData = allDays.map((day) {
            return SalesData(
              day,
              ordersByDay[day] ?? 0,
              DateFormat('MMM dd').format(day),
            );
          }).toList();

          return SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            series: <CartesianSeries<SalesData, String>>[
              ColumnSeries<SalesData, String>(
                dataSource: chartData,
                xValueMapper: (SalesData sales, _) => sales.label,
                yValueMapper: (SalesData sales, _) => sales.amount,
                color: Colors.blue,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopItemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getOrdersQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders in selected range'));
        }

        // Count item occurrences
        final itemCounts = <String, int>{};
        final itemRevenue = <String, double>{};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

          for (var item in items) {
            final itemName = item['name'] ?? 'Unknown';
            final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
            final price = (item['price'] as num?)?.toDouble() ?? 0;

            itemCounts.update(itemName, (value) => value + quantity, ifAbsent: () => quantity);
            itemRevenue.update(itemName, (value) => value + (price * quantity),
                ifAbsent: () => price * quantity);
          }
        }

        if (itemCounts.isEmpty) {
          return const Center(child: Text('No items found'));
        }

        // Sort by count descending
        final sortedItems = itemCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Take top 5
        final topItems = sortedItems.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topItems.length,
          itemBuilder: (context, index) {
            final item = topItems[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Text('${index + 1}'),
              ),
              title: Text(item.key),
              subtitle: Text('\$${itemRevenue[item.key]?.toStringAsFixed(2) ?? '0.00'} revenue'),
              trailing: Text('${item.value} sold'),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderStatusChart() {
    return SizedBox(
      height: 300,
      child: StreamBuilder<QuerySnapshot>(
        stream: _getOrdersQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders in selected range'));
          }

          // Count statuses
          final statusCounts = <String, int>{};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'unknown';
            statusCounts.update(status, (value) => value + 1, ifAbsent: () => 1);
          }

          final chartData = statusCounts.entries.map((entry) {
            return StatusData(
              entry.key,
              entry.value,
              _getStatusColor(entry.key),
            );
          }).toList();

          return SfCircularChart(
            legend: Legend(isVisible: true),
            series: <CircularSeries>[
              PieSeries<StatusData, String>(
                dataSource: chartData,
                xValueMapper: (StatusData data, _) => data.status,
                yValueMapper: (StatusData data, _) => data.count,
                pointColorMapper: (StatusData data, _) => data.color,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          );
        },
      ),
    );
  }

  Query _getOrdersQuery() {
    Query query = FirebaseFirestore.instance
        .collection('Orders')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(_dateRange.start))
        .where('timestamp', isLessThan: Timestamp.fromDate(_dateRange.end.add(const Duration(days: 1))))
        .orderBy('timestamp', descending: true);

    if (_selectedOrderType != 'all') {
      query = query.where('Order_type', isEqualTo: _selectedOrderType);
    }

    return query;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.blue;
      case 'prepared': return Colors.orange;
      case 'pickedup': return Colors.purple;
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }
}

class SalesData {
  final DateTime date;
  final double amount;
  final String label;

  SalesData(this.date, this.amount, this.label);
}

class StatusData {
  final String status;
  final int count;
  final Color color;

  StatusData(this.status, this.count, this.color);
}


class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu Items'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CategoriesTab(),
          MenuItemsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCategoryDialog(context);
          } else {
            _showAddMenuItemDialog(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showAddMenuItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMenuItemDialog(),
    );
  }
}



class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('menu_categories')
          .orderBy('sortOrder')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No categories found'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var category = snapshot.data!.docs[index];
            return CategoryCard(category: category);
          },
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final QueryDocumentSnapshot category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final data = category.data() as Map<String, dynamic>;
    final isActive = data['isActive'] ?? false;
    final imageUrl = data['imageUrl'] as String? ?? '';
    final branchId = data['branchId'] as String? ?? 'No branch';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
            : const CircleAvatar(child: Icon(Icons.category)),
        title: Text(data['name'] ?? 'Unnamed Category'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Branch: $branchId'),
            Text('Sort Order: ${data['sortOrder'] ?? '0'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive,
              onChanged: (value) {
                category.reference.update({'isActive': value});
              },
              activeColor: Colors.green,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCategoryDialog(context, category),
            ),
          ],
        ),
        onTap: () => _showCategoryDetails(context, category),
      ),
    );
  }

  void _showEditCategoryDialog(
      BuildContext context, QueryDocumentSnapshot category) {
    final data = category.data() as Map<String, dynamic>;
    final branches = FirebaseFirestore.instance.collection('branches').snapshots();

    final nameController = TextEditingController(text: data['name'] as String? ?? '');
    final sortOrderController = TextEditingController(
        text: (data['sortOrder'] != null) ? data['sortOrder'].toString() : '0');
    final imageUrlController =
    TextEditingController(text: data['imageUrl'] as String? ?? '');
    String? selectedBranchId = data['branchId'] as String?;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                  ),
                  TextFormField(
                    controller: sortOrderController,
                    decoration: const InputDecoration(labelText: 'Sort Order'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: branches,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final branchList = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedBranchId,
                        decoration: const InputDecoration(labelText: 'Branch'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select a branch'),
                          ),
                          ...branchList.map((branch) {
                            final branchData = branch.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: branchData['branchId'],
                              child: Text(branchData['name'] ?? 'Unnamed Branch'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBranchId = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: data['isActive'] ?? false,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedData = <String, dynamic>{
                    'name': nameController.text,
                    'sortOrder': int.tryParse(sortOrderController.text) ?? 0,
                    'branchId': selectedBranchId,
                    'imageUrl': imageUrlController.text.isNotEmpty
                        ? imageUrlController.text
                        : null,
                    'isActive': data['isActive'] ?? true,
                  };
                  category.reference.update(updatedData);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showCategoryDetails(
      BuildContext context, QueryDocumentSnapshot category) {
    final data = category.data() as Map<String, dynamic>;
    final branchId = data['branchId'] as String? ?? 'No branch specified';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name'] ?? 'Category Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((data['imageUrl'] as String?)?.isNotEmpty == true)
                  Center(
                    child: Image.network(
                      data['imageUrl'],
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Branch: $branchId'),
                const SizedBox(height: 8),
                Text('Sort Order: ${data['sortOrder'] ?? '0'}'),
                const SizedBox(height: 8),
                Text(
                  'Status: ${data['isActive'] == true ? 'Active' : 'Inactive'}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}



class MenuItemsTab extends StatelessWidget {
  const MenuItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('menu_items')
          .orderBy('sortOrder')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No menu items found'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var item = snapshot.data!.docs[index];
            return MenuItemCard(item: item);
          },
        );
      },
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final QueryDocumentSnapshot item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final data = item.data() as Map<String, dynamic>;
    final isAvailable = data['isAvailable'] ?? false;
    final isPopular = data['isPopular'] ?? false;
    final imageUrl = data['imageUrl'] as String?; // Changed to handle single string
    final variants = data['variants'] as Map<String, dynamic>? ?? {};
    final tags = data['tags'] as Map<String, dynamic>? ?? {}; // Changed from dietaryTags to tags

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _showMenuItemDetails(context, item),
        child: Column(
          children: [
            ListTile(
              leading: imageUrl != null
                  ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
                  : const CircleAvatar(child: Icon(Icons.fastfood)),
              title: Text(data['name'] ?? 'Unnamed Item'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['description'] ?? 'No description'),
                  Text('\$${data['price']?.toStringAsFixed(2) ?? '0.00'}'), // Changed from basePrice to price
                  if (variants.isNotEmpty)
                    Text('${variants.length} variants available'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: isPopular ? Colors.amber : Colors.grey, // Changed from isFeatured to isPopular
                    ),
                    onPressed: () {
                      item.reference.update({'isPopular': !isPopular});
                    },
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (value) {
                      item.reference.update({'isAvailable': value});
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Wrap(
                  spacing: 8,
                  children: tags.entries
                      .where((e) => e.value == true)
                      .map((entry) {
                    return Chip(
                      label: Text(entry.key),
                      backgroundColor: Colors.green[100],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMenuItemDetails(BuildContext context, QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl'] as String?; // Changed to handle single string
    final variants = data['variants'] as Map<String, dynamic>? ?? {};
    final tags = data['tags'] as Map<String, dynamic>? ?? {}; // Changed from dietaryTags to tags
    final estimatedTime = data['EstimatedTime'] as String?;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name'] ?? 'Item Details'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.75,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    SizedBox(
                      height: 150,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(data['description'] ?? 'No description available'),
                  const SizedBox(height: 16),
                  Text(
                    'Price: \$${data['price']?.toStringAsFixed(2) ?? '0.00'}', // Changed from basePrice to price
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (estimatedTime != null) ...[
                    Text(
                      'Estimated Time: $estimatedTime',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (variants.isNotEmpty) ...[
                    const Text(
                      'Variants:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...variants.entries.map((variant) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(variant.value['name'] ?? 'Variant'),
                            const Spacer(),
                            Text(
                              '+\$${variant.value['variantprice']?.toStringAsFixed(2)}', // Changed from priceDelta to variantprice
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  if (tags.isNotEmpty) ...[
                    const Text(
                      'Tags:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: tags.entries.map((entry) {
                        return Chip(
                          label: Text(entry.key),
                          backgroundColor: entry.value == true
                              ? Colors.green[100]
                              : Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Branch: ${data['branchId'] ?? 'No branch specified'}'),
                  const SizedBox(height: 8),
                  Text('Category: ${data['categoryId'] ?? 'Uncategorized'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${data['isAvailable'] == true ? 'Available' : 'Unavailable'}',
                  ),
                  Text(
                    'Popular: ${data['isPopular'] == true ? 'Yes' : 'No'}', // Changed from isFeatured to isPopular
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.pop(context);
                _showEditMenuItemDialog(context, item);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditMenuItemDialog(BuildContext context, QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name']);
    final descriptionController = TextEditingController(text: data['description']);
    final priceController = TextEditingController(text: data['price']?.toString()); // Changed from basePrice to price
    final sortOrderController = TextEditingController(text: data['sortOrder']?.toString());
    final estimatedTimeController = TextEditingController(text: data['EstimatedTime']);
    final imageUrlController = TextEditingController(text: data['imageUrl'] as String?);
    final tags = Map<String, bool>.from(
      data['tags'] as Map<String, dynamic>? ?? {}, // Changed from dietaryTags to tags
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Menu Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'), // Changed from Base Price to Price
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: sortOrderController,
                      decoration: const InputDecoration(labelText: 'Sort Order'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: estimatedTimeController,
                      decoration: const InputDecoration(labelText: 'Estimated Time (e.g., 25-35)'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tags'),
                    Wrap(
                      spacing: 8,
                      children: tags.keys.map((tag) {
                        return FilterChip(
                          label: Text(tag),
                          selected: tags[tag] ?? false,
                          onSelected: (selected) {
                            setState(() {
                              tags[tag] = selected;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    item.reference.update({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'price': double.tryParse(priceController.text) ?? 0, // Changed from basePrice to price
                      'sortOrder': int.tryParse(sortOrderController.text) ?? 0,
                      'EstimatedTime': estimatedTimeController.text,
                      'tags': tags,
                      'imageUrl': imageUrlController.text,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  final _imageUrlController = TextEditingController();
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(labelText: 'Sort Order'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('branches').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final branches = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Branch'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select a branch'),
                      ),
                      ...branches.map((branch) {
                        final data = branch.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: data['branchId'],
                          child: Text(data['name'] ?? 'Unnamed Branch'),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBranchId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a branch';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _addCategory();
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addCategory() async {
    await FirebaseFirestore.instance.collection('menu_categories').add({
      'name': _nameController.text,
      'branchId': _selectedBranchId,
      'sortOrder': int.tryParse(_sortOrderController.text) ?? 0,
      'imageUrl': _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      'isActive': true,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}

class AddMenuItemDialog extends StatefulWidget {
  const AddMenuItemDialog({super.key});

  @override
  State<AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  final _estimatedTimeController = TextEditingController(text: '25-35');
  final _imageUrlController = TextEditingController();
  final Map<String, bool> _tags = {
    'isHealthy': false,
    'isSpicy': false,
  };
  final List<Map<String, dynamic>> _variants = [];
  String? _selectedCategoryId;
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Menu Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(labelText: 'Sort Order'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _estimatedTimeController,
                decoration: const InputDecoration(labelText: 'Estimated Time (e.g., 25-35)'),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('menu_categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select a category'),
                      ),
                      ...categories.map((category) {
                        final data = category.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: data['categoryId'],
                          child: Text(data['name'] ?? 'Unnamed Category'),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('branches').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final branches = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Branch'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select a branch'),
                      ),
                      ...branches.map((branch) {
                        final data = branch.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: data['branchId'],
                          child: Text(data['name'] ?? 'Unnamed Branch'),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBranchId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a branch';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Tags'),
              Wrap(
                spacing: 8,
                children: _tags.keys.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: _tags[tag] ?? false,
                    onSelected: (selected) {
                      setState(() {
                        _tags[tag] = selected;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Variants'),
              ..._variants.map((variant) => ListTile(
                title: Text('${variant['name']} (+\$${variant['variantprice']})'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _variants.remove(variant);
                    });
                  },
                ),
              )),
              ElevatedButton(
                onPressed: _showAddVariantDialog,
                child: const Text('Add Variant'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              SwitchListTile(
                title: const Text('Available'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Popular'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _addMenuItem();
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _showAddVariantDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Variant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Variant Name'),
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    _variants.add({
                      'name': nameController.text,
                      'variantprice': double.tryParse(priceController.text) ?? 0,
                      'isAvailable': true,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addMenuItem() async {
    final variantsMap = {};
    for (var variant in _variants) {
      variantsMap[variant['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'variant'] = {
        'name': variant['name'],
        'variantprice': variant['variantprice'],
        'isAvailable': variant['isAvailable'],
      };
    }

    await FirebaseFirestore.instance.collection('menu_items').add({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'categoryId': _selectedCategoryId,
      'branchId': _selectedBranchId,
      'sortOrder': int.tryParse(_sortOrderController.text) ?? 0,
      'EstimatedTime': _estimatedTimeController.text,
      'tags': _tags,
      'imageUrl': _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      'variants': _variants.isNotEmpty ? variantsMap : null,
      'isAvailable': true,
      'isPopular': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sortOrderController.dispose();
    _estimatedTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}



class RidersScreen extends StatefulWidget {
  const RidersScreen({super.key});

  @override
  State<RidersScreen> createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  String _filterStatus = 'all'; // 'all', 'online', 'offline', 'available', 'busy'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDriverDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _buildDriversList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            _buildFilterChip('Online', 'online'),
            _buildFilterChip('Offline', 'offline'),
            _buildFilterChip('Available', 'available'),
            _buildFilterChip('Busy', 'busy'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _filterStatus == value,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? value : 'all';
          });
        },
      ),
    );
  }

  Widget _buildDriversList() {
    Query query = FirebaseFirestore.instance.collection('Drivers');

    // Apply filters based on selection
    if (_filterStatus == 'online') {
      query = query.where('status', isEqualTo: 'online');
    } else if (_filterStatus == 'offline') {
      query = query.where('status', isEqualTo: 'offline');
    } else if (_filterStatus == 'available') {
      query = query.where('isAvailable', isEqualTo: true);
    } else if (_filterStatus == 'busy') {
      query = query.where('isAvailable', isEqualTo: false);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No drivers found'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var driver = snapshot.data!.docs[index];
            return _DriverCard(driver: driver);
          },
        );
      },
    );
  }

  void _showAddDriverDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    String _vehicleType = 'Car';
    final _vehicleNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Driver'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter driver name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _vehicleType,
                    decoration: const InputDecoration(labelText: 'Vehicle Type'),
                    items: ['Car', 'Bike', 'Scooter', 'Bicycle']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) {
                      _vehicleType = value!;
                    },
                  ),
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: const InputDecoration(labelText: 'Vehicle Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _addDriver(
                    _nameController.text,
                    _emailController.text,
                    int.tryParse(_phoneController.text) ?? 0,
                    _vehicleType,
                    _vehicleNumberController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Driver'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDriver(
      String name,
      String email,
      int phone,
      String vehicleType,
      String vehicleNumber,
      ) async {
    await FirebaseFirestore.instance.collection('Drivers').doc(email).set({
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': 'https://static.wikia.nocookie.net/reddeadredemption/images/7/73/John_Marston_TBTN_5_Cropped.png/revision/latest?cb=20250316011637',
      'isAvailable': true,
      'status': 'offline',
      'rating': '4.5',
      'totalDeliveries': 0,
      'currentLocation': GeoPoint(0, 0), // Default location
      'vehicle': {
        'type': vehicleType,
        'number': vehicleNumber,
      },
    });
  }
}

class _DriverCard extends StatelessWidget {
  final QueryDocumentSnapshot driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final data = driver.data() as Map<String, dynamic>;
    final isAvailable = data['isAvailable'] ?? false;
    final status = data['status'] ?? 'offline';
    final rating = data['rating'] ?? '0';
    final totalDeliveries = data['totalDeliveries'] ?? 0;
    final vehicle = data['vehicle'] as Map<String, dynamic>? ?? {};
    final vehicleType = vehicle['type'] ?? 'No vehicle';
    final vehicleNumber = vehicle['number'] ?? '';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(data['profileImageUrl'] ?? ''),
        ),
        title: Text(data['name'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['email'] ?? ''),
            Text('${vehicleType} • ${vehicleNumber}'),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' $rating • $totalDeliveries deliveries'),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: status == 'online' ? Colors.green : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editDriver(context, driver),
            ),
          ],
        ),
        onTap: () => _showDriverDetails(context, driver),
      ),
    );
  }

  void _editDriver(BuildContext context, QueryDocumentSnapshot driver) {
    final data = driver.data() as Map<String, dynamic>;
    final vehicle = data['vehicle'] as Map<String, dynamic>? ?? {};
    final _nameController = TextEditingController(text: data['name']);
    final _phoneController = TextEditingController(text: data['phone'].toString());
    final _vehicleTypeController = TextEditingController(text: vehicle['type']);
    final _vehicleNumberController = TextEditingController(text: vehicle['number']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Driver'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _vehicleTypeController,
                  decoration: const InputDecoration(labelText: 'Vehicle Type'),
                ),
                TextFormField(
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(labelText: 'Vehicle Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await driver.reference.update({
                  'name': _nameController.text,
                  'phone': int.tryParse(_phoneController.text) ?? 0,
                  'vehicle': {
                    'type': _vehicleTypeController.text,
                    'number': _vehicleNumberController.text,
                  },
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDriverDetails(BuildContext context, QueryDocumentSnapshot driver) {
    final data = driver.data() as Map<String, dynamic>;
    final isAvailable = data['isAvailable'] ?? false;
    final status = data['status'] ?? 'offline';
    final rating = data['rating'] ?? '0';
    final totalDeliveries = data['totalDeliveries'] ?? 0;
    final vehicle = data['vehicle'] as Map<String, dynamic>? ?? {};
    final currentLocation = data['currentLocation'] as GeoPoint?;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(data['profileImageUrl'] ?? ''),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.email, data['email']),
                _buildDetailRow(Icons.phone, data['phone'].toString()),
                _buildDetailRow(Icons.directions_car,
                    '${vehicle['type']} (${vehicle['number']})'),
                _buildDetailRow(Icons.star, 'Rating: $rating'),
                _buildDetailRow(
                    Icons.delivery_dining, 'Total Deliveries: $totalDeliveries'),
                _buildDetailRow(Icons.location_on,
                    'Location: ${currentLocation?.latitude ?? 0}° N, ${currentLocation?.longitude ?? 0}° E'),
                _buildDetailRow(Icons.circle,
                    'Status: ${status == 'online' ? 'Online' : 'Offline'}',
                    color: status == 'online' ? Colors.green : Colors.grey),
                _buildDetailRow(
                    Icons.work,
                    'Availability: ${isAvailable ? 'Available' : 'Busy'}',
                    color: isAvailable ? Colors.green : Colors.orange),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text,
      {Color color = Colors.black, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

