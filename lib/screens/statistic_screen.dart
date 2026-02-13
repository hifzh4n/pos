import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String _filter = 'Hari Ini';
  bool _isLoading = true;

  double _totalSales = 0.0;
  int _totalOrders = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime startDate;

      if (_filter == 'Hari Ini') {
        startDate = DateTime(now.year, now.month, now.day);
      } else if (_filter == 'Minggu Ini') {
        startDate = now.subtract(const Duration(days: 7));
      } else {
        startDate = DateTime(now.year, now.month, 1);
      }

      final ordersResponse = await _supabase
          .from('orders')
          .select('id, total_amount')
          .gte('created_at', startDate.toIso8601String());

      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      final totalSales = orders.fold(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item['total_amount'].toString()) ?? 0.0),
      );
      final totalOrders = orders.length;

      if (mounted) {
        setState(() {
          _totalSales = totalSales;
          _totalOrders = totalOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ralat mendapatkan statistik: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return RefreshIndicator(
                  onRefresh: _fetchStats,
                  color: AppTheme.primaryYellow,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Filter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Statistik',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Ringkasan untuk $_filter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            // Filter Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _filter,
                                  items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini']
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _filter = val);
                                      _fetchStats();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Summary Cards
                        if (isSmallScreen) ...[
                          _buildSummaryCard(
                            title: 'Jumlah Jualan',
                            value: 'RM${_totalSales.toStringAsFixed(2)}',
                            icon: Icons.attach_money,
                            color: Colors.green,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryCard(
                            title: 'Pesanan',
                            value: _totalOrders.toString(),
                            icon: Icons.receipt_long,
                            color: Colors.orange,
                            width: double.infinity,
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Jumlah Jualan',
                                  value: 'RM${_totalSales.toStringAsFixed(2)}',
                                  icon: Icons.attach_money,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Pesanan',
                                  value: _totalOrders.toString(),
                                  icon: Icons.receipt_long,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Additional Info
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maklumat Tempoh',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Penapis:',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _filter,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Purata setiap pesanan:',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _totalOrders > 0
                                        ? 'RM${(_totalSales / _totalOrders).toStringAsFixed(2)}'
                                        : 'RM0.00',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
