-- =====================================================
-- COMANDO SQL 4/4: Seed Data Inicial
-- =====================================================

INSERT INTO cultural_references (termo, tipo, significado, exemplo_uso, regiao, contexto_flerte) VALUES
    ('Mó cê', 'giria', 'Gíria carioca para "você está" ou "tipo você"', 'Mó cê linda(o) nessa foto!', 'sudeste', 'Casual e descontraído, muito usado no Rio'),
    ('Massa', 'giria', 'Expressão nordestina para algo legal, bacana', 'Seu perfil tá massa demais!', 'nordeste', 'Tom casual e autêntico'),
    ('Quebrar o gelo', 'expressao_regional', 'Iniciar uma conversa de forma leve', 'Vamos quebrar o gelo: qual teu lugar favorito?', 'nacional', 'Início de conversa, tom casual'),
    ('Deu match', 'giria', 'Expressão moderna de apps de namoro, significa combinaram', 'Deu match! Destino ou sorte?', 'nacional', 'Contexto de apps de relacionamento'),
    ('Crush', 'giria', 'Paquera, pessoa por quem se está interessado', 'Então você é meu novo crush?', 'nacional', 'Tom flertante moderno'),
    ('Chamar pra sair', 'expressao_regional', 'Convidar para um encontro', 'Que tal a gente chamar pra sair e conhecer melhor?', 'nacional', 'Convite direto mas respeitoso'),
    ('Gato(a)', 'giria', 'Pessoa bonita, atraente', 'Que gato(a) você é!', 'nacional', 'Elogio físico direto'),
    ('Mozão', 'giria', 'Apelido carinhoso para parceiro romântico', 'E aí, mozão, bora conhecer?', 'nacional', 'Tom carinhoso e descontraído'),
    ('Peguete', 'giria', 'Ficante, relacionamento casual', 'Já tem algum peguete por aí?', 'nacional', 'Contexto de relacionamento casual'),
    ('Rolê', 'giria', 'Passeio, programa', 'Bora marcar um rolê?', 'nacional', 'Convite casual para sair'),
    ('Shippar', 'giria', 'Torcer por um casal, imaginar junto', 'Já tô shippando a gente', 'nacional', 'Tom moderno e divertido'),
    ('Zap', 'giria', 'WhatsApp, usado para pedir contato', 'Me passa teu zap?', 'nacional', 'Pedido de contato casual'),
    ('Tamo junto', 'giria', 'Expressão de apoio, estar presente', 'Qualquer coisa, tamo junto!', 'nacional', 'Tom solidário e parceiro'),
    ('Beleza', 'giria', 'Concordância, tudo bem', 'Beleza, vamos marcar então!', 'nacional', 'Confirmação casual'),
    ('Top', 'giria', 'Algo muito bom, excelente', 'Seu perfil tá top!', 'nacional', 'Elogio casual'),
    ('Mano(a)', 'giria', 'Amigo, parceiro (pode ser usado em flerte)', 'E aí mano(a), bora trocar uma ideia?', 'sudeste', 'Tom descontraído paulista'),
    ('Arraso', 'giria', 'Estar arrasando, estar incrível', 'Você arrasa nessa foto!', 'nacional', 'Elogio empolgado'),
    ('Gatilho', 'meme', 'Algo que desencadeia memória ou emoção forte', 'Seu sorriso é meu gatilho', 'nacional', 'Tom romântico moderno'),
    ('Red flag', 'meme', 'Sinal de alerta em relacionamento', 'Pelo menos não vi red flags no seu perfil', 'nacional', 'Tom humorístico sobre relacionamentos'),
    ('Green flag', 'meme', 'Sinal positivo em relacionamento', 'Gostar de pets é total green flag!', 'nacional', 'Tom positivo sobre qualidades'),
    ('Flerte', 'expressao_regional', 'Ato de paquerar, demonstrar interesse romântico', 'Esse é um flerte ou só conversa?', 'nacional', 'Contexto direto de paquera'),
    ('Sorte sua', 'expressao_regional', 'Expressão brincalhona de autoconfiança', 'Match comigo? Sorte sua!', 'nacional', 'Tom confiante e brincalhão'),
    ('Papo reto', 'giria', 'Conversa sincera, direta', 'Papo reto: achei você interessante', 'nacional', 'Tom genuíno e direto'),
    ('Vibe', 'giria', 'Energia, clima de uma pessoa ou lugar', 'Curti sua vibe!', 'nacional', 'Tom descontraído moderno'),
    ('Cara metade', 'expressao_regional', 'Parceiro ideal, alma gêmea', 'Será que você é minha cara metade?', 'nacional', 'Tom romântico tradicional')
ON CONFLICT (termo) DO NOTHING;
