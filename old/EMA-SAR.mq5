#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"

#include "./indicators/CrossingMAs.mqh"

#include "./indicators/SAR.mqh"

string        symbolName            = _Symbol;      // variável para armazenamento
bool          backtest              = false;        // Backtest
bool          restrictedHours       = true;         // Restringir horários?
int           hourToStart           = 10;           // Início
int           hourToFinish          = 16;           // Término

double        input profitLimit     = 1000;          // Limite diário de ganho
double        input lossLimit       = 100;          // Limite diário de perda

double        input tp       = 50000;          // Take profit
double        input sl       = 50000;          // Stop loss



int OnInit() {
  
  setMagicNumber(321);
  
  InitEMA(8);
  
  InitSAR();
  
  strategy.lots     = 10;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
    
    Candle *c1 = new Candle(1, 6);
    Candle *c2 = new Candle(2, 6);
    
    CopyEMABuffer();
    CopySARBuffer();
    
    
    double currentBalance = getCurrentBalance();
    
    if (!restrictHours() && !isEnoughForToday(currentBalance)) {
    
      if (
        !PositionSelect(symbolName)
      ) {
        
        if (
          iSARBuffer[2] < c2.getClose()
          &&
          iSARBuffer[1] > c1.getClose()
        ) {
          Print("VENDA");
          currentPrice = SellAtMarket(iSARBuffer[2], iSARBuffer[1]);
        }
        
        // Print("SAR: ", iSARBuffer[1]);
      } else {
      
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
        
            if (
            iSARBuffer[2] > c2.getClose()
            &&
            iSARBuffer[1] < c1.getClose()
          ) {
            ClosePosition();
          }
        }
      }
    } else if (PositionSelect(symbolName)) {
      
      if (currentPrice > c1.getClose()) {
        
        ClosePosition(); 
      }
    }
  }
}



void OnDeinit(const int reason) {
  
  if(SARhandle != INVALID_HANDLE) IndicatorRelease(SARhandle);
}