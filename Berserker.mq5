#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Simple moving average 34 periods - candle crossing over"

#include "./include/inc.mqh"


// indicador CMAs
#include "./indicators/CrossingMAs.mqh"
// indicador ADX
#include "./indicators/ADX.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int             expertId        = 2;

bool    input   backtest        = true;     // Backtest

int     input   lots            = 10;
double  input   tp              = 500;
double  input   sl              = 20000;


//--- variável para armazenamento
string        symbolName      = _Symbol;

bool          restrictedHours = true;       // Restringir horários?

int           hourToStart     = 10;       // Início
int           hourToFinish    = 16;       // Término

int           profitLimit     = 250;      // Limite diário de ganho
int           lossLimit       = 250;      // Limite diário de perda

double        marobozuHeight  = 5;

double        minADX          = 14;
double        minCandleHeight = 2;


int OnInit() {
  
  setMagicNumber(expertId);
  
  
  if (backtest) {
  
    strategy.id       = 999;
    strategy.symbol   = _Symbol;
    strategy.name     = "Berserker Backtest";
    strategy.lots     = lots;
    strategy.target   = tp;
    strategy.stopLoss = sl;
    
  } else {
  
    if (setStrategy(expertId, symbolName)) {
      
      if (!CreateControlPanel("Berseker")) return(INIT_FAILED);
    }
  }
  
  InitAMA(34);
  
  InitADX(55);
  
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
        
        // if (backtest) ExpertRemove();
      }
    } else {
      
      if (Candle::newBar()) {
      
        // registar última negociação
        if (previousBalance != currentBalance) {
          
          if (!backtest) registerLastDeal(1, 1);
        }
        
        CopyAMABuffer();
        
        CopyADXBuffers();
        
        if (!PositionSelect(symbolName)) {
          
          checkSignal();
        }
    
        previousBalance = currentBalance;
      }
    }
  }
}

 

void OnDeinit(const int reason) {

  if(handleAMA != INVALID_HANDLE) IndicatorRelease(handleAMA);
  if(handleADX != INVALID_HANDLE) IndicatorRelease(handleADX);
  
  ExtDialog.Destroy(reason);
  
  Comment("");
}



void checkSignal() {
        
  Candle *candle1 = new Candle(1, marobozuHeight);
  
  if (ADXBuffer[1] > minADX) {
  
    // up crossing
    if (
      candle1.getClose()  > iAMABuffer[1]
      &&
      candle1.getOpen()   < iAMABuffer[1]
      &&
      candle1.getHeight() > minCandleHeight
      &&
      candle1.getHeight() < marobozuHeight
    ) {
      
      PrintADX("UP");
      
      if (DI_minusBuffer[1] < DI_plusBuffer[1])
        BuyAtMarket(candle1.getClose(), iAMABuffer[1]);
    }
    
    // down crossing
    if (
      candle1.getClose()  < iAMABuffer[1]
      &&
      candle1.getOpen()   > iAMABuffer[1]
      &&
      candle1.getHeight() > minCandleHeight
      &&
      candle1.getHeight() < marobozuHeight
    ) {
    
      PrintADX("DOWN");
      
      if (DI_plusBuffer[1] < DI_minusBuffer[1])
        SellAtMarket(candle1.getClose(), iAMABuffer[1]);
    }
  }
}


void PrintADX(string trend) {

  Print(" ");
  Print(trend);
  Print("ADX ", ADXBuffer[1]);
  Print("DI- ", DI_minusBuffer[1]);
  Print("DI+ ", DI_plusBuffer[1]);
  Print("ADX ", ADXBuffer[0]);
  Print("DI- ", DI_minusBuffer[0]);
  Print("DI+ ", DI_plusBuffer[0]);
  Print(" ");
}