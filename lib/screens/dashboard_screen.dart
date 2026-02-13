import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'order_screen.dart';
import 'statistic_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SupabaseClient get _supabase => Supabase.instance.client;

  int _selectedIndex = 0;
  bool _isSidebarExtended = false;
  final List<Map<String, dynamic>> _cartItems = [];
  // _completedOrders removed as we now use Supabase for persistent stats
  int _currentOrderNumber = 1; // Order number counter

  @override
  void initState() {
    super.initState();
    _fetchLastOrderNumber();
  }

  Future<void> _fetchLastOrderNumber() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('order_number')
          .order('order_number', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        if (mounted) {
          setState(() {
            _currentOrderNumber = (response['order_number'] as int) + 1;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching last order number: $e');
    }
  }

  Future<void> _finalizeAndNextOrder() async {
    // 1. Identify items for this specific order number
    final currentOrderItems = _cartItems
        .where((item) => item['orderNumber'] == _currentOrderNumber)
        .toList();

    if (currentOrderItems.isNotEmpty) {
      try {
        // Calculate Total
        double totalAmount = currentOrderItems.fold(0.0, (sum, item) {
          final price = double.tryParse(item['price'].toString()) ?? 0.0;
          final qty = (item['quantity'] is int)
              ? (item['quantity'] as int)
              : (int.tryParse(item['quantity'].toString()) ?? 1);
          return sum + (price * qty);
        });

        // 2. Insert Order Header
        final orderResponse = await _supabase
            .from('orders')
            .insert({
              'order_number': _currentOrderNumber,
              'total_amount': totalAmount,
              'status': 'pending',
            })
            .select()
            .single();

        final orderId = orderResponse['id'];

        // 3. Insert Order Items
        final List<Map<String, dynamic>> itemsPayload = currentOrderItems.map((
          item,
        ) {
          return {
            'order_id': orderId,
            'name': item['name'],
            'price': item['price'],
            'quantity': (item['quantity'] is int)
                ? (item['quantity'] as int)
                : (int.tryParse(item['quantity'].toString()) ?? 1),
            'variant': item['variant'], // Ensure these keys exist in item map
            'cheese': item['cheese'] ?? false,
            'remarks': item['remarks'],
          };
        }).toList();

        await _supabase.from('order_items').insert(itemsPayload);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ralat menyimpan pesanan: $e')),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _currentOrderNumber++;
      });
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final itemWithOrder = Map<String, dynamic>.from(item);
      itemWithOrder['orderNumber'] = _currentOrderNumber; // Attach Order ID
      _cartItems.add(itemWithOrder);
    });

    // Snackbar handled in MenuScreen
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _updateCartItem(int index, Map<String, dynamic> updatedItem) {
    setState(() {
      _cartItems[index] = updatedItem;
    });
  }

  void _completeOrder(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan selesai!'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Keluar'),
        content: const Text('Adakah anda pasti mahu log keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Log Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isExtended,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: isSelected
            ? BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : BoxDecoration(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: isExtended
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? Colors.black : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.black : Colors.grey[600],
                        size: 24,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final displayName = user?.userMetadata?['display_name'] ?? 'User';
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // ── 1. Main Content ──
          // We add a left margin to reserve space for the collapsed sidebar
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // Index 0: Home
                Center(
                  child: Text(
                    'Home Content',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                ),
                // Index 1: Menu
                // Index 1: Menu
                MenuScreen(
                  onAddToCart: _addToCart,
                  currentOrderNumber: _currentOrderNumber,
                  onNextOrder: _finalizeAndNextOrder,
                ),
                // Index 2: Order
                OrderScreen(
                  cartItems: _cartItems,
                  onRemoveItem: _removeFromCart,
                  onCompleteOrder: _completeOrder,
                  onUpdateItem: _updateCartItem,
                  onClearCart: _clearCart,
                ),
                // Index 3: Statistic
                StatisticScreen(),
                // Index 4: Settings
                Center(
                  child: Text(
                    'Settings Content',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Barrier / Scrim (Click to closing) ──
          if (_isSidebarExtended)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSidebarExtended = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.2), // Dimmed background
                ),
              ),
            ),

          // ── 3. Sidebar ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _isSidebarExtended ? 260 : 72,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                if (_isSidebarExtended)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(4, 0),
                  ),
              ],
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Toggle Button
                Align(
                  alignment: _isSidebarExtended
                      ? Alignment.centerRight
                      : Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isSidebarExtended ? 8.0 : 0,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isSidebarExtended ? Icons.menu_open : Icons.menu,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSidebarExtended = !_isSidebarExtended;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Menu Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSidebarItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          index: 0,
                          isExtended: _isSidebarExtended,
                        ),
                        _buildSidebarItem(
                          icon: Icons.restaurant_menu,
                          label: 'Menu',
                          index: 1,
                          isExtended: _isSidebarExtended,
                        ),
                        _buildSidebarItem(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Order',
                          index: 2,
                          isExtended: _isSidebarExtended,
                        ),
                        _buildSidebarItem(
                          icon: Icons.bar_chart_outlined,
                          label: 'Statistic',
                          index: 3,
                          isExtended: _isSidebarExtended,
                        ),
                        _buildSidebarItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          index: 4,
                          isExtended: _isSidebarExtended,
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_isSidebarExtended) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.primaryYellow,
                                child: Text(
                                  initial,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(
                              Icons.logout,
                              size: 18,
                              color: AppTheme.secondaryRed,
                            ),
                            label: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                color: AppTheme.secondaryRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.secondaryRed,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Collapsed Profile
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryYellow,
                          child: Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(
                            Icons.logout,
                            color: AppTheme.secondaryRed,
                          ),
                          tooltip: 'Logout',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
