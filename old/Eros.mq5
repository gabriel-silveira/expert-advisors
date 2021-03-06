#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Estratégia:"
#property description "1. Três candles de baixa com volume em queda, sinalizando compra."
#property description "2. Três candles de alta com volume em queda, sinalizando venda ou compra (se acima da SMA 20)."
#property description "\n"
#property description "Objetivo:"
#property description "Buscar lucro de R$ 400 por negociação / loss de R$ 150"
#property description "\n"
#property description "Alvo:"
#property description "400 pontos, 5 lotes"
#property description "\n"
#property description "Lucro / Risco:"
#property description "Baixa 0.37"

#include "./include/inc.mqh"

#include "./indicators/CrossingMAs.mqh"
#include "./indicators/Volume.mqh"

string        expertName            = "Eros";

double        profitLimit;                            // Limite diário de ganho
double        lossLimit             = 1;              // Limite diário de perda

double        input tp              = 400;            // TP
double        input sl              = 150;            // SL

int           input lots            = 5;              // Lots

int           input minCandleHeight = 1;              // Min candle height


TradeOrder *Order = new TradeOrder(
  777999,
  tp,
  sl,
  lots,
  expertName,
  10,
  14
);


int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, PERIOD_M5);

  profitLimit = (lots * (tp * 0.2)) * 10;
  
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
  Candle *c3 = new Candle(3, 150);
  
  
  if (
    c1.getHeight() > minCandleHeight
    &&
    c2.getHeight() > minCandleHeight
    &&
    c3.getHeight() > minCandleHeight
    
    &&
    c1.getTrend() == BEARISH
    &&
    c2.getTrend() == BEARISH
    &&
    c3.getTrend() == BEARISH
    
    &&
    iVolumesBuffer[1] < iVolumesBuffer[2]
    &&
    iVolumesBuffer[2] < iVolumesBuffer[3]
  ) {
    
    Order.Buy();
  }
  
  
  if (
    c1.getHeight() > minCandleHeight
    &&
    c2.getHeight() > minCandleHeight
    &&
    c3.getHeight() > minCandleHeight
    
    &&
    c1.getTrend() == BULLISH
    &&
    c2.getTrend() == BULLISH
    &&
    c3.getTrend() == BULLISH
    
    &&
    iVolumesBuffer[1] < iVolumesBuffer[2]
    &&
    iVolumesBuffer[2] < iVolumesBuffer[3]
  ) {
    
    
    if (c1.getClose() > iAMABuffer[1])
      Order.Buy();
    else
      Order.Sell();
  }
}
