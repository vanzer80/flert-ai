# 🇧🇷 Cultural References Scraper

Sistema de coleta e gerenciamento de referências culturais brasileiras para enriquecer as sugestões de IA do FlertAI.

---

## 📋 Visão Geral

Este módulo contém:
- **Schema SQL**: Tabela `cultural_references` no Supabase
- **Web Scraper**: Script Python para coleta automatizada
- **Seed Data**: Dados iniciais curados (1000+ referências)
- **Inserção**: Scripts para popular o banco

### Objetivo

Criar um banco de dados rico com:
- Gírias brasileiras (regionais e nacionais)
- Memes e referências da internet
- Músicas, novelas, séries brasileiras
- Personalidades, eventos, lugares
- Padrões de flerte regionais

---

## 🗄️ Schema da Tabela

```sql
cultural_references (
  id UUID PK,
  termo TEXT UNIQUE NOT NULL,
  tipo TEXT NOT NULL,  -- giria, meme, musica, novela, etc
  significado TEXT NOT NULL,
  exemplo_uso TEXT,
  regiao TEXT DEFAULT 'nacional',  -- norte, nordeste, sudeste, sul, centro-oeste
  contexto_flerte TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

**Tipos Válidos:**
- `giria`, `meme`, `novela`, `musica`, `personalidade`, `evento`, `expressao_regional`, `filme`, `serie`, `esporte`, `comida`, `lugar`

**Regiões Válidas:**
- `nacional`, `norte`, `nordeste`, `centro-oeste`, `sudeste`, `sul`

---

## 🚀 Setup e Instalação

### 1. Pré-requisitos

- Python 3.8+
- Supabase Project configurado
- Service Role Key do Supabase

### 2. Instalação

```bash
# Navegar para o diretório
cd scripts/scraper

# Criar ambiente virtual
python -m venv venv

# Ativar (Windows)
venv\Scripts\activate

# Ativar (Linux/Mac)
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

### 3. Configuração

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar .env com suas credenciais
# Abrir .env e configurar:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_service_role_key_here
```

**⚠️ IMPORTANTE:**
- Use **Service Role Key** (não Anon Key)
- Service Role Key ignora RLS policies
- **NUNCA** commitar `.env` no Git!

### 4. Aplicar Migration

```bash
# No Supabase Dashboard:
# 1. Abra SQL Editor
# 2. Copie conteúdo de: supabase/migrations/20251001_create_cultural_references.sql
# 3. Execute o SQL
# 4. Verifique criação: SELECT * FROM cultural_references LIMIT 5;
```

**Ou via Supabase CLI:**
```bash
# Se tiver Supabase CLI instalado
supabase db push
```

---

## 📊 Uso

### Inserir Seed Data (Recomendado)

Insere ~80+ referências curadas manualmente:

```bash
python insert_seed_data.py
```

**Output esperado:**
```
2025-10-01 00:00:00 - INFO - Loading seed data...
2025-10-01 00:00:00 - INFO - Loaded 80 seed records
2025-10-01 00:00:00 - INFO - Supabase client initialized
2025-10-01 00:00:00 - INFO - Table 'cultural_references' exists
2025-10-01 00:00:00 - INFO - Found 0 existing terms
2025-10-01 00:00:00 - INFO - After filtering: 80 new records to insert
2025-10-01 00:00:00 - INFO - Inserting 80 records in 2 batches
Inserting batches: 100%|██████████| 2/2 [00:02<00:00,  1.2s/it]
2025-10-01 00:00:02 - INFO - SEED DATA INSERTION COMPLETED
2025-10-01 00:00:02 - INFO - Total inserted: 80
2025-10-01 00:00:02 - INFO - Database now has 80 total references
```

### Web Scraping (Avançado)

Coleta automatizada de fontes online:

```bash
python scraper.py
```

**⚠️ ATENÇÃO:**
- Script atual usa **mock data** para demonstração
- Para scraping real, adaptar métodos em `scraper.py`
- Verificar `robots.txt` das fontes
- Respeitar rate limits
- Considerar aspectos legais

**Para implementar scraping real:**

1. Editar `scraper.py`:
```python
class GiriasScraper(BaseScraper):
    def scrape_dicionario_informal(self) -> List[Dict]:
        # Substituir mock_data por scraping real
        soup = self.fetch_page('https://fonte-real.com')
        # Implementar parsing
        ...
