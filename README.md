# FIAP - Faculdade de Informática e Administração Paulista

<p align="center">
<a href="https://www.fiap.com.br/"><img src="assets/logo-fiap.png" alt="FIAP - Faculdade de Informática e Administração Paulista" border="0" width=40% height=40%></a>
</p>

<br>

# FarmTech Solutions

## Capítulo 1 - Fase 1

## 👨‍🎓 Integrantes:

- <a href="https://www.linkedin.com/in/joão-pedro-zavanela-andreu-119663250/">João Pedro Zavanela Andreu - RM570231</a>
- <a href="https://www.linkedin.com/in/jessicapmgomes/">Jéssica Paula Miranda Gomes - RM572120</a>
- <a href="https://www.linkedin.com/in/caike-minhano/">Caike Minhano - RM569255</a>
- Rafael Briani Rodrigues da Costa - RM573086
- Renan Lucas Seni de Souza - RM570862

## 👩‍🏫 Professores:

### Tutor(a)

- Sabrina Otoni

### Coordenador(a)

- André Godoi
## 📜 Descrição

O projeto **FarmTech Solutions** é um sistema de gerenciamento agrícola desenvolvido como parte do Capítulo 1 da Fase 1 da FIAP. O sistema tem como objetivo auxiliar produtores rurais no controle e monitoramento de talhões agrícolas, oferecendo funcionalidades para o cadastro, consulta, atualização e remoção de dados de lavouras de **Cana-de-açúcar** e **Laranja**.

Por meio de um menu interativo em **Python**, o usuário pode registrar informações de cada talhão, como nome, cultura, área calculada automaticamente (retângulo para cana, elipse para laranja) e a quantidade de insumo necessária com base na dose por metro e número de ruas da lavoura.

Complementando o sistema, dois scripts em **R** ampliam a análise dos dados:

- `estatisticas.R`: calcula estatísticas descritivas (média, desvio padrão, mínimo e máximo) sobre as áreas, quantidades de insumo e número de ruas cadastrados.
- `iralem.R`: consome a API pública **Open-Meteo** para exibir as condições climáticas atuais e a previsão dos próximos 5 dias para a localização da fazenda, auxiliando na tomada de decisões sobre irrigação e aplicação de insumos.

## 📁 Estrutura de pastas

Dentre os arquivos e pastas presentes na raiz do projeto, definem-se:

- **.github**: arquivos de configuração específicos do GitHub para gerenciar e automatizar processos no repositório.
- **assets**: arquivos relacionados a elementos não-estruturados, como imagens.
- **config**: arquivos de configuração para definir parâmetros e ajustes do projeto.
- **document**: documentos do projeto solicitados pelas atividades. Na subpasta `other`, adicione documentos complementares.
- **scripts**: scripts auxiliares para tarefas específicas, como deploy e backups.
- **src**: todo o código-fonte do projeto, incluindo:
  - `main.py` — sistema CRUD em Python para gerenciamento de talhões agrícolas.
  - `estatisticas.R` — análise estatística dos dados de área, insumos e ruas.
  - `iralem.R` — consulta climática via API Open-Meteo com previsão de 5 dias.
- **README.md**: guia e explicação geral sobre o projeto.

## 🔧 Como executar o código

### Pré-requisitos

- **Python 3.8+** — [Download](https://www.python.org/downloads/)
- **R 4.0+** — [Download](https://cran.r-project.org/)
- Pacotes R: `httr` e `jsonlite` (instalados automaticamente pelo script `iralem.R`)

### Executando o sistema Python

```bash
# Clone o repositório
git clone https://github.com/renanseni/fase1_cap1.git

# Acesse a pasta do projeto
cd fase1_cap1

# Execute o sistema principal
python src/main.py
```

Ao iniciar, o menu interativo será exibido com as opções:
1. Cadastrar nova área
2. Exibir registros
3. Atualizar registro
4. Deletar registro
5. Sair

### Executando os scripts R

```bash
# Estatísticas descritivas dos dados
Rscript src/estatisticas.R

# Consulta climática via API Open-Meteo
Rscript src/iralem.R
```

> **Obs.:** o script `iralem.R` requer conexão com a internet para acessar a API Open-Meteo.

## 🗃 Histórico de lançamentos

* 0.1.0 - 17/03/2025
    * Implementação do sistema CRUD em Python (`main.py`)
    * Script de estatísticas descritivas em R (`estatisticas.R`)
    * Script de consulta climática via API Open-Meteo em R (`iralem.R`)

## 📋 Licença

<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"><p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/agodoi/template">MODELO GIT FIAP</a> por <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://fiap.com.br">Fiap</a> está licenciado sobre <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">Attribution 4.0 International</a>.</p>
