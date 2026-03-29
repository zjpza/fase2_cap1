"""
FarmTech Solutions - Integracao com API Meteorologica (Ir Alem - Opcional 1)

Consulta a API publica Open-Meteo para obter dados climaticos
e sugere se a irrigacao deve ser suspensa com base na previsao de chuva.

Os dados podem ser transferidos manualmente para o ESP32 via Monitor Serial
ou copiados para uma variavel no codigo C/C++.

Localizacao padrao: Piracicaba-SP (polo agricola)
"""
from __future__ import annotations

import json
import logging
import sys
from datetime import datetime
from decimal import Decimal
from pathlib import Path

import requests

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

# --- Configuracao ---
LATITUDE = -22.7249
LONGITUDE = -47.6493
CIDADE = "Piracicaba-SP"

# Limite de chuva (mm) para suspender irrigacao
LIMITE_CHUVA_MM = Decimal("5.0")

API_URL = "https://api.open-meteo.com/v1/forecast"


def buscar_previsao(latitude: float, longitude: float) -> dict:
    """Consulta a API Open-Meteo e retorna os dados meteorologicos."""
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": "temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m",
        "daily": "precipitation_sum,precipitation_probability_max,temperature_2m_max,temperature_2m_min",
        "timezone": "America/Sao_Paulo",
        "forecast_days": 5,
    }

    response = requests.get(API_URL, params=params, timeout=10)
    response.raise_for_status()
    return response.json()


def exibir_dados_atuais(dados: dict) -> None:
    """Exibe as condicoes climaticas atuais."""
    current = dados["current"]

    logger.info("=== Condicoes Atuais - %s ===", CIDADE)
    logger.info("Temperatura: %.1f C", current["temperature_2m"])
    logger.info("Umidade do ar: %d%%", current["relative_humidity_2m"])
    logger.info("Precipitacao: %.1f mm", current["precipitation"])
    logger.info("Vento: %.1f km/h", current["wind_speed_10m"])


def exibir_previsao(dados: dict) -> list[dict]:
    """Exibe a previsao dos proximos dias e retorna os dados formatados."""
    daily = dados["daily"]
    previsoes = []

    logger.info("")
    logger.info("=== Previsao para os proximos 5 dias ===")
    logger.info(
        "%-12s | %6s | %6s | %10s | %12s",
        "Data", "Min", "Max", "Chuva(mm)", "Prob. Chuva",
    )
    logger.info("-" * 60)

    for i in range(len(daily["time"])):
        data = daily["time"][i]
        temp_min = daily["temperature_2m_min"][i]
        temp_max = daily["temperature_2m_max"][i]
        chuva_mm = Decimal(str(daily["precipitation_sum"][i]))
        prob_chuva = daily["precipitation_probability_max"][i]

        logger.info(
            "%-12s | %5.1f C | %5.1f C | %8s mm | %10d%%",
            data, temp_min, temp_max, chuva_mm, prob_chuva,
        )

        previsoes.append({
            "data": data,
            "temp_min": temp_min,
            "temp_max": temp_max,
            "chuva_mm": str(chuva_mm),
            "prob_chuva": prob_chuva,
        })

    return previsoes


def analisar_irrigacao(dados: dict) -> dict:
    """Analisa se a irrigacao deve ser suspensa com base na previsao."""
    daily = dados["daily"]

    chuva_hoje = Decimal(str(daily["precipitation_sum"][0]))
    chuva_amanha = Decimal(str(daily["precipitation_sum"][1]))
    prob_hoje = daily["precipitation_probability_max"][0]
    prob_amanha = daily["precipitation_probability_max"][1]

    suspender = False
    motivos = []

    if chuva_hoje >= LIMITE_CHUVA_MM:
        suspender = True
        motivos.append(f"Chuva prevista hoje: {chuva_hoje} mm (limite: {LIMITE_CHUVA_MM} mm)")

    if chuva_amanha >= LIMITE_CHUVA_MM:
        suspender = True
        motivos.append(f"Chuva prevista amanha: {chuva_amanha} mm (limite: {LIMITE_CHUVA_MM} mm)")

    if prob_hoje >= 70:
        suspender = True
        motivos.append(f"Probabilidade de chuva hoje: {prob_hoje}%")

    if prob_amanha >= 70:
        suspender = True
        motivos.append(f"Probabilidade de chuva amanha: {prob_amanha}%")

    logger.info("")
    logger.info("=== Recomendacao de Irrigacao ===")

    if suspender:
        logger.info("SUSPENDER IRRIGACAO")
        for motivo in motivos:
            logger.info("  - %s", motivo)
    else:
        logger.info("MANTER IRRIGACAO NORMAL")
        logger.info("  - Sem previsao significativa de chuva")

    return {
        "suspender_irrigacao": suspender,
        "motivos": motivos,
        "chuva_hoje_mm": str(chuva_hoje),
        "chuva_amanha_mm": str(chuva_amanha),
    }


def gerar_dados_esp32(resultado: dict) -> None:
    """Gera o trecho de codigo C para copiar no ESP32."""
    valor = 1 if resultado["suspender_irrigacao"] else 0

    logger.info("")
    logger.info("=== Dados para o ESP32 (copie para o codigo C/C++) ===")
    logger.info("")
    logger.info("// Dados meteorologicos - gerado em %s", datetime.now().strftime("%Y-%m-%d %H:%M"))
    logger.info("int previsaoChuva = %d;  // 0 = sem chuva, 1 = chuva prevista", valor)
    logger.info("")
    logger.info(
        "Ou envie '%d' pelo Monitor Serial do Wokwi (usando Serial.read())",
        valor,
    )


def salvar_json(previsoes: list[dict], resultado: dict) -> None:
    """Salva os dados em JSON para consulta posterior."""
    output = {
        "cidade": CIDADE,
        "data_consulta": datetime.now().isoformat(),
        "previsoes": previsoes,
        "recomendacao": resultado,
    }

    caminho = Path(__file__).parent / "dados_climaticos.json"
    caminho.write_text(json.dumps(output, indent=2, ensure_ascii=False), encoding="utf-8")
    logger.info("")
    logger.info("Dados salvos em: %s", caminho)


def main() -> None:
    """Executa o fluxo completo de consulta e analise."""
    logger.info("FarmTech Solutions - Consulta Meteorologica")
    logger.info("Localizacao: %s (%.4f, %.4f)", CIDADE, LATITUDE, LONGITUDE)
    logger.info("")

    try:
        dados = buscar_previsao(LATITUDE, LONGITUDE)
    except requests.ConnectionError:
        logger.error("Sem conexao com a internet. Verifique sua rede.")
        sys.exit(1)
    except requests.HTTPError as e:
        logger.error("Erro na API: %s", e)
        sys.exit(1)
    except requests.Timeout:
        logger.error("Timeout ao consultar a API. Tente novamente.")
        sys.exit(1)

    exibir_dados_atuais(dados)
    previsoes = exibir_previsao(dados)
    resultado = analisar_irrigacao(dados)
    gerar_dados_esp32(resultado)
    salvar_json(previsoes, resultado)


if __name__ == "__main__":
    main()
