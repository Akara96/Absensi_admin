import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class OvertimeRequestScreen extends StatefulWidget {
  const OvertimeRequestScreen({super.key});

  @override
  State<OvertimeRequestScreen> createState() => _OvertimeRequestScreenState();
}

class _OvertimeRequestScreenState extends State<OvertimeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();

  DateTime _tanggalLembur = DateTime.now();
  TimeOfDay _orasHahu = const TimeOfDay(hour: 17, minute: 30);
  TimeOfDay _orasRemata = const TimeOfDay(hour: 20, minute: 00);
  
  bool _isLoading = false;

  List<dynamic> _historiLembur = [];
  bool _isLoadingHistori = true;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayFormat = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadHistori();
  }

  Future<void> _loadHistori() async {
    try {
      final data = await ApiService.getHistoriLembur();
      if (mounted) setState(() { _historiLembur = data; _isLoadingHistori = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistori = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLembur,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        _tanggalLembur = picked;
      });
    }
  }

  Future<void> _pickTime({required bool isMulai}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMulai ? _orasHahu : _orasRemata,
    );
    if (picked != null) {
      setState(() {
        if (isMulai) _orasHahu = picked;
        else _orasRemata = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final strHahu = '${_orasHahu.hour.toString().padLeft(2, '0')}:${_orasHahu.minute.toString().padLeft(2, '0')}';
      final strRemata = '${_orasRemata.hour.toString().padLeft(2, '0')}:${_orasRemata.minute.toString().padLeft(2, '0')}';
      
      await ApiService.submitLembur(
        dataLembur: _dateFormat.format(_tanggalLembur),
        orasHahu: strHahu,
        orasRemata: strRemata,
        razaun: _keteranganController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedidu Lembur submete ona! Hein aprova.'), backgroundColor: Colors.green),
        );
        _keteranganController.clear();
        setState(() => _isLoading = false);
        _loadHistori();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Pedidu Lembur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Informasaun Lembur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                              const SizedBox(height: 16),

                              // Tanggal Lembur
                              _DateTile(
                                label: 'Data Lembur',
                                date: _displayFormat.format(_tanggalLembur),
                                onTap: _pickDate,
                              ),
                              const SizedBox(height: 20),

                              // Waktu Range
                              Row(
                                children: [
                                  Expanded(
                                    child: _TimeTile(
                                      label: 'Oras Hahu',
                                      time: _orasHahu.format(context),
                                      onTap: () => _pickTime(isMulai: true),
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_rounded, color: Colors.grey)),
                                  Expanded(
                                    child: _TimeTile(
                                      label: 'Oras Remata',
                                      time: _orasRemata.format(context),
                                      onTap: () => _pickTime(isMulai: false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Keterangan
                              TextFormField(
                                controller: _keteranganController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Razaun / Tarefa (Obrigatóriu)',
                                  prefixIcon: const Icon(Icons.work_history),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Favor hatama razaun/tarefa' : null,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded),
                          label: Text(_isLoading ? 'Hein...' : 'Haruka Pedidu', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Histori Section
                      Text('Históriu Lembur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                      const SizedBox(height: 12),
                      _isLoadingHistori
                          ? const Center(child: CircularProgressIndicator())
                          : _historiLembur.isEmpty
                              ? _EmptyHistori()
                              : Column(
                                  children: _historiLembur.map((lembur) => _LemburCard(lembur: lembur)).toList(),
                                ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _DateTile extends StatelessWidget {
  final String label, date;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label, time;
  final VoidCallback onTap;
  const _TimeTile({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LemburCard extends StatelessWidget {
  final dynamic lembur;
  const _LemburCard({required this.lembur});

  @override
  Widget build(BuildContext context) {
    final statusColors = {'hein': Colors.orange, 'aprova': Colors.green, 'rejeita': Colors.red};
    
    final statusManajer = lembur['estadu_manajer'] as String? ?? 'hein';
    final statusHr = lembur['estadu_hr'] as String? ?? 'hein';
    
    // Overall status logic
    String finalStatus = statusHr;
    Color statusColor = statusColors[statusHr] ?? Colors.grey;
    if (statusHr == 'hein') {
      if (statusManajer == 'rejeita') {
        finalStatus = 'rejeita (Manajer)';
        statusColor = Colors.red;
      } else if (statusManajer == 'aprova') {
        finalStatus = 'Hein HR';
      } else {
        finalStatus = 'Hein Manajer';
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.work_history, color: statusColor),
        ),
        title: Text('${lembur['data_lembur']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 4),
             Text('${lembur['oras_hahu']} → ${lembur['oras_remata']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
             Text('${lembur['razaun']}', style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(finalStatus.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _EmptyHistori extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Seidauk iha históriu lembur.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