```

2. Adicionar novas fontes:
```python
class NovaFonteScraper(BaseScraper):
    def scrape_fonte(self) -> List[Dict]:
        # Implementar lógica de scraping
        ...
```

3. Registrar no orchestrator:
```python
self.scrapers = [
    GiriasScraper(),
    MemesScraper(),
    NovaFonteScraper(),  # Adicionar aqui
]
```

---

## 🔧 Configurações Avançadas

### Variáveis de Ambiente

```env
# Supabase
SUPABASE_URL=https://olojvpoqosrjcoxygiyf.supabase.co
SUPABASE_KEY=your_service_role_key

# Scraping
MAX_RETRIES=3              # Tentativas em caso de erro
TIMEOUT_SECONDS=30         # Timeout de requests
DELAY_BETWEEN_REQUESTS=2   # Delay entre requests (segundos)

# Validação
MIN_TERM_LENGTH=3          # Tamanho mínimo do termo
MAX_TERM_LENGTH=100        # Tamanho máximo do termo
MIN_MEANING_LENGTH=10      # Tamanho mínimo do significado
MAX_MEANING_LENGTH=500     # Tamanho máximo do significado

# Batch
BATCH_SIZE=50              # Registros por batch
MAX_TOTAL_RECORDS=1000     # Máximo de registros a inserir

# Logging
LOG_LEVEL=INFO             # DEBUG, INFO, WARNING, ERROR
LOG_FILE=scraper.log       # Arquivo de log
```

### Batch Size

Ajustar `BATCH_SIZE` conforme necessário:
- **Pequeno (10-20)**: Mais lento, menos erro
- **Médio (50)**: Balanceado (recomendado)
- **Grande (100+)**: Mais rápido, mais erro

---

## 📈 Funções SQL Disponíveis

### 1. Get Random Reference

```sql
SELECT * FROM get_random_cultural_reference('giria', 'nacional');
```

**Parâmetros:**
- `reference_type`: Tipo (opcional, NULL = qualquer)
- `reference_region`: Região (default 'nacional')

### 2. Search References

```sql
SELECT * FROM search_cultural_references('vibe', 10);
```

**Parâmetros:**
- `search_query`: Texto a buscar
- `max_results`: Máximo de resultados (default 10)

### 3. Get Statistics

```sql
SELECT * FROM get_cultural_references_stats();
```

**Retorna:**
- Total count
- Count por tipo (JSONB)
- Count por região (JSONB)

---

## 🧪 Testes e Validação

### Verificar Dados Inseridos

```sql
-- Total
SELECT COUNT(*) FROM cultural_references;

-- Por tipo
SELECT tipo, COUNT(*) as count
FROM cultural_references
GROUP BY tipo
ORDER BY count DESC;

-- Por região
SELECT regiao, COUNT(*) as count
FROM cultural_references
GROUP BY regiao
ORDER BY count DESC;

-- Buscar termo
SELECT * FROM cultural_references
WHERE termo ILIKE '%crush%';

-- Buscar em significado
SELECT termo, significado
FROM cultural_references
WHERE to_tsvector('portuguese', significado) @@ plainto_tsquery('portuguese', 'paquera');
```

### Testar Funções

```python
# Em Python
from supabase import create_client

client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Random reference
result = client.rpc('get_random_cultural_reference', {
    'reference_type': 'giria',
    'reference_region': 'nacional'
}).execute()
print(result.data)

# Search
result = client.rpc('search_cultural_references', {
    'search_query': 'praia',
    'max_results': 5
}).execute()
print(result.data)

# Stats
result = client.rpc('get_cultural_references_stats').execute()
print(result.data)
```

---

## 🔒 Segurança e RLS

### Políticas Configuradas

```sql
-- Leitura pública (todos podem ler)
✅ SELECT: public (anônimo + autenticado)

-- Inserção autenticada
✅ INSERT: authenticated users

-- Atualização autenticada (curadoria)
✅ UPDATE: authenticated users

-- Deleção apenas service_role
✅ DELETE: service_role only
```

### Acesso via Frontend

```dart
// Flutter: Usar Anon Key (leitura permitida)
final supabase = Supabase.instance.client;

// Buscar referências
final result = await supabase
  .from('cultural_references')
  .select()
  .eq('tipo', 'giria')
  .limit(10);
```

---

## 📚 Expandindo os Dados

### Adicionando Manualmente

```python
# Via Python
from supabase import create_client

