"""
=====================================================
SCRIPT DE EXECUÇÃO PÓS-CONFIGURAÇÃO
=====================================================
Execute este script APÓS configurar o .env com a Service Role Key válida
"""

import os
import sys
from dotenv import load_dotenv

print("="*70)
print("SCRIPT DE VERIFICAÇÃO E EXECUÇÃO")
print("="*70)
print()

# Carregar .env
load_dotenv()

# Verificar variáveis
supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')

print("1. Verificando configuração do .env...")
print()

if not supabase_url:
    print("  ✗ SUPABASE_URL não configurado")
    sys.exit(1)
else:
    print(f"  ✓ SUPABASE_URL: {supabase_url}")

if not supabase_key or supabase_key == 'COLOQUE_SUA_SERVICE_ROLE_KEY_AQUI':
    print("  ✗ SUPABASE_KEY inválido ou não configurado")
    print()
    print("⚠️  AÇÃO NECESSÁRIA:")
    print()
    print("1. Abra: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api")
    print("2. Copie a chave 'service_role' (secret)")
    print("3. Cole no arquivo .env na linha SUPABASE_KEY=")
    print("4. Execute este script novamente")
    print()
    sys.exit(1)
else:
    key_preview = supabase_key[:20] + "..." + supabase_key[-10:] if len(supabase_key) > 30 else "***"
    print(f"  ✓ SUPABASE_KEY: {key_preview}")

print()
print("2. Testando conexão com Supabase...")
print()

try:
    from supabase import create_client
    
    client = create_client(supabase_url, supabase_key)
    
    # Testar se tabela existe
    result = client.table('cultural_references').select('id').limit(1).execute()
    
    print("  ✓ Conexão estabelecida com sucesso!")
    print(f"  ✓ Tabela 'cultural_references' existe")
    print(f"  ✓ Registros atuais: {len(result.data) if result.data else 0}")
    
except Exception as e:
    error_msg = str(e)
    print(f"  ✗ Erro ao conectar: {error_msg}")
    print()
    
    if "relation" in error_msg.lower() and "does not exist" in error_msg.lower():
        print("⚠️  A tabela 'cultural_references' NÃO EXISTE!")
        print()
        print("AÇÃO NECESSÁRIA:")
        print()
        print("1. Abra: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf")
        print("2. Vá para: SQL Editor → New query")
        print("3. Copie TODO o conteúdo de:")
        print("   supabase/migrations/20251001_create_cultural_references.sql")
        print("4. Cole no SQL Editor e clique em 'Run'")
        print("5. Execute este script novamente")
        print()
    elif "401" in error_msg or "unauthorized" in error_msg.lower():
        print("⚠️  Chave de API inválida!")
        print()
        print("Verifique se você copiou a chave 'service_role' (não 'anon')")
        print()
    
    sys.exit(1)

print()
print("3. Carregando seed data...")
print()

try:
    from seed_data import get_seed_data
    
    seed_data = get_seed_data()
    print(f"  ✓ {len(seed_data)} referências carregadas")
    
    # Estatísticas
    from collections import Counter
    tipos = Counter([d['tipo'] for d in seed_data])
    regioes = Counter([d['regiao'] for d in seed_data])
    
    print()
    print("  Por tipo:")
    for tipo, count in tipos.most_common(5):
        print(f"    - {tipo}: {count}")
    
    print()
    print("  Por região:")
    for regiao, count in regioes.most_common(3):
        print(f"    - {regiao}: {count}")
    
except Exception as e:
    print(f"  ✗ Erro ao carregar seed data: {e}")
    sys.exit(1)

print()
print("4. Verificando registros existentes...")
print()

try:
    existing = client.table('cultural_references').select('termo').execute()
    existing_terms = {row['termo'] for row in existing.data}
    
    print(f"  ✓ {len(existing_terms)} termos já existem no banco")
    
    # Filtrar novos
    new_data = [d for d in seed_data if d['termo'] not in existing_terms]
    
    if len(new_data) == 0:
        print()
        print("✅ TODOS OS DADOS JÁ FORAM INSERIDOS!")
        print()
        print(f"Total no banco: {len(existing_terms)} referências culturais")
        print()
        print("Próximos passos:")
        print("1. Expandir seed_data.py para 1000+ refs")
        print("2. Integrar com Edge Function (docs/INTEGRACAO_CULTURAL_REFERENCES.md)")
        print("3. Testar no app!")
        print()
        sys.exit(0)
    
    print(f"  ✓ {len(new_data)} novos termos para inserir")
    
except Exception as e:
    print(f"  ✗ Erro ao verificar existentes: {e}")
    sys.exit(1)

print()
print("5. Deseja inserir os dados? (s/n): ", end='')
resposta = input().strip().lower()

if resposta != 's':
    print()
    print("Operação cancelada pelo usuário.")
    print()
    sys.exit(0)

print()
print("6. Inserindo dados no Supabase...")
print()

try:
    from tqdm import tqdm
    
    BATCH_SIZE = 50
    inserted_count = 0
    error_count = 0
    
    for i in tqdm(range(0, len(new_data), BATCH_SIZE), desc="Inserindo"):
        batch = new_data[i:i+BATCH_SIZE]
        
        try:
            result = client.table('cultural_references').insert(batch).execute()
            inserted_count += len(batch)
        except Exception as e:
            print(f"\n  ⚠️  Erro no batch {i//BATCH_SIZE + 1}: {e}")
            # Tentar individual
            for item in batch:
                try:
                    client.table('cultural_references').insert(item).execute()
                    inserted_count += 1
                except:
                    error_count += 1
    
    print()
    print("="*70)
    print("INSERÇÃO CONCLUÍDA!")
    print("="*70)
    print()
    print(f"✓ Registros inseridos: {inserted_count}")
    print(f"✓ Total no banco: {len(existing_terms) + inserted_count}")
    if error_count > 0:
        print(f"⚠️  Erros: {error_count}")
    print()
    print("Próximos passos:")
    print("1. Verificar dados no Supabase Dashboard")
    print("2. Expandir para 1000+ referências (editar seed_data.py)")
    print("3. Integrar com Edge Function")
    print()
    
except Exception as e:
    print(f"  ✗ Erro durante inserção: {e}")
    sys.exit(1)

print("="*70)
print("SETUP COMPLETO! 🎉")
print("="*70)
