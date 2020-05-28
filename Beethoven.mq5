#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "BEETHOVEN"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"


// indicador CMAs
#include "./indicators/CrossingMAs.mqh"

// painel do expert
#include "./include/Panel-Beethoven.mqh"



int expertId = 1;



//--- variável para armazenamento
string  symbolName        = _Symbol;

bool    restrictedHours   = true;   // Restringir horários?
int     hourToStart       = 10;     // Início
int     hourToFinish      = 17;     // Término

int     profitLimit       = 9999;   // Limite diário de ganho
int     lossLimit         = 9999;   // Limite diário de perda

int     mrbzheight        = 100;

bool    crossedUp         = false;

bool    invertSignal      = false;



int OnInit() {
  
  setMagicNumber(expertId);
  
  string strategies[];
  
  if (getExpertStrategies(expertId, strategies)) {
    
    if (setStrategy(strategies)) {
    
      initCrossingMAs();
      
      if (!CreateControlPanel()) return(INIT_FAILED);
    }
  }
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (!restrictHours()) {
      
    double currentBalance = getCurrentBalance();
  
    if (isEnoughForToday(currentBalance)) {
    
      if (previousBalance != currentBalance) {
      
        Print("Lucro do dia atingido! ", currentBalance);
        Print("- - - - - - - - - - - - - - -");
      }
    } else {
      
      if (Candle::newBar()) {
      
        // registar última negociação
        if (previousBalance != currentBalance) {
          
          registerLastDeal(1, 1);
        }
        
        CopyCrossingMAsBuffers();
        
        if (!PositionSelect(symbolName)) {
        
          if (!checkExceptions()) {
          
            checkSignal();
          }
        } else {
          
          checkPosition();
        }
    
        previousBalance = currentBalance;
      }
    }
  }
}



void OnDeinit(const int reason) {

  if(handleAMA != INVALID_HANDLE) IndicatorRelease(handleAMA);
  if(handleEMA != INVALID_HANDLE) IndicatorRelease(handleEMA);
  
  ExtDialog.Destroy(reason);
  
  Comment("");
}



bool checkExceptions() {

  Candle *candle1 = new Candle(1, mrbzheight);
  Candle *candle2 = new Candle(2, mrbzheight);
  Candle *candle3 = new Candle(3, mrbzheight);
  Candle *candle4 = new Candle(4, mrbzheight);
  
  bool skip = false;
  
  // evitar marobozus
  // evitar soldados de alta ou baixa
  if (
    (candle1.getHeight() > mrbzheight || candle2.getHeight() > mrbzheight)
    ||
    (
         candle1.getTrend() == BULLISH
      && candle2.getTrend() == BULLISH
      && candle3.getTrend() == BULLISH
      && candle4.getTrend() == BULLISH
    )
    ||
    (
         candle1.getTrend() == BEARISH
      && candle2.getTrend() == BEARISH
      && candle3.getTrend() == BEARISH
      && candle4.getTrend() == BEARISH
    )
  ) {
  
    return true;
  }

  return false;
}



void checkSignal() {

  if (crossingUp()) {
  
    if (invertSignal) {
    
      currentPrice = SellAtMarket();
    } else {
      
      currentPrice = BuyAtMarket();
    }
    
    candleCount = 0;
  }
  
  if (crossingDown()) {
  
    if (invertSignal) {
    
      currentPrice = BuyAtMarket();
    } else {
    
      currentPrice = SellAtMarket();
    }
    
    candleCount = 0;
  }
}

