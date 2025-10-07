// src/vision/anchors.ts
// Sistema de normalização e ponderação de âncoras visuais

import { VisionContext } from '../../supabase/functions/_shared/vision/extractor.ts';

export interface Anchor {
  token: string;
  original: string;
  source: 'vision' | 'ocr';
  confidence: number;
  weight: number;
  category: 'object' | 'action' | 'place' | 'color' | 'detail' | 'ocr';
}

/**
 * Mapeamento de traduções para termos visuais comuns
 */
const VISUAL_TERM_TRANSLATIONS: Record<string, string[]> = {
  // Animais
  'cat': ['gato', 'gata', 'felino', 'bichano'],
  'dog': ['cachorro', 'cão', 'cao', 'canino'],
  'bird': ['passaro', 'ave', 'passarinho'],

  // Móveis
  'chair': ['cadeira', 'poltrona', 'assento'],
  'table': ['mesa', 'mesinha'],
  'sofa': ['sofa', 'estofado', 'sofal'],
  'bed': ['cama', 'leito'],

  // Cores básicas
  'red': ['vermelho', 'vermelha'],
  'blue': ['azul'],
  'green': ['verde'],
  'yellow': ['amarelo', 'amarela'],
  'orange': ['laranja'],
  'purple': ['roxo', 'roxoa'],
  'pink': ['rosa'],
  'black': ['preto', 'preta'],
  'white': ['branco', 'branca'],
  'gray': ['cinza'],
  'brown': ['marrom', 'castanho'],

  // Lugares
  'room': ['sala', 'quarto', 'comodo'],
  'kitchen': ['cozinha'],
  'bedroom': ['quarto', 'dormitorio'],
  'living': ['sala', 'estar'],
  'office': ['escritorio', 'escritório'],

  // Ações
  'sitting': ['sentado', 'sentada', 'sentando'],
  'standing': ['em', 'pe', 'de', 'pe'],
  'eating': ['comendo', 'alimentando'],
  'drinking': ['bebendo'],
};

/**
 * Lista de stopwords em português brasileiro
 */
const PORTUGUESE_STOPWORDS = new Set([
  'a', 'à', 'ao', 'aos', 'aquela', 'aquelas', 'aquele', 'aqueles', 'aquilo',
  'as', 'às', 'até', 'com', 'como', 'da', 'das', 'de', 'dela', 'delas',
  'dele', 'deles', 'do', 'dos', 'e', 'é', 'ela', 'elas', 'ele', 'eles',
  'em', 'entre', 'era', 'eram', 'éramos', 'essa', 'essas', 'esse', 'esses',
  'esta', 'está', 'estamos', 'estão', 'estas', 'estava', 'estavam', 'estávamos',
  'fosse', 'fossem', 'fôssemos', 'há', 'haja', 'hajam', 'hajamos', 'hão',
  'havia', 'haviam', 'havíamos', 'hei', 'houve', 'houvemos', 'houver',
  'houvera', 'houveram', 'houvéramos', 'houverei', 'houverem', 'houveremos',
  'houveria', 'houveriam', 'houveríamos', 'houvermos', 'houvesse', 'houvessem',
  'houvéssemos', 'isso', 'isto', 'já', 'lhe', 'lhes', 'mais', 'mas', 'me',
  'mesmo', 'meu', 'meus', 'minha', 'minhas',  'muito', 'na', 'não', 'nao', 'nas',
  'nem', 'no', 'nos', 'nós', 'nossa', 'nossas', 'nosso', 'nossos', 'num',
  'numa', 'o', 'os', 'ou', 'para', 'pela', 'pelas', 'pelo', 'pelos',
  'por', 'qual', 'quando', 'que', 'quem', 'se', 'seja', 'sejam', 'sejamos',
  'sem', 'ser', 'será', 'serão', 'serei', 'seremos', 'seria', 'seriam',
  'seríamos', 'seu', 'seus', 'só', 'somos', 'sou', 'sua', 'suas', 'também',
  'te', 'tem', 'tém', 'tem', 'temos', 'tenha', 'tenham', 'tenhamos', 'tenho',
  'ter', 'terá', 'terão', 'terei', 'teremos', 'teria', 'teriam', 'teríamos',
  'teu', 'teus', 'teve', 'tinha', 'tinham', 'tínhamos', 'tive', 'tivemos',
  'tiver', 'tivera', 'tiveram', 'tivéramos', 'tiverem', 'tivermos', 'tivesse',
  'tivessem', 'tivéssemos', 'tu', 'tua', 'tuas', 'um', 'uma', 'você', 'vocês',
  'vos'
]);

