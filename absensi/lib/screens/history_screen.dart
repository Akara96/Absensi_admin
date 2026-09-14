import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Janeiru', 'Fevereiru', 'Marsu', 'Abríl', 'Maiu', 'Juñu',
    'Jullu', 'Agostu', 'Setembru', 'Outubru', 'Novembru', 'Dezembru'
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    setState(() {
      _historyFuture = ApiService.getRiwayatAbsensi(
        bulan: _selectedMonth,
        tahun: _selectedYear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Istória Presensa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchHistory(),
              child: FutureBuilder<List<dynamic>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Mosu sala ida: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Seidauk iha istória presensa.'));
                  }

                  final history = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final status = item['status'] as String;

                      // Tentukan warna & ikon berdasarkan status
                      Color statusColor;
                      IconData statusIcon;
                      String statusLabel;

                      switch (status) {
                        case 'hadir':
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                          statusLabel = 'PREZENTE';
                          break;
                        case 'terlambat':
                          statusColor = Colors.orange;
                          statusIcon = Icons.access_time_filled;
                          statusLabel = 'TARDIU';
                          break;
                        case 'hadir_sebagian':
                          statusColor = Colors.deepOrange;
                          statusIcon = Icons.timer_off;
                          statusLabel = 'BALUN';
                          break;
                        case 'alpha':
                          statusColor = Colors.red;
                          statusIcon = Icons.cancel;
                          statusLabel = 'FALTA';
                          break;
                        default:
                          statusColor = Colors.grey;
                          statusIcon = Icons.help;
                          statusLabel = status.toUpperCase();
                      }

                      final String? durasi = item['durasaun_servisu'];
                      final String? komentariu = item['komentariu'];
                      final bool adaKeterangan =
                          komentariu != null && komentariu.isNotEmpty;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Ikon status
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    statusColor.withValues(alpha: 0.12),
                                child: Icon(statusIcon,
                                    color: statusColor, size: 26),
                              ),
                              const SizedBox(width: 12),

                              // Info utama
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['data'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    // Line 1: MASUK PAGI
                                    Row(
                                      children: [
                                        const Icon(Icons.login, size: 13, color: Colors.teal),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tama Dadersan : ${item['oras_tama'] ?? '-'}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Line 2: KELUAR ISTIRAHAT
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_off_outlined, size: 13, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Deskansa        : ${item['oras_sai_deskansa'] ?? '-'}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Line 3: MASUK SIANG
                                    Row(
                                      children: [
                                        const Icon(Icons.wb_sunny_outlined, size: 13, color: Colors.blue),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tama Lokraik    : ${item['oras_tama_lokraik'] ?? '-'}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Line 4: KELUAR SORE
                                    Row(
                                      children: [
                                        const Icon(Icons.logout, size: 13, color: Colors.red),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Sai / Fila          : ${item['oras_sai'] ?? '-'}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    if (durasi != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule,
                                              size: 13, color: Colors.teal),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Durasaun: $durasi',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.teal.shade700),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (adaKeterangan) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        komentariu,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: statusColor,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Badge status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          statusColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Fulan',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_months[index]),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMonth = val;
                  });
                  _fetchHistory();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Tinan',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                int year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedYear = val;
                  });
                  _fetchHistory();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
