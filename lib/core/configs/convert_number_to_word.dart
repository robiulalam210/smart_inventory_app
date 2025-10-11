String numberToWords(int number) {
  if (number == 0) return "zero";

  final List<String> ones = [
    "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
    "sixteen", "seventeen", "eighteen", "nineteen"
  ];

  final List<String> tens = [
    "", "", "twenty", "thirty", "forty", "fifty",
    "sixty", "seventy", "eighty", "ninety"
  ];

  if (number < 20) return ones[number];
  if (number < 100) return tens[number ~/ 10] + (number % 10 != 0 ? " ${ones[number % 10]}" : "");
  if (number < 1000) return "${ones[number ~/ 100]} hundred${number % 100 != 0 ? " ${numberToWords(number % 100)}" : ""}";
  if (number < 1000000) return "${numberToWords(number ~/ 1000)} thousand${number % 1000 != 0 ? " ${numberToWords(number % 1000)}" : ""}";

  return "Number too large";
}

String amountToWords(double amount) {
  int integerPart = amount.toInt();
  int decimalPart = ((amount - integerPart) * 100).round();

  String words = numberToWords(integerPart);
  if (decimalPart > 0) {
    words += " and ${numberToWords(decimalPart)} cents";
  }
  return "$words taka only.";
}


