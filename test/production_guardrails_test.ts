// test/production_guardrails_test.ts
// Teste de validação das funcionalidades críticas do PROMPT H

import { ProductionGuardrails } from '../src/guardrails/guardrails.ts';
import { SecureEnvironment, InputValidator, SecurityLogger } from '../src/security/security.ts';
import { ObservabilityManager } from '../src/observability/observability.ts';

/**
 * Teste completo das funcionalidades críticas de produção
 */
async function testProductionGuardrails() {
  console.log('🛡️ TESTE DE GUARDRAILS DE PRODUÇÃO');
  console.log('==================================\n');

  const results = {
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    guardrailsWorking: 0,
    securityWorking: 0,
    observabilityWorking: 0
  };

  // Teste 1: Guardrail de âncoras ausentes
  results.totalTests++;
  console.log('🧪 Teste 1: Rejeição de saída sem âncora');

  try {
    const result = ProductionGuardrails.validateSuggestion(
      'Que foto interessante!',
      [], // Sem âncoras
      [],
      0
    );

    if (!result.allowed && result.reason === 'GUARDRAIL_ANCHOR_MISSING') {
      results.passedTests++;
      results.guardrailsWorking++;
      console.log('   ✅ Guardrail de âncora funcionando');
      console.log(`   📝 Fallback: "${result.fallback}"`);
    } else {
      results.failedTests++;
      console.log('   ❌ Guardrail de âncora falhou');
    }
  } catch (error) {
    results.failedTests++;
    console.log(`   ❌ Erro no teste: ${error.message}`);
  }

  // Teste 2: Controle de regeneração
  results.totalTests++;
  console.log('\n🧪 Teste 2: Limitação de regeneração');

  try {
    const result = ProductionGuardrails.validateSuggestion(
      'Sugestão alternativa',
      ['teste'],
      [],
      2 // Acima do limite (max 1)
    );

    if (!result.allowed && result.reason === 'GUARDRAIL_MAX_REGENERATIONS') {
      results.passedTests++;
      results.guardrailsWorking++;
      console.log('   ✅ Controle de regeneração funcionando');
    } else {
      results.failedTests++;
      console.log('   ❌ Controle de regeneração falhou');
    }
  } catch (error) {
    results.failedTests++;
    console.log(`   ❌ Erro no teste: ${error.message}`);
  }

  // Teste 3: Controle de repetição
  results.totalTests++;
  console.log('\n🧪 Teste 3: Controle de repetição alta');

  try {
    const result = ProductionGuardrails.validateSuggestion(
      'Que guitarra incrível! Você toca há quanto tempo?',
      ['guitarra'],
      ['Que guitarra incrível! Você toca há quanto tempo?'], // Repetição exata
      0
    );

    if (!result.allowed && result.reason === 'GUARDRAIL_HIGH_REPETITION') {
      results.passedTests++;
      results.guardrailsWorking++;
      console.log('   ✅ Controle de repetição funcionando');
      console.log(`   🔄 Taxa de repetição: ${result.metadata?.repetitionRate.toFixed(3)}`);
    } else {
      results.failedTests++;
      console.log('   ❌ Controle de repetição falhou');
    }
  } catch (error) {
    results.failedTests++;
    console.log(`   ❌ Erro no teste: ${error.message}`);
  }

  // Teste 4: Validação de entrada segura
  results.totalTests++;
  console.log('\n🧪 Teste 4: Validação de entrada');

  try {
    // Entrada válida
    const validInput = {
      userId: 'user123',
      imageData: 'data:image/jpeg;base64,abc123',
      tone: 'descontraído'
    };

    const validResult = InputValidator.validateRequest(validInput);
    if (validResult.valid) {
      results.passedTests++;
      results.securityWorking++;
      console.log('   ✅ Validação de entrada válida funcionando');
    } else {
      results.failedTests++;
      console.log('   ❌ Validação de entrada válida falhou');
    }

    // Entrada inválida
    const invalidInput = {
      imageData: 'não é base64 válido'
    };

    const invalidResult = InputValidator.validateRequest(invalidInput);
    if (!invalidResult.valid && invalidResult.errors.length > 0) {
      results.passedTests++;
      results.securityWorking++;
      console.log('   ✅ Rejeição de entrada inválida funcionando');
      console.log(`   ❌ Erros: ${invalidResult.errors.join(', ')}`);
    } else {
      results.failedTests++;
      console.log('   ❌ Rejeição de entrada inválida falhou');
    }

  } catch (error) {
    results.failedTests++;
    console.log(`   ❌ Erro no teste: ${error.message}`);
  }

  // Teste 5: Observabilidade funcionando
  results.totalTests++;
  console.log('\n🧪 Teste 5: Sistema de observabilidade');

  try {
    const requestId = 'test-request-123';
    const userId = 'test-user';
    const ip = '192.168.1.1';

    // Simular métricas
    ObservabilityManager.recordGeneration({
      requestId,
      timestamp: Date.now(),
      userId,
      ip,
      visionProcessingMs: 150,
      anchorComputationMs: 25,
      generationMs: 300,
      totalLatencyMs: 475,
      anchorCount: 4,
      anchorsUsed: 4,
      repetitionRate: 0.1,
      suggestionLength: 85,
      success: true,
      guardrailTriggered: false,
      inputImageSize: 512,
      outputTokens: 20
    });

    // Verificar se métricas foram registradas
    const recentMetrics = ObservabilityManager.getRecentMetrics(1);
    if (recentMetrics.length > 0) {
      results.passedTests++;
      results.observabilityWorking++;
      console.log('   ✅ Observabilidade registrando métricas');
      console.log(`   📊 Métricas recentes: ${recentMetrics.length}`);
    } else {
      results.failedTests++;
      console.log('   ❌ Observabilidade não registrou métricas');
    }

  } catch (error) {
    results.failedTests++;
    console.log(`   ❌ Erro no teste: ${error.message}`);
  }

  // Teste 6: Logs de segurança
  results.totalTests++;
  console.log('\n🧪 Teste 6: Logs de segurança');

  try {
    // Registrar evento de segurança
    SecurityLogger.log('warn', 'TEST_RATE_LIMIT', {
      userId: 'test-user',
      ip: '192.168.1.1',
      attempts: 15
    });

    // Verificar se log foi registrado
    const recentLogs = SecurityLogger.getRecentLogs(1);
    if (recentLogs.length > 0) {
      results.passedTests++;
      results.securityWorking++;
      console.log('   ✅ Logs de segurança funcionando');
      console.log(`   📋 Logs recentes: ${recentLogs.length}`);
    } else {
      results.failedTests++;
      console.log('   ❌ Logs de segurança não funcionaram');
    }

  } catch (error) {
    results.failedTests++;
    console.log(`   ❌ Erro no teste: ${error.message}`);
  }

  // Relatório final
  console.log('\n📊 RELATÓRIO FINAL DE VALIDAÇÃO');
  console.log('==============================');
  console.log(`Testes executados: ${results.totalTests}`);
  console.log(`Testes aprovados: ${results.passedTests}/${results.totalTests} (${(results.passedTests/results.totalTests*100).toFixed(1)}%)`);
  console.log(`Testes falhados: ${results.failedTests}`);

  console.log('\n🎯 COMPONENTES VALIDADOS:');
  console.log(`Guardrails: ${results.guardrailsWorking}/3 (${(results.guardrailsWorking/3*100).toFixed(1)}%)`);
  console.log(`Segurança: ${results.securityWorking}/2 (${(results.securityWorking/2*100).toFixed(1)}%)`);
  console.log(`Observabilidade: ${results.observabilityWorking}/1 (${(results.observabilityWorking/1*100).toFixed(1)}%)`);

  // Critérios de aceite
  const criteriaMet = {
    allTestsPassed: results.passedTests === results.totalTests,
    guardrailsWorking: results.guardrailsWorking >= 2,
    securityWorking: results.securityWorking >= 1,
    observabilityWorking: results.observabilityWorking >= 1
  };

  console.log('\n🎯 CRITÉRIOS DE ACEITE:');
  console.log(`Todos os testes passam: ${criteriaMet.allTestsPassed ? '✅' : '❌'}`);
  console.log(`Guardrails ≥67%: ${criteriaMet.guardrailsWorking ? '✅' : '❌'}`);
  console.log(`Segurança ≥50%: ${criteriaMet.securityWorking ? '✅' : '❌'}`);
  console.log(`Observabilidade 100%: ${criteriaMet.observabilityWorking ? '✅' : '❌'}`);

  const allCriteriaPassed = Object.values(criteriaMet).every(Boolean);

  console.log(`\n🏆 STATUS FINAL:`);
  console.log(`${allCriteriaPassed ? '✅ PROMPT H VALIDADO COM SUCESSO' : '❌ PROMPT H PRECISA AJUSTES'}`);

  return {
    success: allCriteriaPassed,
    results,
    criteriaMet
  };
}

