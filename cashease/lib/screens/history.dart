<<<<<<< HEAD
// lib/screens/history.dart (Asumsi file ini ada di lib/screens/)

import 'package:flutter/material.dart';
import '../services/database_helper.dart'; // FIX PATH: Menggunakan jalur services/

class History extends StatefulWidget {
  final String phoneNumber; // Tambahkan properti phoneNumber

  const History({super.key, required this.phoneNumber});
=======
import 'package:flutter/material.dart';
// No need to import intl package as we'll create our own formatting methods

class History extends StatefulWidget {
  const History({super.key});
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // Filter-filter untuk status transaksi
  String? selectedStatus;
  String? selectedCategory;
  DateTime? selectedDate;
  bool showFilterPanel = false;

  // Text editing controller for search functionality
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

<<<<<<< HEAD
  // Data transaksi (sekarang kosong, akan diisi dari database)
  List<Map<String, dynamic>> allTransactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Inisialisasi DB Helper
  bool _isLoading = true;
=======
  // Data dummy untuk transaksi yang lebih banyak dan beragam
  final List<Map<String, dynamic>> allTransactions = [
    {
      'type': 'topup',
      'status': 'success',
      'description': 'Top Up Successful',
      'detail': 'Successfully Added Rp. 100.000',
      'color': Colors.green,
      'icon': Icons.arrow_upward,
      'date': DateTime(2025, 4, 28),
      'amount': 100000,
    },
    {
      'type': 'payment',
      'status': 'success',
      'description': 'Payment to Merchant',
      'detail': 'Paid Rp. 75.000 to Online Store',
      'color': Colors.blue,
      'icon': Icons.shopping_cart,
      'date': DateTime(2025, 4, 27),
      'amount': -75000,
    },
    {
      'type': 'topup',
      'status': 'failed',
      'description': 'Top Up Failed',
      'detail': 'Failed to Add Rp. 200.000',
      'color': Colors.red,
      'icon': Icons.error,
      'date': DateTime(2025, 4, 26),
      'amount': 0,
    },
    {
      'type': 'send_money',
      'status': 'success',
      'description': 'Send Money to Friend',
      'detail': 'Sent Rp. 150.000 to John Doe',
      'color': Colors.orange,
      'icon': Icons.send,
      'date': DateTime(2025, 4, 25),
      'amount': -150000,
    },
    {
      'type': 'cashback',
      'status': 'success',
      'description': 'Cashback Received',
      'detail': 'Received Rp. 25.000 Cashback',
      'color': Colors.green,
      'icon': Icons.monetization_on,
      'date': DateTime(2025, 4, 24),
      'amount': 25000,
    },
    {
      'type': 'refund',
      'status': 'in_progress',
      'description': 'Refund Processing',
      'detail': 'Refund of Rp. 90.000 in Progress',
      'color': Colors.amber,
      'icon': Icons.replay,
      'date': DateTime(2025, 4, 23),
      'amount': 0,
    },
    {
      'type': 'payment',
      'status': 'cancelled',
      'description': 'Payment Cancelled',
      'detail': 'Cancelled Payment of Rp. 120.000',
      'color': Colors.grey,
      'icon': Icons.cancel,
      'date': DateTime(2025, 4, 22),
      'amount': 0,
    },
    {
      'type': 'topup',
      'status': 'success',
      'description': 'Top Up Successful',
      'detail': 'Successfully Added Rp. 500.000',
      'color': Colors.green,
      'icon': Icons.arrow_upward,
      'date': DateTime(2025, 4, 21),
      'amount': 500000,
    },
    {
      'type': 'payment',
      'status': 'success',
      'description': 'Payment for Utilities',
      'detail': 'Paid Rp. 250.000 for Electricity',
      'color': Colors.blue,
      'icon': Icons.lightbulb,
      'date': DateTime(2025, 4, 20),
      'amount': -250000,
    },
    {
      'type': 'cashback',
      'status': 'success',
      'description': 'Promo Cashback',
      'detail': 'Received Rp. 50.000 Promo Cashback',
      'color': Colors.green,
      'icon': Icons.card_giftcard,
      'date': DateTime(2025, 4, 19),
      'amount': 50000,
    },
  ];
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

  // Filtered transactions based on selected criteria
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadTransactions(); // Memuat data dari database
=======
    // Initialize filtered transactions with all transactions
    filteredTransactions = List.from(allTransactions);

    // Add listener to search controller
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // Fungsi untuk memuat data dari database
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final dbTransactions = await _dbHelper.getUserTransactions(
        widget.phoneNumber,
      );

      // Mapping data dari DB ke format yang dibutuhkan UI
      allTransactions =
          dbTransactions
              .map((dbT) => _mapTransactionToUI(dbT))
              .whereType<Map<String, dynamic>>()
              .toList();

