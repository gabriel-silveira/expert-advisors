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


double input tp = 40000;
double input sl = 20000;


int OnInit() {
  
  setMagicNumber(expertId);
  
  InitStochastic(14, 3, 3);
  
  InitRSI(8);
  
  strategy.target   = tp;
  strategy.stopLoss = sl;
  strategy.lots     = 1;
  
  return(INIT_SUCCEEDED);
}


void OnTick() {
  
  if (!restrictHours()) {
  
    if (Candle::newBar()) {
      
      CopyStochasticBuffers();
      
      CopyRSIBuffers();
      
      if (!PositionSelect(symbolName)) {
      
        Candle *c1 = new Candle(1, 0);
    
        Print("Day open price: ", (string) getDayOpenPrice());
        Print("Close price: ", (string) c1.getClose());
        Print("Sum: ", (string) (getDayOpenPrice() + 70));
      
        if (
          c1.getClose() > getDayOpenPrice() + 70
          &&
          StochasticBuffer[1] > 90
        ) {
          SellAtMarket(StochasticBuffer[1], SignalBuffer[1]);
        }
        
        if (
          c1.getClose() < getDayOpenPrice() - 70
          &&
          StochasticBuffer[1] < 10
        ) {
          BuyAtMarket(StochasticBuffer[1], SignalBuffer[1]);
        }
        
        /*
        if (
            StochasticBuffer[1] < 10
        ) {
          
          BuyAtMarket(StochasticBuffer[1], SignalBuffer[1]);
        }*/
      }
      /*
      if (
        (
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
          &&
          StochasticBuffer[1] < 20
        )
        ||
        (
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
          &&
          StochasticBuffer[1] > 80
        )
      ) {
        
        ClosePosition();
      }*/
    }
  }
}


void OnDeinit(const int reason) {

  if(handleStoch != INVALID_HANDLE) IndicatorRelease(handleStoch);
  
  Comment("");
}




double getDayOpenPrice() {

  MqlRates rate[];
  
  CopyRates(Symbol(), PERIOD_D1, 0, 1, rate);
  
  return rate[0].open;
}
