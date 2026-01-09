class SmartCategorizer {
  static String guessCategory(String merchantName) {
    merchantName = merchantName.toLowerCase();
    
    if (merchantName.contains('zomato') || merchantName.contains('swiggy') || merchantName.contains('dominos') || merchantName.contains('restaurant') || merchantName.contains('cafe')) {
      return 'Food';
    } else if (merchantName.contains('uber') || merchantName.contains('ola') || merchantName.contains('rapido') || merchantName.contains('petrol') || merchantName.contains('fuel') || merchantName.contains('shell')) {
      return 'Travel';
    } else if (merchantName.contains('netflix') || merchantName.contains('spotify') || merchantName.contains('prime') || merchantName.contains('youtube') || merchantName.contains('apple')) {
      return 'Subscriptions';
    } else if (merchantName.contains('dmart') || merchantName.contains('blinkit') || merchantName.contains('bigbasket') || merchantName.contains('amazon') || merchantName.contains('flipkart') || merchantName.contains('myntra')) {
      return 'Shopping';
    }
    
    return 'General'; // Default fall-back
  }
}
