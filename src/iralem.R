# FarmTech Solutions - Analise Estatistica para Irrigacao (Ir Alem - Opcional 2)
#
# Simula leituras dos sensores (umidade, pH, NPK) ao longo de 30 dias
# e aplica analise estatistica para recomendar se a bomba deve ser ligada.
#
# Cultura de referencia: Tomate
#   pH ideal: 6.0 a 6.8
#   Umidade ideal: 60% a 80%
#   NPK: todos necessarios

# --- Instalacao de pacotes (se necessario) ---
pacotes <- c("jsonlite")
for (pkg in pacotes) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cran.r-project.org")
  }
}
library(jsonlite)

# --- Parametros ideais para tomate ---
PH_MIN <- 6.0
PH_MAX <- 6.8
UMIDADE_MIN <- 60.0
UMIDADE_MAX <- 80.0

# --- Simulacao de 30 dias de leituras ---
set.seed(42)
n_dias <- 30

dados <- data.frame(
  dia = 1:n_dias,
  umidade = round(runif(n_dias, min = 40, max = 95), 1),
  ph = round(runif(n_dias, min = 4.0, max = 9.0), 1),
  nitrogenio = sample(c(TRUE, FALSE), n_dias, replace = TRUE, prob = c(0.7, 0.3)),
  fosforo = sample(c(TRUE, FALSE), n_dias, replace = TRUE, prob = c(0.6, 0.4)),
  potassio = sample(c(TRUE, FALSE), n_dias, replace = TRUE, prob = c(0.65, 0.35))
)

cat("=== FarmTech Solutions - Analise Estatistica ===\n")
cat("Cultura: Tomate | Periodo: 30 dias simulados\n\n")

# --- Estatisticas descritivas ---
cat("--- Estatisticas Descritivas ---\n\n")

cat("Umidade do solo (%):\n")
cat(sprintf("  Media:         %.1f\n", mean(dados$umidade)))
cat(sprintf("  Desvio Padrao: %.1f\n", sd(dados$umidade)))
cat(sprintf("  Minimo:        %.1f\n", min(dados$umidade)))
cat(sprintf("  Maximo:        %.1f\n", max(dados$umidade)))
cat(sprintf("  Mediana:       %.1f\n\n", median(dados$umidade)))

cat("pH do solo:\n")
cat(sprintf("  Media:         %.1f\n", mean(dados$ph)))
cat(sprintf("  Desvio Padrao: %.1f\n", sd(dados$ph)))
cat(sprintf("  Minimo:        %.1f\n", min(dados$ph)))
cat(sprintf("  Maximo:        %.1f\n", max(dados$ph)))
cat(sprintf("  Mediana:       %.1f\n\n", median(dados$ph)))

cat("Presenca de nutrientes (dias com nutriente presente):\n")
cat(sprintf("  Nitrogenio (N): %d/%d (%.0f%%)\n", sum(dados$nitrogenio), n_dias, mean(dados$nitrogenio) * 100))
cat(sprintf("  Fosforo    (P): %d/%d (%.0f%%)\n", sum(dados$fosforo), n_dias, mean(dados$fosforo) * 100))
cat(sprintf("  Potassio   (K): %d/%d (%.0f%%)\n\n", sum(dados$potassio), n_dias, mean(dados$potassio) * 100))

# --- Analise de correlacao ---
cat("--- Correlacao entre Umidade e pH ---\n")
cor_valor <- cor(dados$umidade, dados$ph)
cat(sprintf("  Coeficiente de correlacao (Pearson): %.3f\n", cor_valor))

if (abs(cor_valor) < 0.3) {
  cat("  Interpretacao: Correlacao fraca\n\n")
} else if (abs(cor_valor) < 0.7) {
  cat("  Interpretacao: Correlacao moderada\n\n")
} else {
  cat("  Interpretacao: Correlacao forte\n\n")
}

# --- Decisao de irrigacao por dia ---
dados$npk_ok <- dados$nitrogenio & dados$fosforo & dados$potassio
dados$ph_ok <- (dados$ph >= PH_MIN) & (dados$ph <= PH_MAX)

dados$irrigar <- ifelse(
  dados$umidade < UMIDADE_MIN, TRUE,
  ifelse(
    dados$umidade > UMIDADE_MAX, FALSE,
    !dados$npk_ok | !dados$ph_ok
  )
)

# --- Resumo das decisoes ---
dias_irrigados <- sum(dados$irrigar)
dias_sem_irrigacao <- n_dias - dias_irrigados

