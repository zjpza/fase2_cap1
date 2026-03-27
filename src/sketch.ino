/*
 * FarmTech Solutions - Sistema de Irrigacao Inteligente
 * Cultura de referencia: Tomate
 *
 * Sensores simulados no Wokwi:
 *   - 3 botoes: Nitrogenio (N), Fosforo (P), Potassio (K)
 *   - LDR: simula sensor de pH do solo
 *   - DHT22: simula umidade do solo
 *   - Rele azul: simula bomba d'agua
 *
 * Parametros ideais para tomate:
 *   - pH: 6.0 a 6.8
 *   - Umidade do solo: 60% a 80%
 *   - NPK: todos necessarios (N=true, P=true, K=true)
 */

#include <DHT.h>

// --- Pinos ---
const int PIN_BUTTON_N   = 12;
const int PIN_BUTTON_P   = 14;
const int PIN_BUTTON_K   = 27;
const int PIN_LDR        = 34;  // entrada analogica
const int PIN_DHT        = 15;
const int PIN_RELAY      = 26;

// --- Configuracao DHT22 ---
const int DHT_TYPE = DHT22;
DHT dht(PIN_DHT, DHT_TYPE);

// --- Parametros ideais para tomate ---
const float PH_MIN          = 6.0;
const float PH_MAX          = 6.8;
const float UMIDADE_MIN     = 60.0;
const float UMIDADE_MAX     = 80.0;
const int   LDR_ANALOG_MAX  = 4095;  // resolucao ADC 12 bits do ESP32
const float PH_SCALE_MAX    = 14.0;

// --- Intervalo de leitura (ms) ---
const unsigned long INTERVALO_LEITURA = 2000;
unsigned long ultimaLeitura = 0;

// --- Funcao: converte leitura analogica do LDR em pH (0-14) ---
float ldrParaPh(int leituraAnalogica) {
  return (float)leituraAnalogica / LDR_ANALOG_MAX * PH_SCALE_MAX;
}

// --- Funcao: decide se deve irrigar ---
bool deveIrrigar(bool n, bool p, bool k, float ph, float umidade) {
  // Se a umidade esta acima do maximo, nao irriga (solo ja esta umido)
  if (umidade > UMIDADE_MAX) {
    return false;
  }

  // Se a umidade esta abaixo do minimo, irriga independente do resto
  if (umidade < UMIDADE_MIN) {
    return true;
  }

  // Na faixa intermediaria (60-80%), verifica NPK e pH
  bool npkOk = n && p && k;
  bool phOk  = (ph >= PH_MIN) && (ph <= PH_MAX);

  // Se nutrientes e pH estao adequados, nao precisa irrigar
  // Se algum esta fora, irriga pra ajudar na absorcao
  if (!npkOk || !phOk) {
    return true;
  }

  return false;
}

void setup() {
  Serial.begin(115200);
  Serial.println("=== FarmTech Solutions - Irrigacao Inteligente ===");
  Serial.println("Cultura: Tomate");
  Serial.println("Parametros ideais:");
  Serial.print("  pH: ");
  Serial.print(PH_MIN);
  Serial.print(" - ");
  Serial.println(PH_MAX);
  Serial.print("  Umidade: ");
  Serial.print(UMIDADE_MIN);
  Serial.print("% - ");
  Serial.print(UMIDADE_MAX);
  Serial.println("%");
  Serial.println("  NPK: todos necessarios");
  Serial.println("=========================================\n");

  // Configura pinos dos botoes com pull-up interno
  pinMode(PIN_BUTTON_N, INPUT_PULLUP);
  pinMode(PIN_BUTTON_P, INPUT_PULLUP);
  pinMode(PIN_BUTTON_K, INPUT_PULLUP);

  // Configura pino do rele como saida
  pinMode(PIN_RELAY, OUTPUT);
  digitalWrite(PIN_RELAY, LOW);

  // Inicializa DHT22
  dht.begin();
}

void loop() {
  unsigned long agora = millis();

  if (agora - ultimaLeitura < INTERVALO_LEITURA) {
    return;
  }
  ultimaLeitura = agora;

  // --- Leitura dos sensores ---

  // Botoes NPK (pull-up: LOW = pressionado = nutriente presente)
  bool nitrogenio = (digitalRead(PIN_BUTTON_N) == LOW);
  bool fosforo    = (digitalRead(PIN_BUTTON_P) == LOW);
  bool potassio   = (digitalRead(PIN_BUTTON_K) == LOW);

  // LDR -> pH
  int ldrRaw = analogRead(PIN_LDR);
  float ph   = ldrParaPh(ldrRaw);

  // DHT22 -> Umidade
  float umidade = dht.readHumidity();

  if (isnan(umidade)) {
    Serial.println("[ERRO] Falha ao ler DHT22. Verifique a conexao.");
    return;
  }

  // --- Decisao de irrigacao ---
  bool irrigar = deveIrrigar(nitrogenio, fosforo, potassio, ph, umidade);

  // Aciona rele
  digitalWrite(PIN_RELAY, irrigar ? HIGH : LOW);

  // --- Exibe no Monitor Serial ---
  Serial.println("--- Leitura dos Sensores ---");
  Serial.print("  Nitrogenio (N): ");
  Serial.println(nitrogenio ? "PRESENTE" : "AUSENTE");
  Serial.print("  Fosforo    (P): ");
  Serial.println(fosforo ? "PRESENTE" : "AUSENTE");
  Serial.print("  Potassio   (K): ");
  Serial.println(potassio ? "PRESENTE" : "AUSENTE");
  Serial.print("  pH do solo:     ");
  Serial.print(ph, 1);
  Serial.print(" (LDR raw: ");
  Serial.print(ldrRaw);
  Serial.println(")");
  Serial.print("  Umidade solo:   ");
  Serial.print(umidade, 1);
  Serial.println("%");
  Serial.println("--- Decisao ---");
  Serial.print("  Bomba d'agua:   ");
  Serial.println(irrigar ? "LIGADA" : "DESLIGADA");

  // Motivo da decisao
  if (umidade > UMIDADE_MAX) {
    Serial.println("  Motivo: Umidade acima do maximo. Solo ja esta umido.");
  } else if (umidade < UMIDADE_MIN) {
    Serial.println("  Motivo: Umidade abaixo do minimo. Irrigacao necessaria.");
  } else {
    bool npkOk = nitrogenio && fosforo && potassio;
    bool phOk  = (ph >= PH_MIN) && (ph <= PH_MAX);
    if (!npkOk) {
      Serial.println("  Motivo: Nutrientes NPK insuficientes. Irrigando para auxiliar absorcao.");
    }
    if (!phOk) {
      Serial.print("  Motivo: pH fora da faixa ideal (");
      Serial.print(PH_MIN);
      Serial.print("-");
      Serial.print(PH_MAX);
      Serial.println("). Irrigando para correcao.");
    }
    if (npkOk && phOk) {
      Serial.println("  Motivo: Todos os parametros adequados. Irrigacao nao necessaria.");
    }
  }
  Serial.println();
}
