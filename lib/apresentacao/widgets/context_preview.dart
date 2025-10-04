import 'package:flutter/material.dart';

/// Widget para pré-visualização do contexto extraído da imagem
/// Exibe informações como nome detectado, ambiente, pessoas, etc.
class ContextPreview extends StatelessWidget {
  final Map<String, dynamic>? visionContext;
  final bool showWhenEmpty;

  const ContextPreview({
    Key? key,
    this.visionContext,
    this.showWhenEmpty = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (visionContext == null || visionContext!.isEmpty) {
      return showWhenEmpty
          ? _buildEmptyState()
          : const SizedBox.shrink();
    }

    final personName = visionContext!['personName'] as String?;
    final imageDescription = visionContext!['imageDescription'] as String?;

    // Extrair informações úteis da descrição
    final contextInfo = _extractContextInfo(imageDescription ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Contexto Detectado',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nome da pessoa (se disponível)
          if (personName != null && personName.isNotEmpty && personName != 'Nenhum')
            _buildInfoChip(
              context,
              icon: Icons.person,
              label: 'Pessoa: $personName',
              color: Colors.blue,
            ),

          // Ambiente detectado
          if (contextInfo['ambiente'] != null)
            _buildInfoChip(
              context,
              icon: Icons.place,
              label: 'Ambiente: ${contextInfo['ambiente']}',
              color: Colors.green,
            ),

          // Número de pessoas
          if (contextInfo['pessoas'] != null)
            _buildInfoChip(
              context,
              icon: Icons.people,
              label: '${contextInfo['pessoas']}',
              color: Colors.orange,
            ),

          // Objetos/pets detectados
          if (contextInfo['objetos'] != null && contextInfo['objetos']!.isNotEmpty)
            Wrap(
              spacing: 4,
              children: contextInfo['objetos']!.map<Widget>((objeto) {
                return _buildInfoChip(
                  context,
                  icon: Icons.inventory_2,
                  label: objeto,
                  color: Colors.purple,
                  small: true,
                );
              }).toList(),
            ),

          // Texto OCR detectado
          if (contextInfo['texto_ocr'] != null && contextInfo['texto_ocr']!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Texto Detectado:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contextInfo['texto_ocr']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool small = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4, right: 4),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Não foi possível extrair contexto visual da imagem. A sugestão será baseada apenas em elementos textuais.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Extrai informações contextuais da descrição da imagem
  Map<String, dynamic> _extractContextInfo(String description) {
    final info = <String, dynamic>{};

    // Ambiente (palavras-chave de localização)
    final ambientes = ['praia', 'mar', 'cidade', 'casa', 'apartamento', 'escritório', 'trabalho', 'festa', 'bar', 'restaurante'];
    for (final ambiente in ambientes) {
      if (description.toLowerCase().contains(ambiente)) {
        info['ambiente'] = ambiente;
        break;
      }
    }

    // Número de pessoas (estimativa baseada em contexto)
    if (description.toLowerCase().contains('selfie') || description.toLowerCase().contains('sozinho')) {
      info['pessoas'] = '1 pessoa';
    } else if (description.toLowerCase().contains('grupo') || description.toLowerCase().contains('amigos')) {
      info['pessoas'] = 'Grupo';
    }

    // Objetos/pets
    final objetos = <String>[];
    final objetosChave = ['cachorro', 'gato', 'livro', 'instrumento', 'bicicleta', 'carro', 'mochila', 'óculos'];
    for (final objeto in objetosChave) {
      if (description.toLowerCase().contains(objeto)) {
        objetos.add(objeto);
      }
    }
    if (objetos.isNotEmpty) {
      info['objetos'] = objetos;
    }

    // Texto OCR (extrair da seção específica)
    final ocrMatch = description.split('\n\nTexto Extraído (OCR):');
    if (ocrMatch.length > 1) {
      final ocrText = ocrMatch[1].trim();
      if (ocrText.isNotEmpty && !ocrText.contains('Nenhum texto detectado')) {
        info['texto_ocr'] = ocrText.length > 100 ? '${ocrText.substring(0, 100)}...' : ocrText;
      }
    }

    return info;
  }
}
