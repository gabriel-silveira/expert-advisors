#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"


#include "./indicators/Stochastic.mqh"
#include "./indicators/RSI.mqh"


int           expertId        = 6;

string        expertName      = "Estocástico 8 3 3";


bool          backtest        = true; // Backtest


string        symbolName      = _Symbol;  // variável para armazenamento

bool          restrictedHours = true;     // Restringir horários?
int           hourToStart     = 9;       // Início
int           hourToFinish    = 17;       // Término

double        profitLimit     = 2500;      // Limite diário de ganho
double        lossLimit       = 1000;      // Limite diário de perda


double input tp = 10000;
double input sl = 10000;


int OnInit() {
  
  setMagicNumber(expertId);
  
  InitStochastic(8, 3, 3);
  
  InitRSI(8);
  
  strategy.target   = tp;
  strategy.stopLoss = sl;
  strategy.lots     = 1;
  
  return(INIT_SUCCEEDED);
}


void OnTick() {
  
  if (!restrictHours()) {
  
    if (Candle::newBar()) {
      
      if (!PositionSelect(symbolName)) {
      
        CopyStochasticBuffers();
        
        CopyRSIBuffers();
      
        Candle *c1 = new Candle(1, 0);
      
        if (
          StochasticBuffer[1] > 90
          &&
          iRSIBuffer[1] >= 75
          &&
          c1.getHeight() < 1
        ) {
        
          Print((string)(StochasticBuffer[2] - StochasticBuffer[1]));
          
          // ExpertRemove();
          SellAtMarket(StochasticBuffer[1], SignalBuffer[1]);
        }
      }
    }
  }
}


void OnDeinit(const int reason) {

  if(handleStoch != INVALID_HANDLE) IndicatorRelease(handleStoch);
  
  Comment("");
}