cat("--- Decisao de Irrigacao (30 dias) ---\n")
cat(sprintf("  Dias com irrigacao:  %d (%.0f%%)\n", dias_irrigados, dias_irrigados / n_dias * 100))
cat(sprintf("  Dias sem irrigacao:  %d (%.0f%%)\n\n", dias_sem_irrigacao, dias_sem_irrigacao / n_dias * 100))

# --- Motivos de irrigacao ---
dias_umidade_baixa <- sum(dados$umidade < UMIDADE_MIN)
dias_npk_problema <- sum(dados$umidade >= UMIDADE_MIN & dados$umidade <= UMIDADE_MAX & !dados$npk_ok)
dias_ph_problema <- sum(dados$umidade >= UMIDADE_MIN & dados$umidade <= UMIDADE_MAX & !dados$ph_ok)

cat("--- Motivos de Irrigacao ---\n")
cat(sprintf("  Umidade baixa (<%.0f%%):     %d dias\n", UMIDADE_MIN, dias_umidade_baixa))
cat(sprintf("  NPK insuficiente:          %d dias\n", dias_npk_problema))
cat(sprintf("  pH fora da faixa ideal:    %d dias\n\n", dias_ph_problema))

# --- Teste t: umidade nos dias irrigados vs nao irrigados ---
cat("--- Teste Estatistico (t-test) ---\n")
cat("H0: A media de umidade e igual nos dias irrigados e nao irrigados\n")

grupo_irrigado <- dados$umidade[dados$irrigar]
grupo_nao_irrigado <- dados$umidade[!dados$irrigar]

if (length(grupo_irrigado) > 1 && length(grupo_nao_irrigado) > 1) {
  teste <- t.test(grupo_irrigado, grupo_nao_irrigado)
  cat(sprintf("  Media irrigados:       %.1f%%\n", mean(grupo_irrigado)))
  cat(sprintf("  Media nao irrigados:   %.1f%%\n", mean(grupo_nao_irrigado)))
  cat(sprintf("  p-valor:               %.4f\n", teste$p.value))

  if (teste$p.value < 0.05) {
    cat("  Resultado: Diferenca SIGNIFICATIVA (p < 0.05)\n")
    cat("  A umidade influencia significativamente a decisao de irrigacao.\n\n")
  } else {
    cat("  Resultado: Diferenca NAO significativa (p >= 0.05)\n")
    cat("  Outros fatores (NPK, pH) pesam mais na decisao.\n\n")
  }
} else {
  cat("  Dados insuficientes para o teste.\n\n")
}

# --- Recomendacao final baseada na media ---
cat("--- Recomendacao Final (baseada nas medias) ---\n")

media_umidade <- mean(dados$umidade)
media_ph <- mean(dados$ph)
freq_npk <- mean(dados$npk_ok)

recomendacao <- "MANTER IRRIGACAO NORMAL"

if (media_umidade < UMIDADE_MIN) {
  recomendacao <- "AUMENTAR FREQUENCIA DE IRRIGACAO"
} else if (media_umidade > UMIDADE_MAX) {
  recomendacao <- "REDUZIR FREQUENCIA DE IRRIGACAO"
}

if (media_ph < PH_MIN || media_ph > PH_MAX) {
  cat(sprintf("  ALERTA: pH medio (%.1f) fora da faixa ideal (%.1f-%.1f)\n", media_ph, PH_MIN, PH_MAX))
  cat("  Considerar correcao do solo.\n")
}

if (freq_npk < 0.5) {
  cat("  ALERTA: NPK completo presente em menos de 50% dos dias.\n")
  cat("  Considerar adubacao.\n")
}

cat(sprintf("  Recomendacao: %s\n\n", recomendacao))

# --- Exporta dados para JSON ---
saida <- list(
  cultura = "Tomate",
  periodo_dias = n_dias,
  estatisticas = list(
    umidade_media = round(mean(dados$umidade), 1),
    ph_medio = round(mean(dados$ph), 1),
    dias_irrigados = dias_irrigados,
    dias_sem_irrigacao = dias_sem_irrigacao
  ),
  recomendacao = recomendacao
)

caminho_json <- file.path(dirname(sys.frame(1)$ofile), "resultado_analise.json")
write_json(saida, caminho_json, pretty = TRUE)
cat(sprintf("Dados exportados em: %s\n", caminho_json))
