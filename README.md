# FIAP - Faculdade de Informática e Administração Paulista

<p align="center">
<a href="https://www.fiap.com.br/"><img src="assets/logo-fiap.png" alt="FIAP - Faculdade de Informática e Administração Paulista" border="0" width=40% height=40%></a>
</p>

<br>

# FarmTech Solutions - Sistema de Irrigacao Inteligente

## Capitulo 1 - Fase 2

## Integrantes:

- <a href="https://www.linkedin.com/in/joão-pedro-zavanela-andreu-119663250/">João Pedro Zavanela Andreu - RM570231</a>
- <a href="https://www.linkedin.com/in/jessicapmgomes/">Jéssica Paula Miranda Gomes - RM572120</a>
- <a href="https://www.linkedin.com/in/caike-minhano/">Caike Minhano - RM569255</a>
- Rafael Briani Rodrigues da Costa - RM573086
- Renan Lucas Seni de Souza - RM570862

## Professores:

### Tutor(a)

- Sabrina Otoni

### Coordenador(a)

- André Godoi

## Descricao

O projeto **FarmTech Solutions - Fase 2** e um sistema de irrigacao inteligente desenvolvido para a disciplina da FIAP. O sistema utiliza um **ESP32** simulado na plataforma **Wokwi** para monitorar sensores agricolas e controlar automaticamente uma bomba d'agua (rele), otimizando a irrigacao de uma lavoura de **Tomate**.

### Sensores utilizados (simulados no Wokwi)

| Sensor Real | Simulacao no Wokwi | Pino ESP32 | Funcao |
|---|---|---|---|
| Nitrogenio (N) | Botao verde | GPIO 12 | Presenca do nutriente (pressionado = presente) |
| Fosforo (P) | Botao verde | GPIO 14 | Presenca do nutriente (pressionado = presente) |
| Potassio (K) | Botao verde | GPIO 27 | Presenca do nutriente (pressionado = presente) |
| Sensor de pH | LDR (sensor de luz) | GPIO 34 (ADC) | Leitura analogica convertida para escala 0-14 |
| Umidade do solo | DHT22 | GPIO 15 | Leitura de umidade (%) |
| Bomba d'agua | Rele azul | GPIO 26 | Liga/desliga irrigacao |

### Logica de irrigacao

A cultura de referencia escolhida foi o **Tomate**, com os seguintes parametros ideais:

- **pH do solo:** 6.0 a 6.8
- **Umidade do solo:** 60% a 80%
- **NPK:** todos os nutrientes necessarios (N, P e K presentes)

A decisao de ligar ou desligar a bomba segue esta logica:

1. **Umidade abaixo de 60%** → Liga a bomba (solo seco, irrigacao necessaria)
2. **Umidade acima de 80%** → Desliga a bomba (solo ja esta umido o suficiente)
3. **Umidade entre 60% e 80%** → Verifica NPK e pH:
   - Se algum nutriente (N, P ou K) esta **ausente** → Liga a bomba para auxiliar na absorcao
   - Se o pH esta **fora da faixa ideal** (< 6.0 ou > 6.8) → Liga a bomba para correcao
   - Se todos os parametros estao **adequados** → Desliga a bomba

### Imagem do circuito

temo q fzr isso ainda.

## Estrutura de pastas

Dentre os arquivos e pastas presentes na raiz do projeto, definem-se:

- **.github**: Nesta pasta ficarão os arquivos de configuração específicos do GitHub que ajudam a gerenciar e automatizar processos no repositório.

- **assets**: Aqui estão os arquivos relacionados a elementos não-estruturados deste repositório, como imagens.

- **config**: Posicione aqui arquivos de configuração que são usados para definir parâmetros e ajustes do projeto.

- **document**: Aqui estão todos os documentos do projeto que as atividades poderão pedir. Na subpasta "other", adicione documentos complementares e menos importantes.

- **scripts**: Posicione aqui scripts auxiliares para tarefas específicas do seu projeto. Exemplo: deploy, migrações de banco de dados, backups.

- **src**: Todo o código fonte criado para o desenvolvimento do projeto ao longo das 7 fases.
  - `sketch.ino ` - Código principal do ESP32 (C/C++).
  - `iralem.py `  - Script Python com integração com API meteorológica.
  - `iralem.R` - Script R - Análise estatística
- **README.md**: Arquivo que serve como guia e explicação geral sobre o projeto (o mesmo que você está lendo agora).

## Como executar

### 1. Simulacao no Wokwi (obrigatorio)

1. Acesse [wokwi.com](https://wokwi.com) e crie um novo projeto **ESP32**
2. Copie o conteudo de `src/sketch.ino` para o editor de codigo
3. Na aba **Libraries**, adicione a biblioteca `DHT sensor library`
4. Clique em **Start Simulation**
5. Interaja com os sensores:
   - Pressione os botoes **N**, **P**, **K** para simular presenca de nutrientes
   - Ajuste o **LDR** (clicando nele) para variar o pH simulado
   - Ajuste o **DHT22** (clicando nele) para variar a umidade
6. Observe no **Monitor Serial** as leituras e a decisao de irrigacao

### 2. Script Python - API meteorologica (Ir Além)

```bash
# Instale as dependencias
pip install requests

# Execute o script
python src/iralem.py
```

### 3. Analise em R (Ir Além)

```bash
Rscript src/iralem.r
```

## Historico de lancamentos

* 0.1.0 - 26/03/2026
    * Implementacao do sistema de irrigacao inteligente no ESP32 (sketch.ino)
    * Diagrama do circuito para o Wokwi (diagram.json)

## Licenca

<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"><p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/agodoi/template">MODELO GIT FIAP</a> por <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://fiap.com.br">Fiap</a> está licenciado sobre <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">Attribution 4.0 International</a>.</p>
