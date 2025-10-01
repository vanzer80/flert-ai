"""
Script para verificar o setup do ambiente
"""
import sys

print("="*60)
print("VERIFICAÇÃO DO AMBIENTE")
print("="*60)
print()

print(f"✓ Python: {sys.version}")
print()

# Verificar módulos necessários
modules_to_check = [
    'supabase',
    'requests',
    'bs4',
    'dotenv',
    'pandas',
    'tqdm'
]

print("Verificando dependências:")
missing = []
for module in modules_to_check:
    try:
        __import__(module)
        print(f"  ✓ {module}")
    except ImportError:
        print(f"  ✗ {module} - NÃO INSTALADO")
        missing.append(module)

print()

if missing:
    print("⚠️ DEPENDÊNCIAS FALTANDO:")
    print()
    print("Execute:")
    print("  pip install -r requirements.txt")
    print()
else:
    print("✅ Todas as dependências instaladas!")
    print()

# Verificar .env
import os
env_file = '.env'
if os.path.exists(env_file):
    print(f"✓ Arquivo {env_file} existe")
    
    # Verificar variáveis
    from dotenv import load_dotenv
    load_dotenv()
    
    supabase_url = os.getenv('SUPABASE_URL')
    supabase_key = os.getenv('SUPABASE_KEY')
    
    if supabase_url:
        print(f"  ✓ SUPABASE_URL configurado")
    else:
        print(f"  ✗ SUPABASE_URL não configurado")
    
    if supabase_key and len(supabase_key) > 20:
        print(f"  ✓ SUPABASE_KEY configurado")
    else:
        print(f"  ✗ SUPABASE_KEY não configurado ou inválido")
else:
    print(f"✗ Arquivo {env_file} NÃO existe")
    print()
    print("Execute:")
    print("  copy .env.example .env")
    print("  notepad .env  # Configure as variáveis")

print()
print("="*60)