/**
 * Simulação de limite de rate atingido
 */
async function simulateRateLimitTest() {
  console.log('\n🚦 SIMULAÇÃO DE LIMITE DE RATE ATINGIDO');
  console.log('=====================================\n');

  try {
    const userId = 'test-user-limit';
    const ip = '192.168.1.100';

    // Simular múltiplas tentativas (em produção seria controle real)
    for (let i = 0; i < 12; i++) {
      const check = await RateLimiter.checkRateLimit(userId, 'user');
      console.log(`Tentativa ${i + 1}: ${check.allowed ? '✅ Permitida' : '❌ Bloqueada'}`);

      if (!check.allowed) {
        console.log(`   ⏱️ Reset em: ${new Date(check.resetTime || 0).toLocaleTimeString()}`);
        break;
      }

      // Registrar tentativa
      await RateLimiter.recordAttempt(userId, 'user');
    }

    console.log('\n✅ Simulação de rate limit concluída');

  } catch (error) {
    console.log(`❌ Erro na simulação: ${error.message}`);
  }
}

/**
 * Teste de logs estruturados
 */
async function testStructuredLogging() {
  console.log('\n📋 TESTE DE LOGS ESTRUTURADOS');
  console.log('============================\n');

  try {
    const requestId = 'test-structured-logging';
    const userId = 'test-user';
    const ip = '192.168.1.1';

    // Simular eventos de uma geração
    const observability = ObservabilityManager.startRequest(requestId, userId, ip);

    observability.log('request_started', { hasImage: true, tone: 'descontraído' });
    await new Promise(resolve => setTimeout(resolve, 50));
    observability.log('vision_completed', { confidence: 0.9, objects: 3 });
    await new Promise(resolve => setTimeout(resolve, 50));
    observability.log('anchors_computed', { count: 4, tokens: ['praia', 'sol', 'mar'] });
    await new Promise(resolve => setTimeout(resolve, 50));
    observability.log('suggestion_generated', { length: 85, tone: 'descontraído' });

    // Registrar métricas finais
    observability.recordMetrics({
      visionProcessingMs: 150,
      anchorComputationMs: 25,
      generationMs: 300,
      totalLatencyMs: 475,
      anchorCount: 4,
      anchorsUsed: 4,
      repetitionRate: 0.1,
      suggestionLength: 85,
      success: true,
      guardrailTriggered: false
    });

    observability.end();

    console.log('✅ Logs estruturados registrados com sucesso');
    console.log('📊 Eventos registrados: request_started, vision_completed, anchors_computed, suggestion_generated');

  } catch (error) {
    console.log(`❌ Erro no teste de logs: ${error.message}`);
  }
}

