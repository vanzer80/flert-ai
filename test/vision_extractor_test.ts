// test/vision_extractor_test.ts
// Teste para validar o extrator de visão determinístico

import { extractVisionContext } from '../supabase/functions/_shared/vision/extractor.ts';

// URLs de imagens de teste públicas (substitua por URLs reais se necessário)
const TEST_IMAGES = [
  'https://picsum.photos/800/600?random=1',  // Imagem aleatória 1
  'https://picsum.photos/800/600?random=2',  // Imagem aleatória 2
  'https://picsum.photos/800/600?random=3',  // Imagem aleatória 3
  'https://picsum.photos/800/600?random=4',  // Imagem aleatória 4
  'https://picsum.photos/800/600?random=5',  // Imagem aleatória 5
];

/**
 * Testa o extrator de visão com múltiplas imagens
 */
async function testVisionExtractor() {
  console.log('🧪 Iniciando testes do extrator de visão...\n');

  for (let i = 0; i < TEST_IMAGES.length; i++) {
    const imageUrl = TEST_IMAGES[i];
    console.log(`\n📷 Teste ${i + 1}/5: ${imageUrl}`);

    try {
      const result = await extractVisionContext({
        imageUrl,
        ocrTextRaw: ''
      });

      if (result.success && result.data) {
        const data = result.data;

        console.log(`   ✅ Sucesso em ${result.attempts} tentativa(s)`);
        console.log(`   📊 Confiança geral: ${data.confidence_overall.toFixed(2)}`);
        console.log(`   👥 Pessoas: ${data.detected_persons.count}`);
        console.log(`   🎯 Objetos: ${data.objects.length} ${data.objects.map(obj => `${obj.name}(${obj.confidence.toFixed(2)})`).join(', ')}`);
        console.log(`   🌈 Cores: ${data.colors.length} ${data.colors.join(', ')}`);
        console.log(`   🏠 Lugares: ${data.places.length} ${data.places.map(place => `${place.name}(${place.confidence.toFixed(2)})`).join(', ')}`);
        console.log(`   📝 OCR: ${data.ocr_text.length > 0 ? `"${data.ocr_text}"` : 'sem texto'}`);
        console.log(`   💡 Detalhes: ${data.notable_details.length} ${data.notable_details.join(', ')}`);

        // Validar estrutura JSON
        const isValidStructure = validateJsonStructure(data);
        console.log(`   🔍 JSON válido: ${isValidStructure ? '✅' : '❌'}`);

        if (result.low_confidence) {
          console.log(`   ⚠️  Baixa confiança detectada`);
        }
      } else {
        console.log(`   ❌ Falha: ${result.error}`);
        console.log(`   🔄 Tentativas: ${result.attempts}`);
      }
    } catch (error) {
      console.log(`   💥 Erro inesperado: ${error.message}`);
    }
  }

  console.log('\n🏁 Testes concluídos!');
}

/**
 * Valida estrutura básica do JSON retornado
 */
function validateJsonStructure(data: any): boolean {
  try {
    // Verificações básicas de estrutura
    if (!data || typeof data !== 'object') return false;
    if (typeof data.schema_version !== 'string') return false;
    if (!data.detected_persons || typeof data.detected_persons.count !== 'number') return false;
    if (!Array.isArray(data.objects)) return false;
    if (!Array.isArray(data.actions)) return false;
    if (!Array.isArray(data.places)) return false;
    if (!Array.isArray(data.colors)) return false;
    if (typeof data.ocr_text !== 'string') return false;
    if (!Array.isArray(data.notable_details)) return false;
    if (typeof data.confidence_overall !== 'number') return false;

    // Verificar intervalos válidos
    if (data.confidence_overall < 0 || data.confidence_overall > 1) return false;
    if (data.detected_persons.count < 0) return false;

    // Verificar estrutura de arrays
    for (const obj of data.objects) {
      if (!obj.name || typeof obj.confidence !== 'number' || obj.confidence < 0 || obj.confidence > 1) {
        return false;
      }
    }

    return true;
  } catch (error) {
    return false;
  }
}

// Executar testes se arquivo for chamado diretamente
if (import.meta.main) {
  await testVisionExtractor();
}