/**
 * Expande termos visuais usando traduções
 */
function expandVisualTerms(term: string): string[] {
  const normalized = normalizeToken(term);
  const translations: string[] = [];

  // Verificar se o termo normalizado tem traduções
  for (const [english, portugueseList] of Object.entries(VISUAL_TERM_TRANSLATIONS)) {
    if (normalized === english) {
      translations.push(...portugueseList);
    }
  }

  // Se não tiver traduções, usar o termo normalizado
  return translations.length > 0 ? translations : [normalized];
}

/**
 * Normaliza um token removendo acentos, convertendo para lowercase,
 * removendo caracteres especiais e filtrando stopwords
 */
export function normalizeToken(text: string): string {
  if (!text || typeof text !== 'string') {
    return '';
  }

  // 1. Converter para lowercase
  let normalized = text.toLowerCase();

  // 2. Remover acentos (simplificado - pode ser melhorado com biblioteca)
  normalized = normalized
    .replace(/[áàâãä]/g, 'a')
    .replace(/[éèêë]/g, 'e')
    .replace(/[íìîï]/g, 'i')
    .replace(/[óòôõö]/g, 'o')
    .replace(/[úùûü]/g, 'u')
    .replace(/[ç]/g, 'c')
    .replace(/[ñ]/g, 'n');

  // 3. Manter apenas letras e números (remover pontuação e símbolos)
  normalized = normalized.replace(/[^a-zA-Z0-9]/g, ' ');

  // 4. Dividir em palavras e filtrar
  const words = normalized.split(/\s+/).filter(word => word.length > 0);

  // 5. Filtrar stopwords e palavras muito curtas
  const filteredWords = words.filter(word =>
    word.length >= 3 && !PORTUGUESE_STOPWORDS.has(word)
  );

  // 6. Juntar de volta (escolher a palavra mais longa se houver múltiplas formas)
  return filteredWords.length > 0 ? filteredWords[0] : '';
}

/**
 * Calcula o peso de uma âncora baseado na confiança e fonte
 */
export function calculateAnchorWeight(confidence: number, source: 'vision' | 'ocr'): number {
  // Garantir que confiança seja sempre positiva
  const safeConfidence = Math.max(0, confidence);

  // Peso base: confiança (mínimo 0.5 para evitar âncoras muito fracas)
  let weight = Math.max(safeConfidence, 0.5);

  // Bonus baseado na fonte
  if (source === 'ocr') {
    // OCR geralmente é mais confiável para texto específico
    weight += 0.3;
  } else {
    // Vision para objetos/cores/locais
    weight += 0.1;
  }

  // Garantir limites
  return Math.max(0.1, Math.min(1.0, weight));
}

/**
 * Computa âncoras normalizadas a partir do contexto visual
 */
