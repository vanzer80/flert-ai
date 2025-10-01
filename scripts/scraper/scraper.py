"""
=====================================================
CULTURAL REFERENCES SCRAPER
=====================================================
Description: Web scraper para coletar referências culturais brasileiras
             e popular o banco de dados do FlertAI
Author: FlertAI Team
Date: 2025-10-01

Features:
- Web scraping de múltiplas fontes
- Limpeza e validação de dados
- Inserção no Supabase
- Retry logic e error handling
- Logging detalhado
=====================================================
"""

import os
import re
import json
import time
import logging
from typing import List, Dict, Optional
from datetime import datetime

import requests
from bs4 import BeautifulSoup
from fake_useragent import UserAgent
from retry import retry
from tqdm import tqdm
from dotenv import load_dotenv
from supabase import create_client, Client

# =====================================================
# CONFIGURATION
# =====================================================

# Load environment variables
load_dotenv()

# Supabase Configuration
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')

# Scraping Configuration
MAX_RETRIES = int(os.getenv('MAX_RETRIES', 3))
TIMEOUT_SECONDS = int(os.getenv('TIMEOUT_SECONDS', 30))
DELAY_BETWEEN_REQUESTS = float(os.getenv('DELAY_BETWEEN_REQUESTS', 2))

# Data Quality
MIN_TERM_LENGTH = int(os.getenv('MIN_TERM_LENGTH', 3))
MAX_TERM_LENGTH = int(os.getenv('MAX_TERM_LENGTH', 100))
MIN_MEANING_LENGTH = int(os.getenv('MIN_MEANING_LENGTH', 10))
MAX_MEANING_LENGTH = int(os.getenv('MAX_MEANING_LENGTH', 500))

# Batch Processing
BATCH_SIZE = int(os.getenv('BATCH_SIZE', 50))
MAX_TOTAL_RECORDS = int(os.getenv('MAX_TOTAL_RECORDS', 1000))

# Logging Configuration
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
LOG_FILE = os.getenv('LOG_FILE', 'scraper.log')

# Setup logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# User agent for requests
ua = UserAgent()

# =====================================================
# DATABASE CLIENT
# =====================================================

class SupabaseClient:
    """Cliente Supabase para inserção de dados"""
    
    def __init__(self):
        if not SUPABASE_URL or not SUPABASE_KEY:
            raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set in environment")
        
        self.client: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        logger.info("Supabase client initialized successfully")
    
    def insert_cultural_reference(self, data: Dict) -> bool:
        """
        Insere uma referência cultural no banco de dados
        
        Args:
            data: Dicionário com os dados da referência
        
        Returns:
            bool: True se inserção foi bem-sucedida
        """
        try:
            result = self.client.table('cultural_references').insert(data).execute()
            logger.debug(f"Inserted: {data['termo']}")
            return True
        except Exception as e:
            logger.error(f"Error inserting {data.get('termo', 'unknown')}: {e}")
            return False
    
    def insert_batch(self, data_list: List[Dict]) -> int:
        """
        Insere múltiplas referências em batch
        
        Args:
            data_list: Lista de dicionários com dados
        
        Returns:
            int: Número de inserções bem-sucedidas
        """
        success_count = 0
        try:
            result = self.client.table('cultural_references').insert(data_list).execute()
            success_count = len(data_list)
            logger.info(f"Batch inserted: {success_count} records")
        except Exception as e:
            logger.error(f"Batch insert failed, trying individual inserts: {e}")
            # Fallback: tentar inserir individualmente
            for data in data_list:
                if self.insert_cultural_reference(data):
                    success_count += 1
        
        return success_count
    
    def check_exists(self, termo: str) -> bool:
        """
        Verifica se um termo já existe no banco
        
        Args:
            termo: Termo a verificar
        
        Returns:
            bool: True se termo já existe
        """
        try:
            result = self.client.table('cultural_references').select('id').eq('termo', termo).execute()
            return len(result.data) > 0
        except Exception as e:
            logger.error(f"Error checking existence of {termo}: {e}")
            return False

# =====================================================
# DATA VALIDATION AND CLEANING
# =====================================================

