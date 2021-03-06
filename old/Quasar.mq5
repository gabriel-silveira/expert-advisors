#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Estratégia:"
#property description "1. Queda brusca com aumento de volume, sinalizando venda."
#property description "2. Alta brusca com aumento de volume, sinalizando compra."
#property description "\n"
#property description "Objetivo:"
#property description "Buscar lucro de R$ 200 por negociação / loss de R$ 160"
#property description "\n"
#property description "Alvo:"
#property description "400 pontos, 2 lotes"
#property description "\n"
#property description "Lucro / Risco:"
#property description "Alta 0.8"

#include "./include/inc.mqh"

#include "./indicators/CrossingMAs.mqh"
#include "./indicators/Volume.mqh"

string        expertName              = "Quasar";

double        profitLimit;                              // Limite diário de ganho
double        input lossLimit         = 1;              // Limite diário de perda

int           input tp                = 25;             // TP
int           input sl                = 150;            // SL

int           input lots              = 1;              // Lots

int           input minVolume         = 20000;          // Volume mínimo

TradeOrder *Order = new TradeOrder(
  7654321,
  tp,
  sl,
  lots,
  expertName,
  9,
  17
);


int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, PERIOD_M5);

  profitLimit = (lots * 100) * 30;
  
  InitAMA(20);
  
  InitVolume();
  
  return(INIT_SUCCEEDED);
}





void OnTick() {
  
  if (
    Order.ReadyToGo()
  ) {

    CopyAMABuffer();
    
    CopyVolumeBuffer();
  
    CheckSignals();
  }
}



void CheckSignals() {
    
  Candle *c1 = new Candle(1, 150);
  
  if (
    iVolumesBuffer[1] > minVolume
  ) {
    
    if (
      c1.getTrend() == BULLISH
    ) {
    
      Order.Buy();
    } else {
    
      Order.Sell();
    }
  }
}



void OnDeinit(const int reason) {

  if(handleVolume != INVALID_HANDLE) IndicatorRelease(handleVolume);
  
  if(handleAMA != INVALID_HANDLE) IndicatorRelease(handleAMA);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}
