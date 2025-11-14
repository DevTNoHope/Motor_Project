String two(int n)=> n.toString().padLeft(2,'0');
String formatHM(DateTime d)=> '${two(d.hour)}:${two(d.minute)}';
String formatYMD(DateTime d)=> '${d.year}-${two(d.month)}-${two(d.day)}';
