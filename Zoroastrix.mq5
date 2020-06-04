#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int           expertId        = 6;

string        expertName      = "ZOROASTRIX";


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

double        profitLimit     = 400;      // Limite diário de ganho
double        lossLimit       = 50;       // Limite diário de perda


double input tp = 40000;
double input sl = 21000;


int profitCount = 0;

int lossCount   = 0;



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
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  

  if (Candle::newBar()) {

    checkPositionStatus();
    
    if (Candle::newDay()) {
    
      previousBalance = getCurrentBalance();
    
      profitCount = 0;
      
      lossCount = 0;
    }
    
    double currentBalance = getCurrentBalance();
    
    
    if (getHour() > 9) {
  
      if (currentBalance > previousBalance) {
      
        profitCount++;
        
      } else if (currentBalance < previousBalance) {
      
        lossCount++;
      
      } else {
      
        Print("Lucros: ", profitCount);
        
        if (
          !PositionSelect(symbolName)
          &&
          !(profitCount == 2 && lossCount == 0)
          &&
          !(profitCount == 1 && lossCount == 1)
          &&
          lossCount < 2
        ) {
        
          Candle *candle1 = new Candle(1, 0);
          
          if (candle1.getClose() > getDayOpenPrice())
              currentPrice = BuyAtMarket(1, 2);
            else
              currentPrice = SellAtMarket(1, 2);
              
          candleCount = 0;
        }
      }
    }
    
    previousBalance = currentBalance;
      
    /*
    MqlDateTime structNow;
    
    TimeToStruct(TimeCurrent(), structNow);
    
    
    if (structNow.hour > 9) {
    
      if (profitCount == 1 && lossCount == 0) {
      
      } else {
    
    
        if (currentBalance > previousBalance) {
        
          profitCount++;
          
          Print("Lucros: ", profitCount);
          Print("Perdas: ", lossCount);
        } else if (currentBalance < previousBalance) {
          
          lossCount++;
          
          Print("Lucros: ", profitCount);
          Print("Perdas: ", lossCount);
        }
        
        
        if (!PositionSelect(symbolName) && profitCount < 2) {
        
          Candle *candle1 = new Candle(1, 0);
          
          if (candle1.getClose() > getDayOpenPrice())
              currentPrice = BuyAtMarket(1, 2);
            else
              currentPrice = SellAtMarket(1, 2);
              
          candleCount = 0;
          
        }

        previousBalance = currentBalance;
      }
    }*/
  }
}



void checkPositionStatus() {

  if (PositionSelect(_Symbol)) {
  
    candleCount++;
    
    if (
      candleCount > 10
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
          
        } else if (
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
          &&
          tick.last < currentPrice
        ) {
        
          ClosePosition();
        }
      
      }
    }
  }
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


void OnDeinit(const int reason) {
  
  ExtDialog.Destroy(reason);
  
  Comment("");
}


