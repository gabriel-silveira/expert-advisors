#include "./include/inc.mqh"

#include "./indicators/Volume.mqh"

// Objetivo
// 1. Movimento de alta (rally), seguido de um movimento contrário com perda de volume


ENUM_TIMEFRAMES input timeframe       = PERIOD_M5; // Timeframe

double        profitLimit;              // Limite diário de ganho
double        lossLimit;                // Limite diário de perda

double  input inputProfitLimit  = 200;  // Limite diário de ganho

int     input lots              = 1;    // Lots



TradeOrder *Order = new TradeOrder(
  1122339,
  50,
  200,
  1,
  "VAP-v1",
  9,
  16
);



int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, timeframe);

  profitLimit = inputProfitLimit;
  
  lossLimit   = profitLimit / 2;

  InitVolume();
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (Order.ReadyToGo()) {

    CopyVolumeBuffer(5);
    
    CheckSignals();
  }
}


void CheckSignals() {

  Candle *c1 = new Candle(1, 200);
  Candle *c2 = new Candle(2, 200);
  Candle *c3 = new Candle(3, 200);
  
  Print("");
  Print("c1 H: ", c1.getHeight());
  Print("c2 H: ", c2.getHeight());
  Print("c3 H: ", c3.getHeight());
  Print(iVolumesBuffer[3] < iVolumesBuffer[2]);
  Print(iVolumesBuffer[1] > iVolumesBuffer[2]);
  
  if (
    c1.getHeight() > 20
    
    &&
    c2.getTrend() == BEARISH
    &&
    c2.getHeight() > 100
    
    &&
    c3.getTrend() == BEARISH
    &&
    c3.getHeight() > 100
    
    &&
    iVolumesBuffer[2] > iVolumesBuffer[3]
    &&
    iVolumesBuffer[2] > iVolumesBuffer[1]
    
  ) {
  
    Order.Buy();
  
  }
}
