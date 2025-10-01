"""
=====================================================
INSERT SEED DATA
=====================================================
Description: Script para inserir dados iniciais (seed) no Supabase
Author: FlertAI Team
Date: 2025-10-01
=====================================================
"""

import os
import sys
import time
import logging
from typing import List, Dict
from dotenv import load_dotenv
from supabase import create_client, Client
from tqdm import tqdm

# Import seed data
from seed_data import get_seed_data

# =====================================================
# CONFIGURATION
# =====================================================

load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')
BATCH_SIZE = int(os.getenv('BATCH_SIZE', 50))

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('seed_insert.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# =====================================================
# DATABASE CLIENT
# =====================================================

class SeedInserter:
    """Classe para inserir seed data no Supabase"""
    
    def __init__(self):
        if not SUPABASE_URL or not SUPABASE_KEY:
            raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set")
        
        self.client: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        logger.info("Supabase client initialized")
        
        self.inserted_count = 0
        self.skipped_count = 0
        self.error_count = 0
    
    def check_table_exists(self) -> bool:
        """Verifica se a tabela cultural_references existe"""
        try:
            result = self.client.table('cultural_references').select('id').limit(1).execute()
            logger.info("Table 'cultural_references' exists")
            return True
        except Exception as e:
            logger.error(f"Table check failed: {e}")
            return False
    
    def get_existing_terms(self) -> set:
        """Recupera termos já existentes no banco"""
        try:
            result = self.client.table('cultural_references').select('termo').execute()
            existing = {row['termo'] for row in result.data}
            logger.info(f"Found {len(existing)} existing terms")
            return existing
        except Exception as e:
            logger.error(f"Error fetching existing terms: {e}")
            return set()
    
    def insert_batch(self, data_list: List[Dict]) -> int:
        """Insere batch de dados"""
        try:
            result = self.client.table('cultural_references').insert(data_list).execute()
            count = len(data_list)
            logger.info(f"Batch inserted: {count} records")
            return count
        except Exception as e:
            logger.error(f"Batch insert failed: {e}")
            # Tentar inserções individuais
            return self.insert_individually(data_list)
    
    def insert_individually(self, data_list: List[Dict]) -> int:
        """Insere dados individualmente (fallback)"""
        success_count = 0
        for data in data_list:
            try:
                self.client.table('cultural_references').insert(data).execute()
                success_count += 1
                logger.debug(f"Inserted: {data['termo']}")
            except Exception as e:
                logger.error(f"Failed to insert {data['termo']}: {e}")
                self.error_count += 1
        return success_count
    
    def insert_seed_data(self, seed_data: List[Dict], skip_existing: bool = True):
        """
        Insere todos os dados seed
        
        Args:
            seed_data: Lista de dados a inserir
            skip_existing: Se True, pula termos já existentes
        """
        logger.info("="*50)
        logger.info("STARTING SEED DATA INSERTION")
        logger.info("="*50)
        
        start_time = time.time()
        
        # Verificar tabela
        if not self.check_table_exists():
            logger.error("Table does not exist! Run migration first.")
            return
        
        # Filtrar dados existentes
        if skip_existing:
            existing_terms = self.get_existing_terms()
            seed_data = [d for d in seed_data if d['termo'] not in existing_terms]
            logger.info(f"After filtering: {len(seed_data)} new records to insert")
        
        if not seed_data:
            logger.info("No new data to insert")
            return
        
        # Inserir em batches
        total_batches = (len(seed_data) + BATCH_SIZE - 1) // BATCH_SIZE
        logger.info(f"Inserting {len(seed_data)} records in {total_batches} batches")
        
        for i in tqdm(range(0, len(seed_data), BATCH_SIZE), desc="Inserting batches"):
            batch = seed_data[i:i+BATCH_SIZE]
            count = self.insert_batch(batch)
            self.inserted_count += count
            time.sleep(0.5)  # Rate limiting
        
        # Estatísticas finais
        elapsed = time.time() - start_time
        logger.info("="*50)
        logger.info("SEED DATA INSERTION COMPLETED")
        logger.info(f"Time elapsed: {elapsed:.2f}s")
        logger.info(f"Total inserted: {self.inserted_count}")
        logger.info(f"Total errors: {self.error_count}")
        logger.info("="*50)
    
    def get_stats(self) -> Dict:
        """Recupera estatísticas da tabela"""
        try:
            # Total count
            result = self.client.table('cultural_references').select('id', count='exact').execute()
            total = result.count
            
            # Por tipo
            result_tipos = self.client.rpc('get_cultural_references_stats').execute()
            
            logger.info(f"Total references in database: {total}")
            return {'total': total, 'stats': result_tipos.data}
        except Exception as e:
            logger.error(f"Error getting stats: {e}")
            return {'total': 0, 'stats': None}

# =====================================================
# MAIN
# =====================================================

def main():
    """Função principal"""
    try:
        # Carregar seed data
        logger.info("Loading seed data...")
        seed_data = get_seed_data()
        logger.info(f"Loaded {len(seed_data)} seed records")
        
        # Criar inserter
        inserter = SeedInserter()
        
        # Inserir dados
        inserter.insert_seed_data(seed_data, skip_existing=True)
        
        # Mostrar estatísticas
        stats = inserter.get_stats()
        logger.info(f"Database now has {stats['total']} total references")
        
    except KeyboardInterrupt:
        logger.warning("Insertion interrupted by user")
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
