# =============================================================================
# FarmTech Solutions - Estatisticas basicas em R
# Objetivo: calcular media, desvio padrao, minimo e maximo dos dados
#           coletados no sistema Python (areas, insumos e ruas).
# Execucao: Rscript estatisticas.R
# =============================================================================

# ── Vetores de exemplo (simulando dados cadastrados no Python) ──
areas    <- c(1500.0, 2356.19, 800.0, 1200.5, 3100.0)  # area de cada talhao em m2
insumos  <- c(12.0, 18.84, 6.4, 9.6, 24.8)             # quantidade de insumo em litros
ruas     <- c(80, 120, 50, 70, 150)                     # numero de ruas por talhao

# --- Estatisticas de Area (m2) ---
# mean() calcula a media aritmetica, sd() o desvio padrao amostral
cat("========== AREA (m2) ==========\n")
cat("Dados:", areas, "\n")
cat("Media:", round(mean(areas), 2), "m2\n")
cat("Desvio padrao:", round(sd(areas), 2), "m2\n")
cat("Minimo:", min(areas), "m2\n")
cat("Maximo:", max(areas), "m2\n\n")

# --- Estatisticas de Insumos (L) ---
cat("========== INSUMOS (L) ==========\n")
cat("Dados:", insumos, "\n")
cat("Media:", round(mean(insumos), 2), "L\n")
cat("Desvio padrao:", round(sd(insumos), 2), "L\n")
cat("Minimo:", min(insumos), "L\n")
cat("Maximo:", max(insumos), "L\n\n")

# --- Estatisticas de Ruas ---
cat("========== RUAS ==========\n")
cat("Dados:", ruas, "\n")
cat("Media:", round(mean(ruas), 2), "\n")
cat("Desvio padrao:", round(sd(ruas), 2), "\n")
cat("Minimo:", min(ruas), "\n")
cat("Maximo:", max(ruas), "\n")
