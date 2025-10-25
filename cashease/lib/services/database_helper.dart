// database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cashease.db');
    print('📍 Database path: $path');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('🔨 Creating database tables...');

    // Table users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT UNIQUE NOT NULL,
        pin TEXT NOT NULL,
        balance INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Table transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_phone TEXT NOT NULL,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        description TEXT,
        recipient_phone TEXT,
        recipient_name TEXT,
        status TEXT DEFAULT 'success',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_phone) REFERENCES users (phone)
      )
    ''');

    // Table beneficiaries
    await db.execute('''
      CREATE TABLE beneficiaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_phone TEXT NOT NULL,
        beneficiary_name TEXT NOT NULL,
        beneficiary_phone TEXT NOT NULL,
        beneficiary_bank TEXT,
        beneficiary_account TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_phone) REFERENCES users (phone)
      )
    ''');

    // Table pockets
    await db.execute('''
      CREATE TABLE pockets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_phone TEXT NOT NULL,
        name TEXT NOT NULL,
        balance INTEGER DEFAULT 0,
        target_amount INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_phone) REFERENCES users (phone)
      )
    ''');

    print('✅ All tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      print('🔄 Upgrading database from version $oldVersion to $newVersion');

      // Add balance column if not exists
      await db.execute(
        'ALTER TABLE users ADD COLUMN balance INTEGER DEFAULT 0',
      );

      // Create new tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_phone TEXT NOT NULL,
          type TEXT NOT NULL,
          amount INTEGER NOT NULL,
          description TEXT,
          recipient_phone TEXT,
          recipient_name TEXT,
          status TEXT DEFAULT 'success',
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_phone) REFERENCES users (phone)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS beneficiaries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_phone TEXT NOT NULL,
          beneficiary_name TEXT NOT NULL,
          beneficiary_phone TEXT NOT NULL,
          beneficiary_bank TEXT,
          beneficiary_account TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_phone) REFERENCES users (phone)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS pockets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_phone TEXT NOT NULL,
          name TEXT NOT NULL,
          balance INTEGER DEFAULT 0,
          target_amount INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_phone) REFERENCES users (phone)
        )
      ''');
    }
  }

  // Hash PIN untuk keamanan
  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==================== USER METHODS ====================

  // Registrasi user baru
  Future<bool> registerUser(String phone, String pin) async {
    try {
      print('📝 Attempting to register user...');
      print('   Phone: $phone');
      print('   PIN length: ${pin.length}');

      final db = await database;

      final existingUser = await getUserByPhone(phone);
      if (existingUser != null) {
        print('❌ User already exists!');
        return false;
      }

      print('✅ Phone number available, creating user...');

      final hashedPin = _hashPin(pin);
      print('   Hashed PIN: ${hashedPin.substring(0, 10)}...');

      final result = await db.insert('users', {
        'phone': phone,
        'pin': hashedPin,
        'balance': 0,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      print('✅ User registered successfully with ID: $result');

      final savedUser = await getUserByPhone(phone);
      print('🔍 Verification - User saved: ${savedUser != null}');

      return true;
    } catch (e) {
      print('❌ Error registering user: $e');
      print('   Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Cek user berdasarkan nomor telepon
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );

      if (results.isNotEmpty) {
        print('👤 User found: $phone');
        return results.first;
      }
      print('👻 User not found: $phone');
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // Validasi login
  Future<bool> validateLogin(String phone, String pin) async {
    try {
      print('🔐 Validating login...');
      print('   Phone: $phone');

      final user = await getUserByPhone(phone);
      if (user == null) {
        print('❌ User not found');
        return false;
      }

      final hashedPin = _hashPin(pin);
      final isValid = user['pin'] == hashedPin;

      print(isValid ? '✅ Login successful' : '❌ Wrong PIN');
      return isValid;
    } catch (e) {
      print('❌ Error validating login: $e');
      return false;
    }
  }

  // Verifikasi PIN
  Future<bool> verifyPin(String phone, String pin) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'phone = ? AND pin = ?',
        whereArgs: [phone, _hashPin(pin)],
      );
      return results.isNotEmpty;
    } catch (e) {
      print('❌ Error verifying PIN: $e');
      return false;
    }
  }

  // Update PIN
  Future<bool> updatePin(String phone, String newPin) async {
    try {
      print('🔄 Updating PIN for: $phone');

      final db = await database;
      final user = await getUserByPhone(phone);

      if (user == null) {
        print('❌ User not found');
        return false;
      }

      await db.update(
        'users',
        {'pin': _hashPin(newPin)},
        where: 'phone = ?',
        whereArgs: [phone],
      );

      print('✅ PIN updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating PIN: $e');
      return false;
    }
  }

  // Cek apakah user sudah terdaftar
  Future<bool> isUserRegistered(String phone) async {
    final user = await getUserByPhone(phone);
    return user != null;
  }

  // ==================== BALANCE METHODS ====================

  // Get user balance
  Future<int> getUserBalance(String phone) async {
    try {
      final user = await getUserByPhone(phone);
      if (user != null) {
        return user['balance'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error getting balance: $e');
      return 0;
    }
  }

  // Update user balance
  Future<bool> updateBalance(String phone, int newBalance) async {
    try {
      final db = await database;
      await db.update(
        'users',
        {'balance': newBalance},
        where: 'phone = ?',
        whereArgs: [phone],
      );
      print('✅ Balance updated to: $newBalance');
      return true;
    } catch (e) {
      print('❌ Error updating balance: $e');
      return false;
    }
  }

  // Add to balance (topup)
  Future<bool> addBalance(
    String phone,
    int amount, {
    String description = 'Top Up',
  }) async {
    try {
      final db = await database;
      final currentBalance = await getUserBalance(phone);
      final newBalance = currentBalance + amount;

      await db.update(
        'users',
        {'balance': newBalance},
        where: 'phone = ?',
        whereArgs: [phone],
      );

      // Record transaction
      await addTransaction(
        userPhone: phone,
        type: 'topup',
        amount: amount,
        description: description,
      );

      print('✅ Balance added: $amount. New balance: $newBalance');
      return true;
    } catch (e) {
      print('❌ Error adding balance: $e');
      return false;
    }
  }

  // Subtract from balance (send, withdraw, payment)
  Future<bool> subtractBalance(
    String phone,
    int amount, {
    String description = 'Payment',
  }) async {
    try {
      final db = await database;
      final currentBalance = await getUserBalance(phone);

      if (currentBalance < amount) {
        print('❌ Insufficient balance');
        return false;
      }

      final newBalance = currentBalance - amount;

      await db.update(
        'users',
        {'balance': newBalance},
        where: 'phone = ?',
        whereArgs: [phone],
      );

      print('✅ Balance subtracted: $amount. New balance: $newBalance');
      return true;
    } catch (e) {
      print('❌ Error subtracting balance: $e');
      return false;
    }
  }

  // ==================== TRANSACTION METHODS ====================

  // Add transaction
  Future<int> addTransaction({
    required String userPhone,
    required String type,
    required int amount,
    String? description,
    String? recipientPhone,
    String? recipientName,
    String status = 'success',
  }) async {
    try {
      final db = await database;
      final id = await db.insert('transactions', {
        'user_phone': userPhone,
        'type': type,
        'amount': amount,
        'description': description,
        'recipient_phone': recipientPhone,
        'recipient_name': recipientName,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ Transaction recorded with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error adding transaction: $e');
      return -1;
    }
  }

  // Get all transactions for a user
  Future<List<Map<String, dynamic>>> getUserTransactions(String phone) async {
    try {
      final db = await database;
      final transactions = await db.query(
        'transactions',
        where: 'user_phone = ?',
        whereArgs: [phone],
        orderBy: 'created_at DESC',
      );
      print('📊 Found ${transactions.length} transactions for $phone');
      return transactions;
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
  }

  // Get recent transactions
  Future<List<Map<String, dynamic>>> getRecentTransactions(
    String phone, {
    int limit = 10,
  }) async {
    try {
      final db = await database;
      final transactions = await db.query(
        'transactions',
        where: 'user_phone = ?',
        whereArgs: [phone],
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return transactions;
    } catch (e) {
      print('❌ Error getting recent transactions: $e');
      return [];
    }
  }

  // ==================== BENEFICIARY METHODS ====================

  // Add beneficiary
  Future<int> addBeneficiary({
    required String userPhone,
    required String beneficiaryName,
    required String beneficiaryPhone,
    String? beneficiaryBank,
    String? beneficiaryAccount,
  }) async {
    try {
      final db = await database;
      final id = await db.insert('beneficiaries', {
        'user_phone': userPhone,
        'beneficiary_name': beneficiaryName,
        'beneficiary_phone': beneficiaryPhone,
        'beneficiary_bank': beneficiaryBank,
        'beneficiary_account': beneficiaryAccount,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ Beneficiary added with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error adding beneficiary: $e');
      return -1;
    }
  }

  // Get all beneficiaries for a user
  Future<List<Map<String, dynamic>>> getUserBeneficiaries(String phone) async {
    try {
      final db = await database;
      final beneficiaries = await db.query(
        'beneficiaries',
        where: 'user_phone = ?',
        whereArgs: [phone],
        orderBy: 'created_at DESC',
      );
      print('📊 Found ${beneficiaries.length} beneficiaries for $phone');
      return beneficiaries;
    } catch (e) {
      print('❌ Error getting beneficiaries: $e');
      return [];
    }
  }

  // Delete beneficiary
  Future<bool> deleteBeneficiary(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'beneficiaries',
        where: 'id = ?',
        whereArgs: [id],
      );
      print(result > 0 ? '✅ Beneficiary deleted' : '❌ Beneficiary not found');
      return result > 0;
    } catch (e) {
      print('❌ Error deleting beneficiary: $e');
      return false;
    }
  }

  // ==================== POCKET METHODS ====================

  // Add pocket
  Future<int> addPocket({
    required String userPhone,
    required String name,
    int balance = 0,
    int targetAmount = 0,
  }) async {
    try {
      final db = await database;
      final id = await db.insert('pockets', {
        'user_phone': userPhone,
        'name': name,
        'balance': balance,
        'target_amount': targetAmount,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ Pocket added with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error adding pocket: $e');
      return -1;
    }
  }

  // Get all pockets for a user
  Future<List<Map<String, dynamic>>> getUserPockets(String phone) async {
    try {
      final db = await database;
      final pockets = await db.query(
        'pockets',
        where: 'user_phone = ?',
        whereArgs: [phone],
        orderBy: 'created_at DESC',
      );
      print('📊 Found ${pockets.length} pockets for $phone');
      return pockets;
    } catch (e) {
      print('❌ Error getting pockets: $e');
      return [];
    }
  }

  // Update pocket balance
  Future<bool> updatePocketBalance(int pocketId, int newBalance) async {
    try {
      final db = await database;
      await db.update(
        'pockets',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [pocketId],
      );
      print('✅ Pocket balance updated');
      return true;
    } catch (e) {
      print('❌ Error updating pocket balance: $e');
      return false;
    }
  }

  // Delete pocket
  Future<bool> deletePocket(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'pockets',
        where: 'id = ?',
        whereArgs: [id],
      );
      print(result > 0 ? '✅ Pocket deleted' : '❌ Pocket not found');
      return result > 0;
    } catch (e) {
      print('❌ Error deleting pocket: $e');
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  // Get all users (untuk debugging)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await database;
      final users = await db.query('users');
      print('📊 Total users in database: ${users.length}');
      return users;
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  // Delete user (untuk testing/debugging)
  Future<bool> deleteUser(String phone) async {
    try {
      print('🗑️ Deleting user: $phone');

      final db = await database;

      // Delete related data first
      await db.delete(
        'transactions',
        where: 'user_phone = ?',
        whereArgs: [phone],
      );
      await db.delete(
        'beneficiaries',
        where: 'user_phone = ?',
        whereArgs: [phone],
      );
      await db.delete('pockets', where: 'user_phone = ?', whereArgs: [phone]);

      final result = await db.delete(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );

      print(result > 0 ? '✅ User deleted' : '❌ User not found');
      return result > 0;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  // Clear all data (untuk testing)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('transactions');
      await db.delete('beneficiaries');
      await db.delete('pockets');
      await db.delete('users');
      print('🧹 All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
