String two(int n)=> n.toString().padLeft(2,'0');
String formatHM(DateTime d)=> '${two(d.hour)}:${two(d.minute)}';
String formatYMD(DateTime d)=> '${d.year}-${two(d.month)}-${two(d.day)}';
String formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
