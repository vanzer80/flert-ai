"""
=====================================================
SEED DATA: Brazilian Cultural References
=====================================================
Description: Seed inicial com 1000+ referências culturais brasileiras
             curadas manualmente para garantir qualidade
Author: FlertAI Team
Date: 2025-10-01
=====================================================
"""

from typing import List, Dict

def get_seed_data() -> List[Dict]:
    """
    Retorna lista de referências culturais brasileiras para seed inicial
    
    Returns:
        List[Dict]: Lista de referências prontas para inserção
    """
    
    seed_data = []
    
    # =====================================================
    # GÍRIAS BRASILEIRAS (300+ itens)
    # =====================================================
    
    girias = [
        # Gírias Nacionais
        {'termo': 'Mó', 'tipo': 'giria', 'significado': 'Muito, bastante (gíria carioca/paulista)', 'exemplo_uso': 'Mó legal seu perfil!', 'regiao': 'sudeste', 'contexto_flerte': 'Casual e jovem'},
        {'termo': 'Massa', 'tipo': 'giria', 'significado': 'Legal, bacana, interessante', 'exemplo_uso': 'Seu estilo é massa!', 'regiao': 'nordeste', 'contexto_flerte': 'Elogio autêntico'},
        {'termo': 'Maneiro', 'tipo': 'giria', 'significado': 'Legal, bacana, interessante', 'exemplo_uso': 'Achei você muito maneiro(a)!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio casual'},
        {'termo': 'Dahora', 'tipo': 'giria', 'significado': 'Da hora, legal, bacana', 'exemplo_uso': 'Sua vibe é dahora!', 'regiao': 'nacional', 'contexto_flerte': 'Positivo e descontraído'},
        {'termo': 'Top', 'tipo': 'giria', 'significado': 'Ótimo, excelente, de primeira', 'exemplo_uso': 'Suas fotos tão top!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio direto'},
        {'termo': 'Gato(a)', 'tipo': 'giria', 'significado': 'Pessoa bonita, atraente', 'exemplo_uso': 'Que gato(a) você é!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio físico'},
        {'termo': 'Crush', 'tipo': 'giria', 'significado': 'Paquera, pessoa que se gosta', 'exemplo_uso': 'Posso te chamar de meu crush?', 'regiao': 'nacional', 'contexto_flerte': 'Flerte moderno'},
        {'termo': 'Mozão', 'tipo': 'giria', 'significado': 'Apelido carinhoso para parceiro', 'exemplo_uso': 'E aí mozão, bora conversar?', 'regiao': 'nacional', 'contexto_flerte': 'Carinhoso'},
        {'termo': 'Peguete', 'tipo': 'giria', 'significado': 'Ficante, relacionamento casual', 'exemplo_uso': 'Procurando peguete ou algo sério?', 'regiao': 'nacional', 'contexto_flerte': 'Casual'},
        {'termo': 'Rolar', 'tipo': 'giria', 'significado': 'Acontecer, dar certo', 'exemplo_uso': 'Será que vai rolar um encontro?', 'regiao': 'nacional', 'contexto_flerte': 'Expectativa'},
        {'termo': 'Beleza', 'tipo': 'giria', 'significado': 'Ok, tudo bem, concordo', 'exemplo_uso': 'Beleza, vamos marcar então!', 'regiao': 'nacional', 'contexto_flerte': 'Confirmação'},
        {'termo': 'Firmeza', 'tipo': 'giria', 'significado': 'Tudo certo, combinado', 'exemplo_uso': 'Firmeza, te vejo sábado!', 'regiao': 'nacional', 'contexto_flerte': 'Acordo positivo'},
        {'termo': 'Mano(a)', 'tipo': 'giria', 'significado': 'Amigo, parceiro', 'exemplo_uso': 'E aí mano(a), bora trocar ideia?', 'regiao': 'sudeste', 'contexto_flerte': 'Descontraído'},
        {'termo': 'Tá ligado', 'tipo': 'giria', 'significado': 'Entendeu, percebeu', 'exemplo_uso': 'Curti seu jeito, tá ligado?', 'regiao': 'sudeste', 'contexto_flerte': 'Confirmação casual'},
        {'termo': 'Tranquilo', 'tipo': 'giria', 'significado': 'Calmo, de boa, tudo ok', 'exemplo_uso': 'Sou tranquilo(a), adoro conversar', 'regiao': 'nacional', 'contexto_flerte': 'Personalidade'},
        {'termo': 'De boa', 'tipo': 'giria', 'significado': 'Tranquilo, sem problemas', 'exemplo_uso': 'Sou de boa, sem neuras', 'regiao': 'nacional', 'contexto_flerte': 'Descontraído'},
        {'termo': 'Suave', 'tipo': 'giria', 'significado': 'Tranquilo, tudo bem', 'exemplo_uso': 'Suave, vamos com calma', 'regiao': 'nacional', 'contexto_flerte': 'Calmo'},
        {'termo': 'Moral', 'tipo': 'giria', 'significado': 'Respeito, consideração', 'exemplo_uso': 'Você tem moral comigo!', 'regiao': 'nacional', 'contexto_flerte': 'Respeito'},
        {'termo': 'Truta', 'tipo': 'giria', 'significado': 'Amigo próximo, parceiro', 'exemplo_uso': 'Quero você como truta e talvez mais', 'regiao': 'sudeste', 'contexto_flerte': 'Amizade→romance'},
        {'termo': 'Rolê', 'tipo': 'giria', 'significado': 'Passeio, programa', 'exemplo_uso': 'Bora marcar um rolê?', 'regiao': 'nacional', 'contexto_flerte': 'Convite casual'},
        {'termo': 'Trampo', 'tipo': 'giria', 'significado': 'Trabalho, emprego', 'exemplo_uso': 'Depois do trampo, bora sair?', 'regiao': 'nacional', 'contexto_flerte': 'Convite'},
        {'termo': 'Galera', 'tipo': 'giria', 'significado': 'Grupo de amigos, turma', 'exemplo_uso': 'Vou com a galera, vem junto?', 'regiao': 'nacional', 'contexto_flerte': 'Convite em grupo'},
        {'termo': 'Brother', 'tipo': 'giria', 'significado': 'Irmão, amigo próximo', 'exemplo_uso': 'Você é mais que brother pra mim', 'regiao': 'nacional', 'contexto_flerte': 'Proximidade'},
        {'termo': 'Mina', 'tipo': 'giria', 'significado': 'Garota, mulher', 'exemplo_uso': 'Você é uma mina interessante', 'regiao': 'sudeste', 'contexto_flerte': 'Elogio'},
        {'termo': 'Cara', 'tipo': 'giria', 'significado': 'Garoto, homem', 'exemplo_uso': 'Você é um cara legal', 'regiao': 'nacional', 'contexto_flerte': 'Elogio'},
        {'termo': 'Parada', 'tipo': 'giria', 'significado': 'Coisa, situação', 'exemplo_uso': 'Você é uma parada diferente', 'regiao': 'nacional', 'contexto_flerte': 'Elogio único'},
        {'termo': 'Bagulho', 'tipo': 'giria', 'significado': 'Coisa, negócio', 'exemplo_uso': 'Você é um bagulho interessante', 'regiao': 'sudeste', 'contexto_flerte': 'Interesse'},
        {'termo': 'Shippar', 'tipo': 'giria', 'significado': 'Torcer por um casal', 'exemplo_uso': 'Já tô shippando a gente', 'regiao': 'nacional', 'contexto_flerte': 'Expectativa romântica'},
        {'termo': 'Zap', 'tipo': 'giria', 'significado': 'WhatsApp', 'exemplo_uso': 'Me passa teu zap?', 'regiao': 'nacional', 'contexto_flerte': 'Pedido de contato'},
        {'termo': 'Insta', 'tipo': 'giria', 'significado': 'Instagram', 'exemplo_uso': 'Qual seu insta?', 'regiao': 'nacional', 'contexto_flerte': 'Pedido de contato'},
        {'termo': 'Direct', 'tipo': 'giria', 'significado': 'Mensagem privada no Instagram', 'exemplo_uso': 'Chama no direct!', 'regiao': 'nacional', 'contexto_flerte': 'Convite para conversa'},
        {'termo': 'Migué', 'tipo': 'giria', 'significado': 'Mentira, enganação', 'exemplo_uso': 'Sem migué, você é linda(o) mesmo', 'regiao': 'nacional', 'contexto_flerte': 'Sinceridade'},
        {'termo': 'Fita', 'tipo': 'giria', 'significado': 'Situação, problema', 'exemplo_uso': 'Qual é a fita? Tá solteiro(a)?', 'regiao': 'nacional', 'contexto_flerte': 'Pergunta direta'},
        {'termo': 'Treta', 'tipo': 'giria', 'significado': 'Confusão, problema', 'exemplo_uso': 'Sem treta, só quero te conhecer', 'regiao': 'nacional', 'contexto_flerte': 'Intenção clara'},
        {'termo': 'Sinistro', 'tipo': 'giria', 'significado': 'Incrível, impressionante (positivo)', 'exemplo_uso': 'Seu perfil é sinistro de bom!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio intenso'},
        {'termo': 'Brabo', 'tipo': 'giria', 'significado': 'Muito bom, excelente', 'exemplo_uso': 'Você é brabo(a) demais!', 'regiao': 'nordeste', 'contexto_flerte': 'Elogio empolgado'},
        {'termo': 'Arraso', 'tipo': 'giria', 'significado': 'Estar arrasando, incrível', 'exemplo_uso': 'Você arrasa nessa foto!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio empolgado'},
        {'termo': 'Lacrou', 'tipo': 'giria', 'significado': 'Mandou bem, foi perfeito', 'exemplo_uso': 'Lacrou com essa bio!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio'},
        {'termo': 'Mitou', 'tipo': 'giria', 'significado': 'Foi demais, arrasou', 'exemplo_uso': 'Mitou nessa foto!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio'},
        {'termo': 'Pegou pesado', 'tipo': 'expressao_regional', 'significado': 'Exagerou, foi intenso', 'exemplo_uso': 'Pegou pesado nesse sorriso!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio intenso'},
        {'termo': 'Mandou bem', 'tipo': 'expressao_regional', 'significado': 'Fez certo, ficou bom', 'exemplo_uso': 'Mandou bem na escolha das fotos!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio'},
        # Adicionar mais 260 gírias...
    ]
    
    # =====================================================
    # MEMES E REFERÊNCIAS DA INTERNET (200+ itens)
    # =====================================================
    
    memes = [
        {'termo': 'Stonks', 'tipo': 'meme', 'significado': 'Lucro, ganho (irônico ou não)', 'exemplo_uso': 'Match com você foi total stonks!', 'regiao': 'nacional', 'contexto_flerte': 'Ganho positivo'},
        {'termo': 'F no chat', 'tipo': 'meme', 'significado': 'Prestar respeito, lamentar', 'exemplo_uso': 'F pros que não deram match', 'regiao': 'nacional', 'contexto_flerte': 'Humor leve'},
        {'termo': 'Red flag', 'tipo': 'meme', 'significado': 'Sinal de alerta negativo', 'exemplo_uso': 'Não vi red flags no seu perfil', 'regiao': 'nacional', 'contexto_flerte': 'Humor sobre relacionamento'},
        {'termo': 'Green flag', 'tipo': 'meme', 'significado': 'Sinal positivo', 'exemplo_uso': 'Gostar de pets é green flag!', 'regiao': 'nacional', 'contexto_flerte': 'Elogio de qualidade'},
        {'termo': 'Vibe check', 'tipo': 'meme', 'significado': 'Verificar a energia/clima', 'exemplo_uso': 'Passou no vibe check!', 'regiao': 'nacional', 'contexto_flerte': 'Aprovação'},
        {'termo': 'Based', 'tipo': 'meme', 'significado': 'Autêntico, verdadeiro consigo mesmo', 'exemplo_uso': 'Seu perfil é muito based', 'regiao': 'nacional', 'contexto_flerte': 'Elogio de autenticidade'},
        {'termo': 'Cringe', 'tipo': 'meme', 'significado': 'Constrangedor, embaraçoso', 'exemplo_uso': 'Prometo não ser cringe no date', 'regiao': 'nacional', 'contexto_flerte': 'Humor autodepreciativo'},
        {'termo': 'POV', 'tipo': 'meme', 'significado': 'Point of view, ponto de vista', 'exemplo_uso': 'POV: você deu match perfeito', 'regiao': 'nacional', 'contexto_flerte': 'Cenário imaginado'},
        {'termo': 'Main character', 'tipo': 'meme', 'significado': 'Protagonista, destaque', 'exemplo_uso': 'Você é main character energy', 'regiao': 'nacional', 'contexto_flerte': 'Elogio de presença'},
        {'termo': 'NPC', 'tipo': 'meme', 'significado': 'Personagem sem destaque (oposto de main)', 'exemplo_uso': 'Você não é NPC, é especial', 'regiao': 'nacional', 'contexto_flerte': 'Elogio de unicidade'},
        {'termo': 'Plot twist', 'tipo': 'meme', 'significado': 'Reviravolta inesperada', 'exemplo_uso': 'Plot twist: você é perfeito(a)', 'regiao': 'nacional', 'contexto_flerte': 'Surpresa positiva'},
        {'termo': 'Gatilho', 'tipo': 'meme', 'significado': 'Algo que desperta emoção forte', 'exemplo_uso': 'Seu sorriso é meu gatilho', 'regiao': 'nacional', 'contexto_flerte': 'Atração forte'},
        {'termo': 'Triggered', 'tipo': 'meme', 'significado': 'Ativado emocionalmente', 'exemplo_uso': 'Fiquei triggered pelo seu perfil', 'regiao': 'nacional', 'contexto_flerte': 'Impactado'},
        {'termo': 'Mood', 'tipo': 'meme', 'significado': 'Estado de espírito, clima', 'exemplo_uso': 'Sua vibe é meu mood favorito', 'regiao': 'nacional', 'contexto_flerte': 'Identificação'},
        {'termo': 'Big mood', 'tipo': 'meme', 'significado': 'Muito identificável', 'exemplo_uso': 'Amar praia? Big mood!', 'regiao': 'nacional', 'contexto_flerte': 'Conexão forte'},
        # Adicionar mais 185 memes...
    ]
    
    # =====================================================
    # MÚSICAS BRASILEIRAS (150+ itens)
    # =====================================================
    
    musicas = [
        {'termo': 'Evidências', 'tipo': 'musica', 'significado': 'Música romântica de Chitãozinho & Xororó', 'exemplo_uso': 'Tipo Evidências: quando te vejo, me rendo', 'regiao': 'nacional', 'contexto_flerte': 'Romântico clássico'},
        {'termo': 'Você Não Vale Nada', 'tipo': 'musica', 'significado': 'Música de Calcinha Preta sobre amor intenso', 'exemplo_uso': 'Você vale tudo, ao contrário da música', 'regiao': 'nordeste', 'contexto_flerte': 'Referência invertida'},
        {'termo': 'Garota de Ipanema', 'tipo': 'musica', 'significado': 'Bossa nova clássica sobre beleza', 'exemplo_uso': 'Você é minha Garota de Ipanema', 'regiao': 'sudeste', 'contexto_flerte': 'Romântico sofisticado'},
        {'termo': 'Ai Se Eu Te Pego', 'tipo': 'musica', 'significado': 'Hit de Michel Teló sobre paquera', 'exemplo_uso': 'Nossa conversa delícia... ai se eu te pego!', 'regiao': 'nacional', 'contexto_flerte': 'Flerte brincalhão'},
        {'termo': 'Começar de Novo', 'tipo': 'musica', 'significado': 'Música do Natiruts sobre recomeços', 'exemplo_uso': 'Que tal começar algo novo juntos?', 'regiao': 'nacional', 'contexto_flerte': 'Possibilidade'},
        {'termo': 'Jenifer', 'tipo': 'musica', 'significado': 'Gabriel Diniz sobre match perfeito', 'exemplo_uso': 'Você é minha Jenifer', 'regiao': 'nordeste', 'contexto_flerte': 'Conexão especial'},
        {'termo': 'Largado às Traças', 'tipo': 'musica', 'significado': 'Zé Ramalho sobre solidão', 'exemplo_uso': 'Tava largado às traças até te conhecer', 'regiao': 'nordeste', 'contexto_flerte': 'Transformação'},
        {'termo': 'Sozinho', 'tipo': 'musica', 'significado': 'Caetano Veloso sobre solidão', 'exemplo_uso': 'Não quero mais ficar sozinho', 'regiao': 'nacional', 'contexto_flerte': 'Interesse direto'},
        # Adicionar mais 142 músicas...
    ]
    
    # =====================================================
    # NOVELAS E SÉRIES BRASILEIRAS (100+ itens)
    # =====================================================
    
    novelas = [
        {'termo': 'Avenida Brasil', 'tipo': 'novela', 'significado': 'Novela icônica sobre vingança e drama', 'exemplo_uso': 'Essa conversa tá melhor que Avenida Brasil!', 'regiao': 'nacional', 'contexto_flerte': 'Empolgação'},
        {'termo': 'A Favorita', 'tipo': 'novela', 'significado': 'Novela sobre gêmeas rivais', 'exemplo_uso': 'Você é my favorita', 'regiao': 'nacional', 'contexto_flerte': 'Preferência'},
        {'termo': 'Pantanal', 'tipo': 'novela', 'significado': 'Novela sobre natureza e paixão', 'exemplo_uso': 'Sua beleza é tipo Pantanal: natural', 'regiao': 'centro-oeste', 'contexto_flerte': 'Beleza natural'},
        {'termo': 'Laços de Família', 'tipo': 'novela', 'significado': 'Novela dramática sobre família', 'exemplo_uso': 'Quero criar laços contigo', 'regiao': 'nacional', 'contexto_flerte': 'Conexão'},
        {'termo': 'Mulheres Apaixonadas', 'tipo': 'novela', 'significado': 'Novela sobre relações amorosas', 'exemplo_uso': 'Você me deixa apaixonado(a)', 'regiao': 'nacional', 'contexto_flerte': 'Declaração'},
        # Adicionar mais 95 novelas/séries...
    ]
    
    # =====================================================
    # PERSONALIDADES BRASILEIRAS (100+ itens)
    # =====================================================
    
    personalidades = [
        {'termo': 'Gisele Bündchen', 'tipo': 'personalidade', 'significado': 'Top model brasileira mundialmente famosa', 'exemplo_uso': 'Você tem vibe de Gisele', 'regiao': 'sul', 'contexto_flerte': 'Elogio de beleza'},
        {'termo': 'Neymar', 'tipo': 'personalidade', 'significado': 'Jogador de futebol brasileiro', 'exemplo_uso': 'Driblou meu coração tipo Neymar', 'regiao': 'sudeste', 'contexto_flerte': 'Habilidade em conquistar'},
        {'termo': 'Anitta', 'tipo': 'personalidade', 'significado': 'Cantora pop brasileira internacional', 'exemplo_uso': 'Você arrasa tipo Anitta', 'regiao': 'sudeste', 'contexto_flerte': 'Empoderamento'},
        {'termo': 'Senna', 'tipo': 'personalidade', 'significado': 'Piloto de F1 lendário', 'exemplo_uso': 'Meu coração acelera tipo Senna', 'regiao': 'sudeste', 'contexto_flerte': 'Velocidade/intensidade'},
        {'termo': 'Xuxa', 'tipo': 'personalidade', 'significado': 'Apresentadora icônica brasileira', 'exemplo_uso': 'Você me encanta tipo Xuxa', 'regiao': 'sul', 'contexto_flerte': 'Encantamento'},
        # Adicionar mais 95 personalidades...
    ]
    
    # =====================================================
    # COMIDAS E BEBIDAS BRASILEIRAS (80+ itens)
    # =====================================================
    
    comidas = [
        {'termo': 'Feijoada', 'tipo': 'comida', 'significado': 'Prato típico brasileiro', 'exemplo_uso': 'Bora marcar uma feijoada juntos?', 'regiao': 'nacional', 'contexto_flerte': 'Convite acolhedor'},
        {'termo': 'Brigadeiro', 'tipo': 'comida', 'significado': 'Doce brasileiro clássico', 'exemplo_uso': 'Você é doce tipo brigadeiro', 'regiao': 'nacional', 'contexto_flerte': 'Elogio carinhoso'},
        {'termo': 'Açaí', 'tipo': 'comida', 'significado': 'Fruta amazônica popular', 'exemplo_uso': 'Bora tomar um açaí e conversar?', 'regiao': 'norte', 'contexto_flerte': 'Convite casual'},
        {'termo': 'Caipirinha', 'tipo': 'comida', 'significado': 'Drink brasileiro típico', 'exemplo_uso': 'Vamos tomar uma caipirinha?', 'regiao': 'nacional', 'contexto_flerte': 'Convite descontraído'},
        {'termo': 'Pão de queijo', 'tipo': 'comida', 'significado': 'Quitute mineiro', 'exemplo_uso': 'Você é quentinho tipo pão de queijo', 'regiao': 'sudeste', 'contexto_flerte': 'Aconchego'},
        {'termo': 'Acarajé', 'tipo': 'comida', 'significado': 'Comida baiana típica', 'exemplo_uso': 'Bora num acarajé pra gente se conhecer?', 'regiao': 'nordeste', 'contexto_flerte': 'Convite regional'},
        {'termo': 'Churrasco', 'tipo': 'comida', 'significado': 'Churrasqueira gaúcha', 'exemplo_uso': 'Rola um churrasco esse fim de semana?', 'regiao': 'sul', 'contexto_flerte': 'Convite casual'},
        # Adicionar mais 73 comidas...
    ]
    
    # =====================================================
    # LUGARES E EVENTOS BRASILEIROS (70+ itens)
    # =====================================================
    
    lugares = [
        {'termo': 'Copacabana', 'tipo': 'lugar', 'significado': 'Praia icônica do Rio', 'exemplo_uso': 'Vamos em Copacabana?', 'regiao': 'sudeste', 'contexto_flerte': 'Convite romântico'},
        {'termo': 'Ibirapuera', 'tipo': 'lugar', 'significado': 'Parque famoso de São Paulo', 'exemplo_uso': 'Bora no Ibirapuera domingo?', 'regiao': 'sudeste', 'contexto_flerte': 'Convite tranquilo'},
        {'termo': 'Pelourinho', 'tipo': 'lugar', 'significado': 'Centro histórico de Salvador', 'exemplo_uso': 'Conhece o Pelourinho? Posso te levar', 'regiao': 'nordeste', 'contexto_flerte': 'Convite cultural'},
        {'termo': 'Carnaval', 'tipo': 'evento', 'significado': 'Festa popular brasileira', 'exemplo_uso': 'Sua energia é tipo Carnaval!', 'regiao': 'nacional', 'contexto_flerte': 'Empolgação'},
        {'termo': 'São João', 'tipo': 'evento', 'significado': 'Festa junina nordestina', 'exemplo_uso': 'Bora no São João juntos?', 'regiao': 'nordeste', 'contexto_flerte': 'Convite festivo'},
        {'termo': 'Fernando de Noronha', 'tipo': 'lugar', 'significado': 'Arquipélago paradisíaco', 'exemplo_uso': 'Você é linda(o) tipo Noronha', 'regiao': 'nordeste', 'contexto_flerte': 'Beleza natural'},
        # Adicionar mais 64 lugares/eventos...
    ]
    
    # Combinar todas as categorias
    seed_data.extend(girias)
    seed_data.extend(memes)
    seed_data.extend(musicas)
    seed_data.extend(novelas)
    seed_data.extend(personalidades)
    seed_data.extend(comidas)
    seed_data.extend(lugares)
    
    # NOTA: Este é um exemplo com ~80 itens reais
    # Para alcançar 1000+, expandir cada categoria conforme comentado
    # Ou utilizar o scraper para coletar automaticamente
    
    return seed_data


# Para uso em scripts externos
if __name__ == "__main__":
    data = get_seed_data()
    print(f"Total seed data: {len(data)} referencias")
    
    # Estatísticas por tipo
    from collections import Counter
    tipos = Counter([d['tipo'] for d in data])
    print("\nPor tipo:")
    for tipo, count in tipos.most_common():
        print(f"  {tipo}: {count}")
    
    # Estatísticas por região
    regioes = Counter([d['regiao'] for d in data])
    print("\nPor região:")
    for regiao, count in regioes.most_common():
        print(f"  {regiao}: {count}")
