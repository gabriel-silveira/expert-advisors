#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"

#include "./indicators/CrossingMAs.mqh"

string        symbolName            = _Symbol;      // variável para armazenamento
bool          backtest              = false;        // Backtest
bool          restrictedHours       = true;         // Restringir horários?
int           hourToStart           = 10;           // Início
int           hourToFinish          = 16;           // Término

double        input profitLimit     = 600;          // Limite diário de ganho
double        input lossLimit       = 100;          // Limite diário de perda

double        input tp       = 100;          // Take profit
double        input sl       = 100;          // Stop loss

int OnInit() {
  
  setMagicNumber(321);
  
  InitAMA(20);
  
  strategy.lots     = 1;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
  
    if (
      !PositionSelect(symbolName)
    ) {
      CopyAMABuffer();
      
      Candle *c1 = new Candle(1, 6);
      
      if (
        c1.getOpen() < iAMABuffer[1]
        &&
        c1.getClose() > iAMABuffer[1]
      ) {
        BuyAtMarket(c1.getClose(), iAMABuffer[1]);
      }
    }
  }
}


