#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"


// indicador CMAs
#include "./indicators/Stochastic.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int           expertId        = 6;

string        expertName      = "Estocástico 80";


bool  input   backtest        = false; // Backtest


//+------------------------------------------------------------------+
//| CANDLE HEIGHT                                                    |
//+------------------------------------------------------------------+
bool          isMiniDolar     = StringFind(_Symbol, "WDO") != -1;

int           mrbzHeight      = isMiniDolar ? 10 : 100;

int           dojiHeight      = isMiniDolar ?  2 :  20;



string        symbolName      = _Symbol;  // variável para armazenamento

bool          restrictedHours = true;     // Restringir horários?
int           hourToStart     = 10;       // Início
int           hourToFinish    = 16;       // Término

double        profitLimit     = 200;      // Limite diário de ganho
double        lossLimit       = 50;       // Limite diário de perda


double input tp = 40000;
double input sl = 21000;


int OnInit() {
  
  setMagicNumber(expertId);
  
  candlesToClose = 10;
  
  
  if (backtest) {
  
    strategy.id       = 999;
    strategy.symbol   = _Symbol;
    strategy.name     = expertName + "Backtest";
    strategy.lots     = isMiniDolar ?     1 :   10;
    strategy.target   = isMiniDolar ?    tp :  100;
    strategy.stopLoss = isMiniDolar ?    sl : 2500;
    
  } else {
  
    if (setStrategy(expertId, symbolName)) {
    
      profitLimit     = strategy.goal;
      lossLimit       = strategy.riskLimit;
      
      if (!CreateControlPanel(expertName)) return(INIT_FAILED);
    }
  }
  
  InitStochastic(14, 3, 3);
  
  return(INIT_SUCCEEDED);
}



double getDayOpenPrice() {

  MqlRates rate[];
  
  CopyRates(Symbol(), PERIOD_D1, 0, 1, rate);
  
  return rate[0].open;
}


datetime getHour() {

  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  return structNow.hour;
}


void OnTick() {

  checkPositionStatus();
  
  if (!restrictHours()) {
    
    if (!PositionSelect(symbolName)) {
    
      Candle *candle1 = new Candle(1, 0);
      
      if (candle1.getClose() > getDayOpenPrice())
          currentPrice = BuyAtMarket(1, 2);
        else
          currentPrice = SellAtMarket(1, 2);
          
      candleCount = 0;
      
    }
  }
}



void checkPositionStatus() {

  if (PositionSelect(_Symbol)) {
  
    if (Candle::newBar()) {
    
      candleCount++;
      
      if (
        candleCount > 30
      ) {
      
        SymbolInfoTick(_Symbol, tick);
        
        if (
          getHour() > 16
        ) {
        
          if (
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
            &&
            tick.last > currentPrice
          ) {
            ClosePosition();
          }
          
          if (
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
            &&
            tick.last < currentPrice
          ) {
            ClosePosition();
          }
        
        }/* else {
      
          // comprado
          if (
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
            &&
            tick.last > (NormalizeDouble(currentPrice + sl * _Point, _Digits))
          ) {
          
            ClosePosition();
          }
          
          // vendido
          if (
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
            &&
            tick.last < (NormalizeDouble(currentPrice - sl * _Point, _Digits))
          ) {
          
            ClosePosition();
          }
        }*/
      }
    }
  }
}



void OnDeinit(const int reason) {

  if(handleStoch != INVALID_HANDLE) IndicatorRelease(handleStoch);
  
  ExtDialog.Destroy(reason);
  
  Comment("");
}


