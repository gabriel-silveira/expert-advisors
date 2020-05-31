#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "BEETHOVEN"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"


// indicador CMAs
#include "./indicators/CrossingMAs.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int           expertId        = 1;


bool  input   backtest        = false; // Backtest

int   input   mrbzheight      = 100;



//--- variável para armazenamento
string        symbolName      = _Symbol;

bool          restrictedHours = true;   // Restringir horários?
int           hourToStart     = 9;      // Início
int           hourToFinish    = 15;     // Término

double        profitLimit     = 100;    // Limite diário de ganho
double        lossLimit       = 50;     // Limite diário de perda



int OnInit() {
  
  setMagicNumber(expertId);
  
  candlesToClose = 10;
  
  
  if (backtest) {
  
    strategy.id       = 999;
    strategy.symbol   = _Symbol;
    strategy.name     = "Backtest";
    strategy.lots     = 20;
    strategy.target   = 5;
    strategy.stopLoss = 1000;
    
  } else {
  
    if (setStrategy(expertId, symbolName)) {
    
      profitLimit     = strategy.goal;
      lossLimit       = strategy.riskLimit;
      
      if (!CreateControlPanel("Beethoven")) return(INIT_FAILED);
    }
  }
  
  InitCrossingMAs(21, 8);
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (!restrictHours()) {
      
    double currentBalance = getCurrentBalance();
  
    if (isEnoughForToday(currentBalance)) {
    
      if (previousBalance != currentBalance) {
      
        Print("Meta atingida: ", currentBalance);
        Print("- - - - - - - - - - - - - - -");
        
        previousBalance = currentBalance;
        
        // ExpertRemove();
      }
    } else {
      
      if (Candle::newBar()) {
      
        // registar última negociação
        if (previousBalance != currentBalance) {
          
          if (!backtest) registerLastDeal(1, 1);
        }
        
        CopyCrossingMAsBuffers();
        
        if (!PositionSelect(symbolName)) {
          
          checkSignal();
          
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
  
  // 1. evitar marobozus
  // 2. evitar soldados de alta ou baixa
  // 3. evitar candles de indecisão / sem força
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
    ||
    (
         candle1.getHeight() < 20
    )
  ) {
  
    return true;
  }

  return false;
}



void checkSignal() {
        
  if (!checkExceptions()) {
  
    if (crossingUp()) {
    
      currentPrice = BuyAtMarket(iAMABuffer[0], iEMABuffer[0]);
      
      candleCount = 0;
    }
    
    if (crossingDown()) {
    
      currentPrice = SellAtMarket(iAMABuffer[0], iEMABuffer[0]);
      
      candleCount = 0;
    }
  }
}

