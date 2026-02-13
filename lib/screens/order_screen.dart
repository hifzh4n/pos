import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OrderScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int) onRemoveItem;
  final Function(int) onCompleteOrder;
  final Function(int, Map<String, dynamic>) onUpdateItem;
  final VoidCallback onClearCart;

  const OrderScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onCompleteOrder,
    required this.onUpdateItem,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Order',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verify items before checkout',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items in order yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          // Responsive column count
                          final int columns = width > 1200
                              ? 4
                              : width > 800
                              ? 3
                              : width > 600
                              ? 2
                              : 1;
                          final double spacing = 16;
                          final double itemWidth =
                              (width - (columns - 1) * spacing) / columns;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: cartItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return SizedBox(
                                width: itemWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                    onTap: () =>
                                        _showEditDialog(context, index, item),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 0. Order Number Badge
                                        if (item['orderNumber'] != null)
                                          Builder(
                                            builder: (context) {
                                              final int orderNum =
                                                  item['orderNumber'] as int;
                                              final List<Color> colors = [
                                                const Color(
                                                  0xFFE3F2FD,
                                                ), // Blue 100
                                                const Color(
                                                  0xFFFFF3E0,
                                                ), // Orange 100
                                                const Color(
                                                  0xFFF3E5F5,
                                                ), // Purple 100
                                                const Color(
                                                  0xFFE0F2F1,
                                                ), // Teal 100
                                                const Color(
                                                  0xFFFCE4EC,
                                                ), // Pink 100
                                              ];
                                              final Color bg =
                                                  colors[orderNum %
                                                      colors.length];

                                              return Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: bg,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.receipt_long,
                                                      size: 16,
                                                      color: Colors.black87,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Order #$orderNum',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),

                                        // 1. Header: Name & Price
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            16,
                                            16,
                                            8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['name'],
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'RM${(item['totalPrice'] as double).toStringAsFixed(2)}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: AppTheme.primaryYellow,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 2. Details
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Variant & Cheese
                                              Wrap(
                                                spacing: 8,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['varian'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                    ),
                                                  ),
                                                  if (item['cheese'])
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.amber
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '+ Cheese',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .orange[800],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Quantity & Remarks
                                              Row(
                                                children: [
                                                  Text(
                                                    'Qty: ${item['quantity']}',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (item['remark'] != null &&
                                                      item['remark']
                                                          .toString()
                                                          .isNotEmpty) ...[
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'note: "${item['remark']}"',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color: Colors
                                                                  .grey[500],
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 16),
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.1),
                                        ),

                                        // 3. Action Buttons (Full Width)
                                        Row(
                                          children: [
                                            // Cancel Button
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${item['name']} Cancelled',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      duration: const Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                  onRemoveItem(index);
                                                },
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(16),
                                                    ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  alignment: Alignment.center,
                                                  decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.close,
                                                        color: Colors.red[400],
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Cancel',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: Colors
                                                                  .red[400],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Divider
                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: Colors.grey.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                            // Done Button
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  onCompleteOrder(index);
                                                },
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(16),
                                                    ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.05),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Done',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    int index,
    Map<String, dynamic> item,
  ) {
    int quantity = 1; // Default
    // If quantity is in item, use it. currently item structure might not have quantity fully utilized in UI card
    // but DB has it. Let's assume quantity is 1 if missing.
    if (item.containsKey('quantity')) {
      quantity = item['quantity'] is int
          ? item['quantity']
          : int.tryParse(item['quantity'].toString()) ?? 1;
    }

    final TextEditingController remarksController = TextEditingController(
      text: item['remarks'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Edit ${item['name']}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity
                Row(
                  children: [
                    Text('Quantity:', style: GoogleFonts.poppins()),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (quantity > 1) {
                          setDialogState(() => quantity--);
                        }
                      },
                    ),
                    Text(
                      '$quantity',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setDialogState(() => quantity++);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Remarks
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(
                    labelText: 'Remarks / Variant',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  final updatedItem = Map<String, dynamic>.from(item);
                  updatedItem['quantity'] = quantity;
                  updatedItem['remarks'] = remarksController.text;
                  // If remarks contains variant info, update variant? For simplicity just verify logic.

                  onUpdateItem(index, updatedItem);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
