String formatNumberAll(double number) {
  List<String> parts = number.toStringAsFixed(2).split('.'); // Ensure two decimal places
  String integerPart = parts[0];
  String decimalPart = parts[1];

  // Add commas to the integer part
  String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');

  return '$formattedInteger.$decimalPart'; // Combine integer and decimal parts
}


