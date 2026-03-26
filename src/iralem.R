# =============================================================================
# FarmTech Solutions - Dados Climaticos via API (Open-Meteo)
# Objetivo: conectar a uma API meteorologica publica, coletar dados climaticos
#           e exibir informacoes de clima atual e previsao de 5 dias no terminal.
# Dependencias: httr (requisicoes HTTP), jsonlite (parse de JSON)
# Execucao: Rscript IrAlem.R
# =============================================================================

# ── Instalacao automatica de pacotes (so instala se ainda nao tiver) ──
if (!require("httr", quietly = TRUE)) install.packages("httr")
if (!require("jsonlite", quietly = TRUE)) install.packages("jsonlite")

library(httr)      # para fazer requisicoes HTTP (GET)
library(jsonlite)  # para converter JSON em estruturas do R

# ── Configuracao de localizacao ──
latitude  <- -23.55          # latitude de Sao Paulo
longitude <- -46.63          # longitude de Sao Paulo
cidade    <- "Sao Paulo"

# ── Montagem da URL e chamada a API ──
# A API Open-Meteo e gratuita e nao exige chave de autenticacao.
# Parametros: clima atual (temperatura, umidade, vento) e previsao diaria de 5 dias.
url <- paste0(
  "https://api.open-meteo.com/v1/forecast?",
  "latitude=", latitude,
  "&longitude=", longitude,
  "&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code",
  "&daily=temperature_2m_max,temperature_2m_min,precipitation_sum",
  "&timezone=America/Sao_Paulo",
  "&forecast_days=5"
)

# GET() envia a requisicao HTTP e armazena a resposta
resposta <- GET(url)

# Verifica se a API respondeu com sucesso (codigo 200)
if (status_code(resposta) != 200) {
  cat("Erro ao acessar a API. Codigo:", status_code(resposta), "\n")
  quit(status = 1)
}

# Converte o corpo da resposta (JSON) em lista do R
dados <- fromJSON(content(resposta, as = "text", encoding = "UTF-8"))

# ── Exibicao do clima atual ──
atual <- dados$current
cat("==========================================\n")
cat("  FarmTech Solutions - Clima Atual\n")
cat("  Local:", cidade, "\n")
cat("==========================================\n\n")
cat("Temperatura:", atual$temperature_2m, "C\n")
cat("Umidade:", atual$relative_humidity_2m, "%\n")
cat("Vento:", atual$wind_speed_10m, "km/h\n\n")

# ── Exibicao da previsao de 5 dias ──
# Percorre cada dia retornado pela API e imprime em formato de tabela
diario <- dados$daily
cat("========== PREVISAO 5 DIAS ==========\n\n")
cat(sprintf("%-12s  %8s  %8s  %10s\n", "Data", "Min(C)", "Max(C)", "Chuva(mm)"))
cat(strrep("-", 44), "\n")

for (i in seq_along(diario$time)) {
  cat(sprintf(
    "%-12s  %8.1f  %8.1f  %10.1f\n",
    diario$time[i],
    diario$temperature_2m_min[i],
    diario$temperature_2m_max[i],
    diario$precipitation_sum[i]
  ))
}

cat("\nFonte: Open-Meteo API (open-meteo.com)\n")
