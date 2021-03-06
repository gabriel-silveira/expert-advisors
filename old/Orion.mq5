#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Estratégia:"
#property description "Após um candle de alta com corpo acima de 15 pts e volume maior que 30000: compra."
#property description "\n"
#property description "Objetivo:"
#property description "Busca lucro de R$ 100 por negociação / loss de R$ 200"
#property description "\n"
#property description "Alvo:"
#property description "10 pontos, 1 lote"
#property description "\n"
#property description "Lucro / Risco:"
#property description "Muito alto 2.0"

#include "./include/inc.mqh"

#include "./indicators/Volume.mqh"
#include "./indicators/CrossingMAs.mqh"

string        expertName            = "Orion";

double        profitLimit;                            // Limite diário de ganho
double        lossLimit             = 9999;              // Limite diário de perda

double        input tp              = 10000;          // TP
double        input sl              = 20000;          // SL

int           input lots            = 1;              // Lotes


TradeOrder *Trade = new TradeOrder(
  100000,
  tp,
  sl,
  lots,
  expertName,
  9,
  16
);


int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, PERIOD_M5);

  profitLimit = (lots * (tp / 100)) * 10;
  
  InitAMA(20);
  
  InitVolume();
  
  return(INIT_SUCCEEDED);
}


void OnTick() {


  if (
    Trade.ReadyToGo()
  ) {
  
    CopyVolumeBuffer();
    
    CopyAMABuffer();
    
    Candle *c1 = new Candle(1, 6);
    Candle *c2 = new Candle(2, 6);
    Candle *c3 = new Candle(3, 6);
    
    if (
      c1.getHeight() > 15
      &&
      c1.getTrend() == BEARISH
      &&
      iVolumesBuffer[1] > 30000
    ) {
      
      Trade.Sell();
    }
    
    if (
      c1.getHeight() > 15
      &&
      c1.getTrend() == BULLISH
      &&
      iVolumesBuffer[1] > 30000
    ) {
      
      Trade.Buy();
    }
  }
}
