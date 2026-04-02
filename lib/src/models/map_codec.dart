Map<String, dynamic> decodeStringKeyMap(dynamic raw) {
  if (raw is! Map) return {};
  return raw.map((k, v) => MapEntry(k.toString(), deepDecode(v)));
}

dynamic deepDecode(dynamic v) {
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), deepDecode(val)));
  }
  if (v is List) {
    return v.map(deepDecode).toList();
  }
  return v;
}

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double asDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

bool asBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  return fallback;
}
