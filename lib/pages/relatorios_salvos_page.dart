// lib/pages/relatorios_salvos_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';

class RelatoriosSalvosPage extends StatefulWidget {
  const RelatoriosSalvosPage({super.key});

  @override
  State<RelatoriosSalvosPage> createState() => _RelatoriosSalvosPageState();
}

class _RelatoriosSalvosPageState extends State<RelatoriosSalvosPage> {
  List<FileSystemEntity> _arquivos = [];

  @override
  void initState() {
    super.initState();
    _carregarArquivos();
  }

  Future<void> _carregarArquivos() async {
    final dir = await getApplicationDocumentsDirectory();
    final pasta = Directory('${dir.path}/relatorios');
    if (await pasta.exists()) {
      final arquivos = pasta.listSync().where((f) {
        final ext = f.path.split('.').last.toLowerCase();
        return ext == 'csv' || ext == 'pdf';
      }).toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      setState(() => _arquivos = arquivos);
    }
  }

  Future<void> _abrirArquivo(String path) async {
    await OpenFile.open(path);
  }

  Future<void> _compartilharArquivo(String path) async {
    final ext = path.split('.').last.toLowerCase();
    if (ext == 'pdf') {
      await Share.shareXFiles([XFile(path)], text: 'Relatório PDF');
    } else {
      await Share.shareXFiles([XFile(path)], text: 'Relatório CSV');
    }
  }

  Future<void> _excluirArquivo(FileSystemEntity file) async {
    try {
      await file.delete();
      await _carregarArquivos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo excluído com sucesso.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryCiano,
        title: const Text('Relatórios Salvos'),
        elevation: 4,
      ),
      body: _arquivos.isEmpty
          ? Center(
              child: Text(
                'Nenhum relatório encontrado.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _arquivos.length,
              itemBuilder: (ctx, i) {
                final file = _arquivos[i] as File;
                final name = file.uri.pathSegments.last;
                final m = file.statSync().modified;
                final date = DateTime.fromMillisecondsSinceEpoch(m.millisecondsSinceEpoch);
                final formattedDate = '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/'
                    '${date.year} ${date.hour.toString().padLeft(2, '0')}:''${date.minute.toString().padLeft(2, '0')}';
                final ext = name.split('.').last.toLowerCase();
                final icon = ext == 'pdf' ? Icons.picture_as_pdf : Icons.table_chart;
                final iconColor = ext == 'pdf' ? Colors.red : kPrimaryCiano;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(icon, color: iconColor),
                    title: Text(name),
                    subtitle: Text(formattedDate),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.open_in_new, color: kPrimaryCiano),
                          tooltip: 'Abrir',
                          onPressed: () => _abrirArquivo(file.path),
                        ),
                        IconButton(
                          icon: Icon(Icons.share, color: kPrimaryCiano),
                          tooltip: 'Compartilhar',
                          onPressed: () => _compartilharArquivo(file.path),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          tooltip: 'Excluir',
                          onPressed: () => showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir arquivo'),
                              content: const Text('Deseja realmente excluir este arquivo?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
                              ],
                            ),
                          ).then((ok) {
                            if (ok == true) _excluirArquivo(file);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