/**
 * Teste principal de funcionalidades críticas
 */
async function runCriticalFeaturesTest() {
  console.log('🚀 TESTE DE FUNCIONALIDADES CRÍTICAS - PROMPT H');
  console.log('==============================================\n');

  try {
    // Teste principal de guardrails
    const guardrailsResult = await testProductionGuardrails();

    console.log('');

    // Simulação de rate limit
    await simulateRateLimitTest();

    console.log('');

    // Teste de logs estruturados
    await testStructuredLogging();

    // Resultado geral
    const overallSuccess = guardrailsResult.success;

    console.log('\n🏁 RESULTADO GERAL DOS TESTES CRÍTICOS');
    console.log('====================================');
    console.log(`✅ Guardrails: ${guardrailsResult.success ? 'VALIDADO' : 'FALHANDO'}`);
    console.log(`✅ Segurança: ${guardrailsResult.criteriaMet.securityWorking ? 'VALIDADO' : 'FALHANDO'}`);
    console.log(`✅ Observabilidade: ${guardrailsResult.criteriaMet.observabilityWorking ? 'VALIDADO' : 'FALHANDO'}`);

    console.log(`\n🎯 STATUS FINAL: ${overallSuccess ? '✅ PROMPT H VALIDADO' : '❌ PROMPT H PRECISA AJUSTES'}`);

    return overallSuccess;

  } catch (error) {
    console.log(`\n❌ Erro crítico nos testes: ${error.message}`);
    return false;
  }
}

// Funções auxiliares para testes
function calculateRepetitionRate(suggestion: string, previousSuggestions: string[]): number {
  if (previousSuggestions.length === 0) return 0.0;

  const suggestionBigrams = getBigrams(suggestion.toLowerCase());
  let maxSimilarity = 0.0;

  for (const prevSuggestion of previousSuggestions) {
    const prevBigrams = getBigrams(prevSuggestion.toLowerCase());
    const similarity = jaccardSimilarity(suggestionBigrams, prevBigrams);
    if (similarity > maxSimilarity) {
      maxSimilarity = similarity;
    }
  }

  return maxSimilarity;
}

function getBigrams(text: string): Set<string> {
  const bigrams = new Set<string>();
  const words = text.split(/\s+/);

  for (const word of words) {
    if (word.length >= 2) {
      for (let i = 0; i < word.length - 1; i++) {
        bigrams.add(word.substring(i, i + 2));
      }
    }
  }

  return bigrams;
}

function jaccardSimilarity(set1: Set<string>, set2: Set<string>): number {
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  const union = new Set([...set1, ...set2]);

  return intersection.size / union.size;
}

// Executar testes se arquivo for chamado diretamente
if (import.meta.main) {
  await runCriticalFeaturesTest();
}
