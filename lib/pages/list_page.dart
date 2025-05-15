// lib/pages/list_page.dart

import 'package:flutter/material.dart';
import '../main.dart';
import '../db/database_helper.dart';
import '../models/transacao_model.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Transacao> _transacoes = [];
  String _filtroTipo = 'Todos';

  double _totalGeral = 0.0;
  double _totalAvista = 0.0;
  double _totalFiado = 0.0;
  double _totalGastos = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  Future<void> _carregarTransacoes() async {
    final todas = await DatabaseHelper.instance.listarTransacoes();
    setState(() {
      _transacoes = _filtroTipo == 'Todos'
          ? todas
          : todas.where((t) => t.tipo == _filtroTipo).toList();

      _totalAvista = todas
          .where((t) => t.tipo == 'À vista')
          .fold(0.0, (soma, t) => soma + t.valor);
      _totalFiado = todas
          .where((t) => t.tipo == 'Fiado')
          .fold(0.0, (soma, t) => soma + t.valor);
      _totalGastos = todas
          .where((t) => t.tipo == 'Gastos')
          .fold(0.0, (soma, t) => soma + t.valor);
      _totalGeral = _totalAvista + _totalFiado - _totalGastos;
    });
  }

  void _alterarFiltro(String tipo) {
    setState(() {
      _filtroTipo = tipo;
    });
    _carregarTransacoes();
  }

  Future<void> _editarTransacao(Transacao t) async {
    final formKey = GlobalKey<FormState>();
    String desc = t.descricao;
    String val = t.valor.toString();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Transação'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: desc,
                decoration: const InputDecoration(labelText: 'Descrição'),
                onChanged: (v) => desc = v,
              ),
              TextFormField(
                initialValue: val,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => val = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final novoValor = double.tryParse(val.replaceAll(',', '.')) ?? t.valor;
              final updated = Transacao(
                id: t.id,
                tipo: t.tipo,
                descricao: desc,
                valor: novoValor,
                data: t.data,
              );
              await DatabaseHelper.instance.atualizarTransacao(updated);
              Navigator.pop(context);
              _carregarTransacoes();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirTransacao(int id) async {
    await DatabaseHelper.instance.excluirTransacao(id);
    _carregarTransacoes();
  }

  String _formatarData(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildFiltro(String label) {
      final isSelected = _filtroTipo == label;
      Color bg;
      switch (label) {
        case 'À vista':
          bg = isSelected ? Colors.green : Colors.green.withOpacity(0.5);
          break;
        case 'Fiado':
          bg = isSelected ? Colors.orange : Colors.orange.withOpacity(0.5);
          break;
        case 'Gastos':
          bg = isSelected ? Colors.red : Colors.red.withOpacity(0.5);
          break;
        default:
          bg = isSelected ? kPrimaryCiano : kPrimaryCiano.withOpacity(0.5);
      }
      return ElevatedButton(
        onPressed: () => _alterarFiltro(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: isSelected ? 4 : 0,
        ),
        child: Text(label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryCiano,
        title: const Text('Relatório de Transações'),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Como usar'),
                  content: const Text(
                    '🟢 Arraste para a direita para EDITAR.\n'
                    '🔴 Arraste para a esquerda para EXCLUIR.\n'
                    'Use os botões de filtro acima para selecionar o tipo.',
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendi'))],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildResumoLinha('Total Geral', _totalGeral, Colors.grey),
                  const SizedBox(height: 8),
                  _buildResumoLinha('À Vista', _totalAvista, Colors.green),
                  const SizedBox(height: 8),
                  _buildResumoLinha('Fiado', _totalFiado, Colors.orange),
                  const SizedBox(height: 8),
                  _buildResumoLinha('Gastos', _totalGastos, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                buildFiltro('Todos'),
                const SizedBox(width: 8),
                buildFiltro('À vista'),
                const SizedBox(width: 8),
                buildFiltro('Fiado'),
                const SizedBox(width: 8),
                buildFiltro('Gastos'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _transacoes.length,
              itemBuilder: (context, index) {
                final t = _transacoes[index];
                return Dismissible(
                  key: Key(t.id.toString()),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await _excluirTransacao(t.id!);
                      return true;
                    } else {
                      await _editarTransacao(t);
                      return false;
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Icon(
                        t.tipo == 'Fiado'
                            ? Icons.warning_amber
                            : t.tipo == 'Gastos'
                                ? Icons.shopping_cart
                                : Icons.attach_money,
                        color: t.tipo == 'Fiado'
                            ? Colors.orange
                            : t.tipo == 'Gastos'
                                ? Colors.red
                                : Colors.green,
                      ),
                      title: Text(t.descricao),
                      subtitle: Text(_formatarData(t.data)),
                      trailing: Text('R\$ ${t.valor.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoLinha(String label, double valor, Color cor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: cor, fontSize: 16)),
        Text('R\$ ${valor.toStringAsFixed(2)}', style: TextStyle(color: cor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
