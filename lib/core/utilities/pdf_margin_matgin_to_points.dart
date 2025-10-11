// --- Margins ---
double parseMargin(dynamic value, [double defaultValue = 0.2]) {
  if (value == null) return defaultValue;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return defaultValue;
}
