import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/motivation_provider.dart';
import '../../core/theme/theme_notifier.dart';

// FIX: tambah {super.key} pada StatefulWidget
class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<MotivationProvider>();
    provider.fetchMotivations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        provider.fetchMotivations();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy, HH:mm').format(parsed);
    } catch (e) {
      return date;
    }
  }

  void showGenerateDialog() {
    final themeController = TextEditingController();
    final totalController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<MotivationProvider>(
          builder: (ctx, provider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // FIX: tambah const pada Text widget yang tidak butuh variabel
              title: const Row(
                children: [
                  Text('✨ '),
                  Text('Generate Motivasi'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: themeController,
                    decoration: InputDecoration(
                      labelText: 'Theme',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                          // FIX: validasi input sebelum parse
                          final total =
                              int.tryParse(totalController.text.trim());
                          if (themeController.text.trim().isEmpty ||
                              total == null) {
                            return;
                          }
                          await provider.generate(
                            themeController.text.trim(),
                            total,
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: provider.isGenerating
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Generating...'),
                          ],
                        )
                      : const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotivationProvider>();
    final theme    = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delcom Motivation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showGenerateDialog,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generate'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // FIX: tampilkan error banner jika ada
              if (provider.error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: TextStyle(
                              color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.red.shade400, size: 18),
                        onPressed: provider.clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                  itemCount: provider.motivations.length + 1,
                  itemBuilder: (context, index) {
                    if (index < provider.motivations.length) {
                      final item   = provider.motivations[index];
                      final number = index + 1;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '#$number',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatDate(item.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return provider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Loading...'),
                                ],
                              ),
                            )
                          : const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),

          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
