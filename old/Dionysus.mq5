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

string        expertName              = "Dionysus";

double        profitLimit;                              // Limite diário de ganho
double        lossLimit               = 1;              // Limite diário de perda

int           input tp                = 500;            // TP
int           input sl                = 400;            // SL

int           input lots              = 2;              // Lots

int           input minCHeight1       = 180;            // Altura mínima 1
int           input minCHeight2       = 150;            // Altura mínima 2


TradeOrder *Order = new TradeOrder(
  8888,
  tp,
  sl,
  lots,
  expertName,
  9,
  13
);


int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, PERIOD_M5);

  profitLimit = (lots * 100) * 10;
  
  InitAMA(20);
  
  InitVolume();
  
  return(INIT_SUCCEEDED);
}





void OnTick() {
  
  if (
    Candle::newBar()
    &&
    Order.WorkTime()
    &&
    !isEnoughForToday()
    &&
    !PositionSelect(_Symbol)
  ) {

    CopyAMABuffer();
    
    CopyVolumeBuffer();
  
    CheckSignals();
  }
}



void CheckSignals() {
    
  Candle *c1 = new Candle(1, 150);
  Candle *c2 = new Candle(2, 150);
  
  
  if (
    c2.getHeight() > minCHeight1
    &&
    c2.getTrend() == BULLISH
    &&
    c1.getHeight() > minCHeight2
    &&
    c1.getTrend() == BEARISH
    
    &&
    iVolumesBuffer[1] > iVolumesBuffer[2]
  ) {
  
    Order.Sell();
  }
  
  
  if (
    c2.getHeight() > minCHeight1
    &&
    c2.getTrend() == BEARISH
    &&
    c1.getHeight() > minCHeight2
    &&
    c1.getTrend() == BULLISH
    
    &&
    iVolumesBuffer[1] > iVolumesBuffer[2]
  ) {
  
    Order.Buy();
  }
  
  /*
  if (
    // marobozu bullish e em seguida um candle bearish menor
    c2.getHeight() > minMrbzHeight
    &&
    c2.getHeight() > c1.getHeight()
    &&
    c2.getTrend() == BULLISH
    &&
    c1.getTrend() == BEARISH
    
    // o VOLUME do candle menor é consideravelmente menor
    &&
    (iVolumesBuffer[1] / iVolumesBuffer[2]) < dropVolumeFactor
  ) {
    
    if (
      c1.getClose() > iAMABuffer[1]
    )
      Order.Sell();
    else
      Order.Buy();
  }
  */
}



void OnDeinit(const int reason) {

  if(handleVolume != INVALID_HANDLE) IndicatorRelease(handleVolume);
  
  if(handleAMA != INVALID_HANDLE) IndicatorRelease(handleAMA);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}
