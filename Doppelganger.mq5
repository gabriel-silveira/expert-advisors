#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"


#include "./include/inc.mqh"


// indicador CMAs
#include "./indicators/RSI.mqh"
// indicador ADX
#include "./indicators/Stochastic.mqh"

// painel do expert
#include "./include/General-Panel.mqh"



//+------------------------------------------------------------------+
//| PARÂMETROS                                                       |
//+------------------------------------------------------------------+
input int     num_lots          = 10;    // Contratos
input int     deviation         = 0;    // Desvio
input double  stopLoss          = 500;  // Stop loss
input double  takeProfit        = 25;   // Take profit

input bool    restrictedHours   = true; // Restringir horários?
input int     hourToStart       = 10;    // Início
input int     hourToFinish      = 15;   // Término

int   input   profitLimit       = 100;
int   input   lossLimit         = 50;


int   input   minimumRSI        = 30;
int   input   maximumRSI        = 70;

int   input   minimumStc        = 30;
int   input   maximumStc        = 70;

int   input   minimumCandleSize = 10;

input bool    backtest          = false; // Backtest




int OnInit() {

  int expertId = 3;

  string eaName = "Doppelgänger";

  candlesToClose    = 10;

  typeFilling = ORDER_FILLING_RETURN;
  
  
  if (backtest) {
  
    strategy.id       = 999;
    strategy.symbol   = _Symbol;
    strategy.name     = eaName + " Backtest";
    strategy.lots     = num_lots;
    strategy.target   = takeProfit;
    strategy.stopLoss = stopLoss;
    
  } else {
  
    if (setStrategy(expertId, _Symbol)) {
      
      if (!CreateControlPanel(eaName)) return(INIT_FAILED);
    }
  }
  
  InitRSI(14);
  
  InitStochastic(5, 3, 3);
  
  
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
      
          if (currentBalance > previousBalance) PlaySound("request.wav");
          
          if (!backtest) registerLastDeal(1, 1);
        }
        
      
        bool hasPosition = PositionSelect(_Symbol);
        
        if (!hasPosition) {
        
          CopyRSIBuffers();
          
          CopyStochasticBuffers();
          
          
          if (isOverbought()) {
          
            BuyAtMarket(iRSIBuffer[0], StochasticBuffer[0]);
          } else if (isOversold()) {
          
            SellAtMarket(iRSIBuffer[0], StochasticBuffer[0]);
          }
        }
      }
    }
  }
}







bool isOverbought() {

  Candle *candle1 = new Candle(1, 0);
  Candle *candle2 = new Candle(2, 0);
  Candle *candle3 = new Candle(3, 0);
  
  if (
    iRSIBuffer[0] >= maximumRSI
    &&
    StochasticBuffer[0] >= maximumStc
    &&
    candle1.getTrend() == BULLISH && candle1.getHeight() > minimumCandleSize
    &&
    candle2.getTrend() == BULLISH && candle2.getHeight() > minimumCandleSize
    //&&
    //candle3.getTrend() == BULLISH && candle3.getHeight() > minimumCandleSize
  ) {
  
    return true;
  }
  
  return false;
}


bool isOversold() {

  Candle *candle1 = new Candle(1, 0);
  Candle *candle2 = new Candle(2, 0);
  Candle *candle3 = new Candle(3, 0);
  
  if (
    iRSIBuffer[0] <= minimumRSI
    &&
    StochasticBuffer[0] <= minimumStc
    &&
    candle1.getTrend() == BEARISH && candle1.getHeight() > minimumCandleSize
    &&
    candle2.getTrend() == BEARISH && candle2.getHeight() > minimumCandleSize
    //&&
    //candle3.getTrend() == BEARISH && candle3.getHeight() > minimumCandleSize
  ) {
  
    return true;
  }
  
  return false;
}


void OnDeinit(const int reason) {

  if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
  
  if(handleStoch != INVALID_HANDLE) IndicatorRelease(handleStoch);
  
  Comment("");
}

