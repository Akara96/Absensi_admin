import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();

  String _tipeIzin = 'izin';
  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now();
  File? _fotoFile;
  bool _isLoading = false;

  // Histori izin
  List<dynamic> _historiIzin = [];
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
      final data = await ApiService.getHistoriIzin();
      if (mounted) setState(() { _historiIzin = data; _isLoadingHistori = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistori = false);
    }
  }

  Future<void> _pickDate({required bool isMulai}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isMulai ? _tanggalMulai : _tanggalSelesai,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = picked;
          if (_tanggalSelesai.isBefore(picked)) _tanggalSelesai = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Hili Foto Evidénsia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_library)),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source != null) {
      final img = await picker.pickImage(source: source, imageQuality: 70);
      if (img != null) setState(() => _fotoFile = File(img.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favor hamoos foto evidénsia!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.submitIzin(
        tipeIzin: _tipeIzin,
        tanggalMulai: _dateFormat.format(_tanggalMulai),
        tanggalSelesai: _dateFormat.format(_tanggalSelesai),
        keterangan: _keteranganController.text.trim(),
        filePath: _fotoFile!.path,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedidu Lisensa submete ona! Hein aprova husi Admin.'), backgroundColor: Colors.green),
        );
        _keteranganController.clear();
        setState(() { _fotoFile = null; _isLoading = false; });
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
                title: const Text('Pedidu Lisensa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      // Form Card
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Informasaun Pedidu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                              const SizedBox(height: 16),

                              // Tipe Izin
                              const Text('Tipe Pedidu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _TipeChip(label: 'Izin', value: 'izin', icon: Icons.person_off_outlined, selected: _tipeIzin == 'izin', onTap: () => setState(() => _tipeIzin = 'izin')),
                                  const SizedBox(width: 8),
                                  _TipeChip(label: 'Moras', value: 'sakit', icon: Icons.sick_outlined, selected: _tipeIzin == 'sakit', onTap: () => setState(() => _tipeIzin = 'sakit')),
                                  const SizedBox(width: 8),
                                  _TipeChip(label: 'Férias', value: 'cuti', icon: Icons.beach_access_outlined, selected: _tipeIzin == 'cuti', onTap: () => setState(() => _tipeIzin = 'cuti')),
                                  const SizedBox(width: 8),
                                  _TipeChip(label: 'Mendesak', value: 'mendesak', icon: Icons.notification_important_outlined, selected: _tipeIzin == 'mendesak', onTap: () => setState(() => _tipeIzin = 'mendesak')),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Tanggal Range
                              Row(
                                children: [
                                  Expanded(
                                    child: _DateTile(
                                      label: 'Data Hahu',
                                      date: _displayFormat.format(_tanggalMulai),
                                      onTap: () => _pickDate(isMulai: true),
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_rounded, color: Colors.grey)),
                                  Expanded(
                                    child: _DateTile(
                                      label: 'Data Remata',
                                      date: _displayFormat.format(_tanggalSelesai),
                                      onTap: () => _pickDate(isMulai: false),
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
                                  labelText: 'Razaun / Keterangan',
                                  prefixIcon: const Icon(Icons.edit_note),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Favor hatama razaun' : null,
                              ),
                              const SizedBox(height: 20),

                              // Photo Upload
                              const Text('Foto Evidénsia (Obrigatóriu)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4), width: 2, style: BorderStyle.solid),
                                    color: colorScheme.primary.withValues(alpha: 0.05),
                                  ),
                                  child: _fotoFile != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.file(_fotoFile!, fit: BoxFit.cover),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_photo_alternate_outlined, size: 40, color: colorScheme.primary),
                                            const SizedBox(height: 8),
                                            Text('Toke hodi hamoos foto', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                ),
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
                      Text('Históriu Pedidu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                      const SizedBox(height: 12),
                      _isLoadingHistori
                          ? const Center(child: CircularProgressIndicator())
                          : _historiIzin.isEmpty
                              ? _EmptyHistori()
                              : Column(
                                  children: _historiIzin.map((izin) => _IzinCard(izin: izin)).toList(),
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

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _TipeChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TipeChip({required this.label, required this.value, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? colorScheme.primary : Colors.transparent),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label, date;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
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

class _IzinCard extends StatelessWidget {
  final dynamic izin;
  const _IzinCard({required this.izin});

  @override
  Widget build(BuildContext context) {
    final statusColors = {'menunggu': Colors.orange, 'disetujui': Colors.green, 'ditolak': Colors.red};
    final tipeIcons = {
      'sakit': Icons.sick_outlined,
      'izin': Icons.person_off_outlined,
      'cuti': Icons.beach_access_outlined,
      'mendesak': Icons.notification_important_outlined,
    };
    final status = izin['status_pengajuan'] as String? ?? 'menunggu';
    final tipe = izin['tipe_izin'] as String? ?? 'izin';
    var statusColor = statusColors[status] ?? Colors.grey;

    // Special color for mendezak if pending
    if (tipe == 'mendesak' && status == 'menunggu') {
      statusColor = Colors.red;
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
          child: Icon(tipeIcons[tipe] ?? Icons.help_outline, color: statusColor),
        ),
        title: Text(izin['tipe_izin_display'] ?? tipe, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${izin['tanggal_mulai']} → ${izin['tanggal_selesai']}', style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(izin['status_display'] ?? status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
          Text('Seidauk iha históriu pedidu lisensa.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
