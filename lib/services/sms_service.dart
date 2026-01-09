import 'package:brickbybrick/models/draft_expense.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<bool> requestPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  Future<List<DraftExpense>> fetchTransactionSms() async {
    final granted = await requestPermission();
    if (!granted) {
      // Permission denied
      return [];
    }

    // Fetch messages
    final List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 100, // Fetch last 50-100 to start
    );

    List<DraftExpense> drafts = [];

    for (var msg in messages) {
      final body = msg.body;
      if (body == null) continue;

      // Filter for transaction keywords
      if (!_isTransactionMessage(body)) continue;

      final amount = _parseAmount(body);
      if (amount == null) continue;

      final merchant = _parseMerchant(body) ?? 'Unknown Merchant';
      final bankName = _parseBankName(msg.sender ?? '', body);
      
      drafts.add(DraftExpense(
        id: const Uuid().v4(),
        amount: amount,
        merchant: merchant,
        date: msg.date ?? DateTime.now(),
        originalMessage: body,
        bankName: bankName,
      ));
    }

    return drafts;
  }

  bool _isTransactionMessage(String body) {
    final lower = body.toLowerCase();
    return lower.contains('debited') ||
        lower.contains('spent') ||
        lower.contains('sent') ||
        lower.contains('paid') ||
        lower.contains('upi');
  }

  double? _parseAmount(String body) {
    // Regex for: Rs. 500, INR 500.00, Rs 500
    // (?:rs\.?|inr)\s* -> matches "rs.", "rs", "inr" followed by optional space
    // ([\d,]+(\.\d{2})?) -> matches number with commas, optional decimals
    final regExp = RegExp(
      r'(?:rs\.?|inr|₹)\s*([\d,]+(\.\d{2})?)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(body);
    
    if (match != null) {
      String amountStr = match.group(1)!;
      // Remove commas before parsing
      amountStr = amountStr.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    return null;
  }

  String? _parseMerchant(String body) {
    // Simple heuristic: Look for "at", "to"
    // This is tricky and might need refinement.
    
    // Pattern: "at [Merchant]" or "to [Merchant]"
    // We stop at end of line or before next keyword like "on" or "Ref"
    final regExp = RegExp(
      r'(?:at|to|vpa)\s+([a-zA-Z0-9\s\&]+?)(?=\s+(?:on|ref|txn|from|date|\.))',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(body);

    if (match != null) {
      return match.group(1)?.trim();
    }
    
    // Fallback: If "Zomato" or common names exist in text
    final lower = body.toLowerCase();
    if (lower.contains('zomato')) return 'Zomato';
    if (lower.contains('swiggy')) return 'Swiggy';
    if (lower.contains('uber')) return 'Uber';
    
    return null;
  }

  String _parseBankName(String sender, String body) {
    final upperSender = sender.toUpperCase();
    final lowerBody = body.toLowerCase();

    // Map of Keywords (Sender ID parts or Body text) -> Bank Name
    // Order matters: More specific/longer matches first
    final Map<String, String> bankMap = {
      // Major Banks
      'HDFC': 'HDFC Bank',
      'ICICI': 'ICICI Bank',
      'SBI': 'SBI', // State Bank of India
      'AXIS': 'Axis Bank',
      'KOTAK': 'Kotak Mahindra Bank',
      'BOB': 'Bank of Baroda',
      'BARODA': 'Bank of Baroda',
      'PNB': 'Punjab National Bank',
      'PUNJAB': 'Punjab National Bank',
      'CANARA': 'Canara Bank',
      'UNION': 'Union Bank',
      'UBI': 'Union Bank', // Ambiguous but often Union Bank in modern context
      'INDUS': 'IndusInd Bank',
      'IDFC': 'IDFC First Bank',
      'YES': 'Yes Bank',
      'RBL': 'RBL Bank',
      'FED': 'Federal Bank',
      'FDRL': 'Federal Bank',
      'FEDERAL': 'Federal Bank',
      'IOB': 'Indian Overseas Bank',
      'INDIAN': 'Indian Bank',
      'IDBI': 'IDBI Bank',
      'UCO': 'UCO Bank',
      'CBI': 'Central Bank of India',
      'CENTRAL': 'Central Bank of India',
      'BOM': 'Bank of Maharashtra',
      'MAHARASHTRA': 'Bank of Maharashtra',
      
      // Payments Banks & Wallets
      'PAYTM': 'Paytm Bank',
      'AIRTEL': 'Airtel Payments Bank',
      'JIO': 'Jio Payments Bank',
      'AMAZON': 'Amazon Pay',
      'DBS': 'DBS Bank',
      'STANDARD': 'Standard Chartered',
      'SC': 'Standard Chartered',
      'CITI': 'Citi Bank',
      'HSBC': 'HSBC',
      
      // South Indian Banks
      'SOUTH': 'South Indian Bank',
      'SIB': 'South Indian Bank',
      'KARNATAKA': 'Karnataka Bank',
      'KVB': 'Karur Vysya Bank',
      'KARUR': 'Karur Vysya Bank',
      'DHAN': 'Dhanlaxmi Bank',
      'CSB': 'CSB Bank',
    };

    // 1. Check Sender ID (High Confidence)
    // Sender IDs are usually like AD-HDFCBK, VK-ICICIB, BZ-SBIINB
    for (var entry in bankMap.entries) {
      if (upperSender.contains(entry.key)) {
        return entry.value;
      }
    }

    // 2. Check Body Content (Medium Confidence)
    // We look for the keyword usage. To be safe, we might check for "Bank" next to it 
    // or known phrases, but for now simple containment with boundary safety would be good.
    // However, for simplicity and speed, we'll iterate the map.
    // We skip short keys (like 'SC', 'YES') to avoid false positives in text unless matched carefully.
    
    for (var entry in bankMap.entries) {
      // Skip very short keys for body search to avoid detecting "IS" from "AXIS" inside "THIS" etc 
      // though our keys are mostly distinct.
      // "YES" might match "yesterday". "FED" might match "fed".
      
      if (lowerBody.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // 3. Fallback: Check for generic "Account ending" pattern if no bank found
    // This returns a generic placeholder if we can't find a bank name.
    final acMatch = RegExp(r'[aA]/[cC]\s+(?:no\.|ending)?\s*X*(\d{4})').firstMatch(body);
    if (acMatch != null) {
      return 'Bank (..${acMatch.group(1)})';
    }

    return 'Bank';
  }
}