class DataCleaner:
    """Limpeza e validação de dados coletados"""
    
    @staticmethod
    def clean_text(text: str) -> str:
        """Remove espaços extras e normaliza texto"""
        if not text:
            return ""
        text = re.sub(r'\s+', ' ', text.strip())
        text = text.replace('\n', ' ').replace('\r', '')
        return text
    
    @staticmethod
    def validate_term(termo: str) -> bool:
        """Valida se o termo atende aos critérios"""
        if not termo:
            return False
        termo_clean = DataCleaner.clean_text(termo)
        length = len(termo_clean)
        return MIN_TERM_LENGTH <= length <= MAX_TERM_LENGTH
    
    @staticmethod
    def validate_meaning(significado: str) -> bool:
        """Valida se o significado atende aos critérios"""
        if not significado:
            return False
        sig_clean = DataCleaner.clean_text(significado)
        length = len(sig_clean)
        return MIN_MEANING_LENGTH <= length <= MAX_MEANING_LENGTH
    
    @staticmethod
    def normalize_type(tipo: str) -> str:
        """Normaliza o tipo para valores válidos"""
        tipo_lower = tipo.lower()
        valid_types = [
            'giria', 'meme', 'novela', 'musica', 'personalidade',
            'evento', 'expressao_regional', 'filme', 'serie',
            'esporte', 'comida', 'lugar'
        ]
        
        # Mapeamento de sinônimos
        type_map = {
            'gíria': 'giria',
            'música': 'musica',
            'série': 'serie',
            'expressão': 'expressao_regional',
            'regional': 'expressao_regional',
        }
        
        tipo_normalized = type_map.get(tipo_lower, tipo_lower)
        return tipo_normalized if tipo_normalized in valid_types else 'giria'
    
    @staticmethod
    def normalize_region(regiao: str) -> str:
        """Normaliza a região para valores válidos"""
        regiao_lower = regiao.lower() if regiao else 'nacional'
        valid_regions = ['nacional', 'norte', 'nordeste', 'centro-oeste', 'sudeste', 'sul']
        return regiao_lower if regiao_lower in valid_regions else 'nacional'
    
    @staticmethod
    def validate_and_clean(data: Dict) -> Optional[Dict]:
        """
        Valida e limpa um registro completo
        
        Args:
            data: Dicionário com dados brutos
        
        Returns:
            Optional[Dict]: Dados limpos ou None se inválido
        """
        # Campos obrigatórios
        if not all(k in data for k in ['termo', 'tipo', 'significado']):
            return None
        
        # Limpeza
        termo = DataCleaner.clean_text(data['termo'])
        significado = DataCleaner.clean_text(data['significado'])
        
        # Validação
        if not DataCleaner.validate_term(termo):
            return None
        if not DataCleaner.validate_meaning(significado):
            return None
        
        # Construir dados limpos
        clean_data = {
            'termo': termo,
            'tipo': DataCleaner.normalize_type(data['tipo']),
            'significado': significado,
            'exemplo_uso': DataCleaner.clean_text(data.get('exemplo_uso', '')),
            'regiao': DataCleaner.normalize_region(data.get('regiao', 'nacional')),
            'contexto_flerte': DataCleaner.clean_text(data.get('contexto_flerte', ''))
        }
        
        return clean_data

# =====================================================
# WEB SCRAPERS
# =====================================================

class BaseScraper:
    """Classe base para scrapers"""
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': ua.random})
    
    @retry(tries=MAX_RETRIES, delay=2, backoff=2)
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """
        Faz request e retorna BeautifulSoup
        
        Args:
            url: URL a fazer scraping
        
        Returns:
            Optional[BeautifulSoup]: Objeto parsed ou None
        """
        try:
            logger.debug(f"Fetching: {url}")
            response = self.session.get(url, timeout=TIMEOUT_SECONDS)
            response.raise_for_status()
            response.encoding = 'utf-8'
            time.sleep(DELAY_BETWEEN_REQUESTS)
            return BeautifulSoup(response.text, 'html.parser')
        except Exception as e:
            logger.error(f"Error fetching {url}: {e}")
            return None