      filteredTransactions = List.from(allTransactions);
    } catch (e) {
      print('Error loading transactions: $e');
      allTransactions = [];
      filteredTransactions = [];
    }
    setState(() => _isLoading = false);
  }

  // Fungsi untuk memetakan data dari format database ke format UI
  Map<String, dynamic>? _mapTransactionToUI(Map<String, dynamic> dbT) {
    String type = dbT['type'] as String;
    String status = dbT['status'] as String;
    int amount = dbT['amount'] as int;
    String description = dbT['description'] as String? ?? 'No Description';
    DateTime date =
        DateTime.tryParse(dbT['created_at'] as String? ?? '') ?? DateTime.now();
    Color color;
    IconData icon;
    String detail = '';

    // Tentukan warna dan ikon berdasarkan tipe dan status
    switch (type) {
      case 'topup':
        color = status == 'success' ? Colors.green : Colors.red;
        icon = Icons.arrow_upward;
        description = 'Top Up';
        detail =
            status == 'success'
                ? 'Successfully Added Rp. ${_formatNumber(amount)}'
                : 'Top Up Failed: Rp. ${_formatNumber(amount)}';
        break;
      case 'transfer':
      case 'send_money': // Digabungkan
        color = status == 'success' ? Colors.orange : Colors.red;
        icon = Icons.send;
        description = 'Send Money/Transfer';
        detail =
            status == 'success'
                ? 'Sent Rp. ${_formatNumber(amount)} to ${dbT['recipient_name'] ?? 'Recipient'}'
                : 'Transfer Failed: Rp. ${_formatNumber(amount)}';
        amount = -amount; // Pengurangan saldo
        break;
      case 'payment':
        color = status == 'success' ? Colors.blue : Colors.red;
        icon = Icons.shopping_cart;
        description = 'Payment';
        detail =
            status == 'success'
                ? 'Paid Rp. ${_formatNumber(amount)} for $description'
                : 'Payment Failed: Rp. ${_formatNumber(amount)}';
        amount = -amount; // Pengurangan saldo
        break;
      case 'request': // Permintaan Uang yang Diterima (sebagai penerima)
        color = Colors.green;
        icon = Icons.call_received;
        description = 'Request Money Received';
        detail =
            'Received Rp. ${_formatNumber(amount)} from ${dbT['recipient_name'] ?? 'Payer'}';
        break;
      case 'failed': // Transaksi Gagal (saldo tidak cukup, dll.)
        color = Colors.red;
        icon = Icons.error;
        description = 'Transaction Failed';
        detail =
            dbT['description'] as String? ?? 'Insufficient balance or error.';
        amount = 0;
        break;
      case 'saving_goal': // Menambahkan Tabungan/Pocket
        color = Colors.purple;
        icon = Icons.savings;
        description = 'New Saving Goal Added';
        detail = 'Goal: ${dbT['recipient_name'] ?? 'New Goal'}';
        amount = 0; // Tidak mempengaruhi saldo utama secara langsung
        break;
      case 'withdraw':
        color = status == 'success' ? Colors.orange : Colors.red;
        icon = Icons.atm;
        description = 'Withdrawal';
        detail =
            status == 'success'
                ? 'Successful Withdrawal of Rp. ${_formatNumber(amount)}'
                : 'Withdrawal Failed: Rp. ${_formatNumber(amount)}';
        amount = -amount;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
        description = 'Other Transaction';
        detail = description;
        amount = amount;
    }

    return {
      'type': type,
      'status': status,
      'description': description,
      'detail': detail,
      'color': color,
      'icon': icon,
      'date': date,
      'amount': amount,
    };
  }

=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
  // Search functionality
  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  // Apply filters based on selected criteria
  void _applyFilters() {
    setState(() {
<<<<<<< HEAD
      // Logic filter status sudah benar. Jika selectedStatus == null (ketika 'All' dipilih),
      // maka kondisi matchesStatus akan selalu true.
=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
      filteredTransactions =
          allTransactions.where((transaction) {
            // Search filter
            bool matchesSearch =
                searchQuery.isEmpty ||
                transaction['description'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                transaction['detail'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );

<<<<<<< HEAD
            // Status filter: pastikan status di UI chip cocok dengan status di DB ('success', 'failed', dll.)
=======
            // Status filter
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
            bool matchesStatus =
                selectedStatus == null ||
                transaction['status'] == selectedStatus;

<<<<<<< HEAD
            // Category filter (menggunakan kolom 'type' dari mapping)
=======
            // Category filter
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
            bool matchesCategory =
                selectedCategory == null ||
                transaction['type'] == selectedCategory;

            // Date filter
            bool matchesDate =
                selectedDate == null ||
                (transaction['date'].year == selectedDate!.year &&
                    transaction['date'].month == selectedDate!.month &&
                    transaction['date'].day == selectedDate!.day);

            return matchesSearch &&
                matchesStatus &&
                matchesCategory &&
                matchesDate;
          }).toList();
    });
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      selectedStatus = null;
      selectedCategory = null;
      selectedDate = null;
      _searchController.clear();
      searchQuery = '';
      filteredTransactions = List.from(allTransactions);
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }
=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        title: const Text(
          'Activity',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFilterPanel = !showFilterPanel;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.filter_list),
                  ),
                ),
              ],
            ),
          ),

          // Filter panel - shows when filter icon is clicked
          if (showFilterPanel)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusFilter(),
                  const SizedBox(height: 16),

                  const Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2026),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
