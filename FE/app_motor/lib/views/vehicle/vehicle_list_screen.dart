import 'package:flutter/material.dart';
import '../../services/reference_service.dart';
import '../../models/vehicle.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});
  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final _ref = ReferenceService();
  List<Vehicle> _vehicles = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final vs = await _ref.listVehicles();
    setState(() => _vehicles = vs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xe của tôi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final v = _vehicles[i];
          return ListTile(
            leading: const Icon(Icons.motorcycle),
            title: Text(v.plateNo),
            subtitle: Text('${v.brand ?? ''} ${v.model ?? ''}'),
          );
        },
      ),
    );
  }
}