class GiriasScraper(BaseScraper):
    """Scraper para sites de gírias brasileiras"""
    
    def scrape_dicionario_informal(self) -> List[Dict]:
        """
        Scraper de exemplo: Dicionário Informal
        NOTA: Este é um exemplo simplificado. Adaptar conforme site real.
        """
        logger.info("Starting Dicionário Informal scraper")
        references = []
        
        # Lista de páginas de exemplo (adaptar conforme site real)
        base_url = "https://www.dicionarioinformal.com.br"
        # IMPORTANTE: Verificar robots.txt e termos de uso antes de fazer scraping!
        
        # Para exemplo, vou gerar dados mock
        # Em produção, implementar scraping real
        logger.warning("Using mock data for demonstration. Implement real scraping!")
        
        mock_data = self._generate_mock_girias()
        references.extend(mock_data)
        
        logger.info(f"Dicionário Informal: collected {len(references)} references")
        return references
    
    def _generate_mock_girias(self) -> List[Dict]:
        """Gera dados mock para demonstração"""
        return [
            {
                'termo': 'Tá ligado',
                'tipo': 'giria',
                'significado': 'Expressão para verificar entendimento ou concordância',
                'exemplo_uso': 'Gostei do seu perfil, tá ligado?',
                'regiao': 'sudeste',
                'contexto_flerte': 'Casual, confirma interesse'
            },
            {
                'termo': 'Maneiro',
                'tipo': 'giria',
                'significado': 'Legal, bacana, interessante',
                'exemplo_uso': 'Achei seu perfil maneiro demais!',
                'regiao': 'nacional',
                'contexto_flerte': 'Elogio casual'
            },
            {
                'termo': 'Bagulho doido',
                'tipo': 'giria',
                'significado': 'Algo impressionante, surpreendente',
                'exemplo_uso': 'Seu sorriso é um bagulho doido!',
                'regiao': 'sudeste',
                'contexto_flerte': 'Elogio criativo'
            },
        ]


class MemesScraper(BaseScraper):
    """Scraper para memes e referências da internet brasileira"""
    
    def scrape_know_your_meme_br(self) -> List[Dict]:
        """
        Scraper de exemplo: Memes brasileiros
        """
        logger.info("Starting Memes scraper")
        references = []
        
        # Implementação mock
        logger.warning("Using mock data for demonstration")
        mock_data = self._generate_mock_memes()
        references.extend(mock_data)
        
        logger.info(f"Memes: collected {len(references)} references")
        return references
    
    def _generate_mock_memes(self) -> List[Dict]:
        """Gera dados mock de memes"""
        return [
            {
                'termo': 'Stonks',
                'tipo': 'meme',
                'significado': 'Meme sobre investimentos bons (ou ruins de forma irônica)',
                'exemplo_uso': 'Match com você foi total stonks!',
                'regiao': 'nacional',
                'contexto_flerte': 'Humor moderno, indica lucro/ganho'
            },
            {
                'termo': 'F no chat',
                'tipo': 'meme',
                'significado': 'Expressar condolências ou respeito de forma humorística',
                'exemplo_uso': 'F no chat pros que não deram match comigo',
                'regiao': 'nacional',
                'contexto_flerte': 'Humor autodepreciativo leve'
            },
        ]


class CulturalReferencesScraper(BaseScraper):
    """Scraper para referências culturais brasileiras (novelas, músicas, etc)"""
    
    def scrape_cultural_references(self) -> List[Dict]:
        """Coleta referências culturais diversas"""
        logger.info("Starting Cultural References scraper")
        references = []
        
        # Mock data
        logger.warning("Using mock data for demonstration")
        mock_data = self._generate_mock_cultural()
        references.extend(mock_data)
        
        logger.info(f"Cultural: collected {len(references)} references")
        return references
    
    def _generate_mock_cultural(self) -> List[Dict]:
        """Gera dados mock de cultura brasileira"""
        return [
            {
                'termo': 'Evidências',
                'tipo': 'musica',
                'significado': 'Música romântica icônica de Chitãozinho e Xororó',
                'exemplo_uso': 'Tipo Evidências: quando vejo você, eu me rendo',
                'regiao': 'nacional',
                'contexto_flerte': 'Romântico, referência nostálgica'
            },
            {
                'termo': 'Avenida Brasil',
                'tipo': 'novela',
                'significado': 'Novela icônica da Globo, drama e reviravoltas',
                'exemplo_uso': 'Essa conversa tá melhor que Avenida Brasil!',
                'regiao': 'nacional',
                'contexto_flerte': 'Humorístico, comparação empolgante'
            },
            {
                'termo': 'Feijoada',
                'tipo': 'comida',
                'significado': 'Prato típico brasileiro, símbolo de encontro familiar',
                'exemplo_uso': 'Bora marcar uma feijoada pra gente se conhecer melhor?',
                'regiao': 'nacional',
                'contexto_flerte': 'Convite casual e acolhedor'
            },
        ]