<<<<<<< HEAD
                          _applyFilters();
=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null
                                ? 'Choose your date'
                                : _formatDate(selectedDate!, 'dd/MM/yyyy'),
                            style: TextStyle(
                              color:
                                  selectedDate == null
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
<<<<<<< HEAD
                            color: Colors.deepPurple,
=======
                            color: Colors.blue[700],
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Kategori',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _resetFilters();
<<<<<<< HEAD
                            setState(() {
                              showFilterPanel = false;
                            });
=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('RESET'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            setState(() {
                              showFilterPanel =
                                  false; // Hide filter panel after applying
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('APPLY'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Transaction list
          Expanded(
            child:
                filteredTransactions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
<<<<<<< HEAD
                            allTransactions.isEmpty
                                ? 'No transactions found in database'
                                : 'No transactions found matching filters',
=======
                            'No transactions found',
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 1),
                          color: Colors.white,
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: transaction['color'],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                transaction['icon'],
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              transaction['description'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction['detail'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(
                                    transaction['date'],
                                    'dd MMM yyyy',
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing:
                                transaction['amount'] != 0
                                    ? Text(
                                      _formatCurrency(transaction['amount']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
<<<<<<< HEAD
                                            (transaction['amount'] as int) > 0
=======
                                            transaction['amount'] > 0
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    )
                                    : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
<<<<<<< HEAD
        _buildFilterChip('All', null, isStatus: true),
        _buildFilterChip('Success', 'success', isStatus: true),
        _buildFilterChip('Cancelled', 'cancelled', isStatus: true),
        _buildFilterChip('In Progress', 'in_progress', isStatus: true),
        _buildFilterChip('Failed', 'failed', isStatus: true),
        _buildFilterChip('Approved', 'approved', isStatus: true),
=======
        _buildFilterChip('All', null),
        _buildFilterChip('Success', 'success'),
        _buildFilterChip('Cancelled', 'cancelled'),
        _buildFilterChip('In Progress', 'in_progress'),
        _buildFilterChip('Failed', 'failed'),
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
<<<<<<< HEAD
        _buildCategoryChip('All', null, isStatus: false),
        _buildCategoryChip('Payment', 'payment', isStatus: false),
        _buildCategoryChip('Withdraw', 'withdraw', isStatus: false),
        _buildCategoryChip('Top up', 'topup', isStatus: false),
        _buildCategoryChip('Request', 'request', isStatus: false),
        _buildCategoryChip('Transfer', 'transfer', isStatus: false),
        _buildCategoryChip('Saving Goal', 'saving_goal', isStatus: false),
        _buildCategoryChip('Failed Trans', 'failed', isStatus: false),
=======
        _buildCategoryChip('All', null),
        _buildCategoryChip('Payment', 'payment'),
        _buildCategoryChip('Refund', 'refund'),
        _buildCategoryChip('Top up', 'topup'),
        _buildCategoryChip('Cashback', 'cashback'),
        _buildCategoryChip('Send Money', 'send_money'),
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildFilterChip(
    String label,
    String? value, {
    required bool isStatus,
  }) {
    final isSelected =
        isStatus ? selectedStatus == value : selectedCategory == value;
=======
  Widget _buildFilterChip(String label, String? value) {
    final isSelected = selectedStatus == value;
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1

    return InkWell(
      onTap: () {
        setState(() {
<<<<<<< HEAD
          if (isStatus) {
            // FIX LOGIC: When 'All' is clicked, value is null, which is correct.
            selectedStatus = value;
          } else {
            selectedCategory = value;
          }
          _applyFilters();
=======
          selectedStatus = value;
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
          color:
              isSelected
                  ? Colors.deepPurple.withOpacity(0.1)
                  : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildCategoryChip(
    String label,
    String? value, {
    required bool isStatus,
  }) {
    return _buildFilterChip(label, value, isStatus: isStatus);
  }

=======
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
  // Custom date formatting function
  String _formatDate(DateTime date, String format) {
    if (format == 'dd/MM/yyyy') {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } else if (format == 'dd MMM yyyy') {
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    }
    return date.toString();
  }

  // Custom currency formatting function
  String _formatCurrency(int amount) {
    String prefix = 'Rp ';
    String amountStr = amount.abs().toString();

    // Add thousand separators
    String result = '';
    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        result += '.';
      }
      result += amountStr[i];
    }

    return '$prefix$result';
  }

<<<<<<< HEAD
  // Custom function to format number without prefix (used internally)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
=======
  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = selectedCategory == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
          color:
              isSelected
                  ? Colors.deepPurple.withOpacity(0.1)
                  : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
>>>>>>> 539719d8a23c2642640c9ed5b5cd4648d69ed0c1
    );
  }
}