export function computeAnchors(ctx: VisionContext): Anchor[] {
  const anchors = new Map<string, Anchor>();

  // 1. Processar objetos detectados
  for (const obj of ctx.objects) {
    const token = normalizeToken(obj.name);
    if (token) {
      const weight = calculateAnchorWeight(obj.confidence, 'vision');
      const existing = anchors.get(token);

      // Manter a âncora com maior peso
      if (!existing || weight > existing.weight) {
        anchors.set(token, {
          token,
          original: obj.name,
          source: 'vision',
          confidence: obj.confidence,
          weight,
          category: 'object'
        });
      }
    }
  }

  // 2. Processar ações detectadas
  for (const action of ctx.actions) {
    const token = normalizeToken(action.name);
    if (token) {
      const weight = calculateAnchorWeight(action.confidence, 'vision');
      const existing = anchors.get(token);

      if (!existing || weight > existing.weight) {
        anchors.set(token, {
          token,
          original: action.name,
          source: 'vision',
          confidence: action.confidence,
          weight,
          category: 'action'
        });
      }
    }
  }

  // 3. Processar lugares detectados
  for (const place of ctx.places) {
    const token = normalizeToken(place.name);
    if (token) {
      const weight = calculateAnchorWeight(place.confidence, 'vision');
      const existing = anchors.get(token);

      if (!existing || weight > existing.weight) {
        anchors.set(token, {
          token,
          original: place.name,
          source: 'vision',
          confidence: place.confidence,
          weight,
          category: 'place'
        });
      }
    }
  }

  // 4. Processar cores detectadas
  for (const color of ctx.colors) {
    const token = normalizeToken(color);
    if (token) {
      const weight = calculateAnchorWeight(0.8, 'vision'); // Cores geralmente confiáveis
      const existing = anchors.get(token);

      if (!existing || weight > existing.weight) {
        anchors.set(token, {
          token,
          original: color,
          source: 'vision',
          confidence: 0.8,
          weight,
          category: 'color'
        });
      }
    }
  }

  // 5. Processar detalhes notáveis
  for (const detail of ctx.notable_details) {
    const token = normalizeToken(detail);
    if (token) {
      const weight = calculateAnchorWeight(0.7, 'vision'); // Detalhes geralmente confiáveis
      const existing = anchors.get(token);

      if (!existing || weight > existing.weight) {
        anchors.set(token, {
          token,
          original: detail,
          source: 'vision',
          confidence: 0.7,
          weight,
          category: 'detail'
        });
      }
    }
  }

  // 6. Processar texto OCR (bonus de confiança)
  if (ctx.ocr_text && ctx.ocr_text.trim()) {
    const ocrWords = ctx.ocr_text.split(/\s+/).filter(word => word.length > 0);

    for (const word of ocrWords) {
      const token = normalizeToken(word);
      if (token) {
        const weight = calculateAnchorWeight(0.9, 'ocr'); // OCR muito confiável
        const existing = anchors.get(token);

        if (!existing || weight > existing.weight) {
          anchors.set(token, {
            token,
            original: word,
            source: 'ocr',
            confidence: 0.9,
            weight,
            category: 'ocr'
          });
        }
      }
    }
  }

  // Converter Map para Array e ordenar por peso (descendente)
  const anchorList = Array.from(anchors.values());

  // Garantir pelo menos 1 âncora se houver qualquer evidência
  if (anchorList.length === 0 && (
    ctx.objects.length > 0 ||
    ctx.actions.length > 0 ||
    ctx.places.length > 0 ||
    ctx.colors.length > 0 ||
    ctx.notable_details.length > 0 ||
    ctx.ocr_text.trim().length > 0
  )) {
    // Criar âncora genérica baseada na confiança geral
    anchorList.push({
      token: 'elemento',
      original: 'elemento visual',
      source: 'vision',
      confidence: ctx.confidence_overall,
      weight: Math.max(ctx.confidence_overall, 0.5),
      category: 'detail'
    });
  }

  // Ordenar por peso (maior primeiro)
  anchorList.sort((a, b) => b.weight - a.weight);

  console.log(`🔗 Âncoras computadas: ${anchorList.length} únicas`);
  console.log(`📊 Top âncoras: ${anchorList.slice(0, 5).map(a => `${a.token}(${a.weight.toFixed(2)})`).join(', ')}`);

  return anchorList;
}

/**
 * Filtra âncoras já utilizadas (exhausted) para variedade
 */
export function filterAvailableAnchors(
  allAnchors: Anchor[],
  exhaustedTokens: Set<string>
): Anchor[] {
  return allAnchors.filter(anchor => !exhaustedTokens.has(anchor.token));
}

/**
 * Marca âncoras como utilizadas para evitar repetição
 */
export function markAnchorsAsExhausted(
  usedTokens: string[]
): Set<string> {
  return new Set(usedTokens.map(token => normalizeToken(token)));
}