# =====================================================
# ORCHESTRATOR
# =====================================================

class ScraperOrchestrator:
    """Orquestra todos os scrapers e inserção no banco"""
    
    def __init__(self):
        self.db_client = SupabaseClient()
        self.scrapers = [
            GiriasScraper(),
            MemesScraper(),
            CulturalReferencesScraper()
        ]
        self.collected_data = []
        self.inserted_count = 0
        self.skipped_count = 0
    
    def run_all_scrapers(self) -> List[Dict]:
        """Executa todos os scrapers"""
        logger.info("Starting all scrapers...")
        all_references = []
        
        for scraper in self.scrapers:
            try:
                if isinstance(scraper, GiriasScraper):
                    refs = scraper.scrape_dicionario_informal()
                elif isinstance(scraper, MemesScraper):
                    refs = scraper.scrape_know_your_meme_br()
                elif isinstance(scraper, CulturalReferencesScraper):
                    refs = scraper.scrape_cultural_references()
                else:
                    refs = []
                
                all_references.extend(refs)
            except Exception as e:
                logger.error(f"Scraper {scraper.__class__.__name__} failed: {e}")
        
        logger.info(f"Total references collected: {len(all_references)}")
        return all_references
    
    def clean_and_validate_data(self, raw_data: List[Dict]) -> List[Dict]:
        """Limpa e valida todos os dados coletados"""
        logger.info("Cleaning and validating data...")
        cleaned_data = []
        
        for data in tqdm(raw_data, desc="Validating"):
            clean = DataCleaner.validate_and_clean(data)
            if clean:
                # Verificar se já existe
                if not self.db_client.check_exists(clean['termo']):
                    cleaned_data.append(clean)
                else:
                    logger.debug(f"Termo já existe: {clean['termo']}")
                    self.skipped_count += 1
        
        logger.info(f"Valid references: {len(cleaned_data)}")
        logger.info(f"Skipped (duplicates): {self.skipped_count}")
        return cleaned_data
    
    def insert_to_database(self, data_list: List[Dict]) -> int:
        """Insere dados no banco em batches"""
        logger.info("Inserting data into database...")
        total_inserted = 0
        
        # Limitar ao MAX_TOTAL_RECORDS
        data_to_insert = data_list[:MAX_TOTAL_RECORDS]
        
        # Processar em batches
        for i in tqdm(range(0, len(data_to_insert), BATCH_SIZE), desc="Inserting"):
            batch = data_to_insert[i:i+BATCH_SIZE]
            count = self.db_client.insert_batch(batch)
            total_inserted += count
            time.sleep(1)  # Rate limiting
        
        logger.info(f"Total inserted: {total_inserted}")
        return total_inserted
    
    def run_full_pipeline(self):
        """Executa pipeline completo"""
        logger.info("="*50)
        logger.info("STARTING CULTURAL REFERENCES SCRAPER")
        logger.info("="*50)
        
        start_time = time.time()
        
        # 1. Coletar dados
        raw_data = self.run_all_scrapers()
        
        # 2. Limpar e validar
        clean_data = self.clean_and_validate_data(raw_data)
        
        # 3. Inserir no banco
        self.inserted_count = self.insert_to_database(clean_data)
        
        # Estatísticas finais
        elapsed = time.time() - start_time
        logger.info("="*50)
        logger.info("SCRAPING COMPLETED")
        logger.info(f"Time elapsed: {elapsed:.2f}s")
        logger.info(f"Total collected: {len(raw_data)}")
        logger.info(f"Total validated: {len(clean_data)}")
        logger.info(f"Total inserted: {self.inserted_count}")
        logger.info(f"Total skipped: {self.skipped_count}")
        logger.info("="*50)

# =====================================================
# MAIN ENTRY POINT
# =====================================================

def main():
    """Função principal"""
    try:
        orchestrator = ScraperOrchestrator()
        orchestrator.run_full_pipeline()
    except KeyboardInterrupt:
        logger.warning("Scraping interrupted by user")
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        raise


if __name__ == "__main__":
    main()
