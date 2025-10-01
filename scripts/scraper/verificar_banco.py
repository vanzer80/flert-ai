from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

try:
    client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))

    # Verificar total
    result = client.table('cultural_references').select('id', count='exact').execute()
    total = result.count if hasattr(result, 'count') else len(result.data)

    print(f'Total de registros no banco: {total}')

    # Ver amostra
    sample = client.table('cultural_references').select('termo, tipo, regiao').limit(5).execute()
    print('Amostra de dados:')
    for item in sample.data:
        print(f'  - {item["termo"]} ({item["tipo"]}) - {item["regiao"]}')

except Exception as e:
    print(f'Erro: {e}')