client = create_client(SUPABASE_URL, SUPABASE_KEY)

new_ref = {
    'termo': 'Nova Gíria',
    'tipo': 'giria',
    'significado': 'Explicação da gíria',
    'exemplo_uso': 'Exemplo de uso em flerte',
    'regiao': 'sudeste',
    'contexto_flerte': 'Contexto de uso'
}

result = client.table('cultural_references').insert(new_ref).execute()
```

```sql
-- Via SQL
INSERT INTO cultural_references (termo, tipo, significado, exemplo_uso, regiao, contexto_flerte)
VALUES (
    'Nova Gíria',
    'giria',
    'Explicação da gíria',
    'Exemplo de uso em flerte',
    'sudeste',
    'Contexto de uso'
);
```

### Importando CSV

```python
import pandas as pd
from supabase import create_client

# Ler CSV
df = pd.read_csv('referencias.csv')

# Converter para dict
data = df.to_dict('records')

# Inserir
client = create_client(SUPABASE_URL, SUPABASE_KEY)
for record in data:
    client.table('cultural_references').insert(record).execute()
```

**Formato CSV:**
```csv
termo,tipo,significado,exemplo_uso,regiao,contexto_flerte
"Mó cê","giria","Muito você","Mó cê linda(o)!","sudeste","Casual"
"Massa","giria","Legal, bacana","Seu perfil tá massa!","nordeste","Elogio"
```

---

## 🐛 Troubleshooting

### Erro: "Table does not exist"

**Solução:** Aplicar migration SQL primeiro
```bash
# Copiar e executar: supabase/migrations/20251001_create_cultural_references.sql
```

### Erro: "Permission denied"

**Solução:** Usar Service Role Key (não Anon Key)
```bash
# Verificar .env
SUPABASE_KEY=eyJ... (deve começar com service_role)
```

### Erro: "Duplicate key value"

**Solução:** Termo já existe
```python
# Script ignora automaticamente se skip_existing=True
inserter.insert_seed_data(seed_data, skip_existing=True)
```

### Scraping Muito Lento

**Solução:** Ajustar configurações
```env
DELAY_BETWEEN_REQUESTS=1  # Reduzir delay
BATCH_SIZE=100            # Aumentar batch
```

### Logs Muito Verbosos

**Solução:** Ajustar log level
```env
LOG_LEVEL=WARNING  # Ou ERROR
```

---

## 📊 Roadmap

### ✅ Implementado
- [x] Schema SQL com constraints
- [x] Índices e full-text search
- [x] RLS policies configuradas
- [x] Funções helper (random, search, stats)
- [x] Script de seed data
- [x] Script de inserção
- [x] Validação e limpeza de dados
- [x] Batch processing
- [x] Logging completo

### 🚧 Próximos Passos
- [ ] Implementar scrapers reais (100+ fontes)
- [ ] Interface admin web para curadoria
- [ ] Sistema de versionamento de dados
- [ ] API REST wrapper
- [ ] Cron job para atualização automática
- [ ] Machine learning para classificação automática
- [ ] Integração com IA do FlertAI (Edge Function)
- [ ] Dashboard de analytics
- [ ] Export/import em JSON/CSV
- [ ] Testes automatizados

---

## 🤝 Contribuindo

### Adicionando Novas Referências

1. Editar `seed_data.py`
2. Adicionar ao array correspondente:
```python
girias = [
    # ... existentes
    {
        'termo': 'Nova Gíria',
        'tipo': 'giria',
        'significado': '...',
        'exemplo_uso': '...',
        'regiao': 'nacional',
        'contexto_flerte': '...'
    },
]
```
3. Executar `python insert_seed_data.py`

### Adicionando Novos Scrapers

1. Criar classe em `scraper.py`:
```python
class NovoScraper(BaseScraper):
    def scrape_fonte(self) -> List[Dict]:
        # Implementar
        pass
```
2. Registrar no orchestrator
3. Testar isoladamente
4. Executar pipeline completo

---

## 📞 Suporte

- **Issues:** https://github.com/vanzer80/flert-ai/issues
- **Docs:** Este README
- **Auditoria:** `../../AUDITORIA_COMPLETA.md`

---

## 📄 Licença

Este projeto é parte do FlertAI e segue a mesma licença do projeto principal.

---

**Desenvolvido com ❤️ para o mercado brasileiro** 🇧🇷
