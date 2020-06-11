#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"

#include "./indicators/CrossingMAs.mqh"

#include "./indicators/ADX.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int           expertId        = 7;
string        expertName      = "ZOROASTRIX";


bool  input   backtest        = false; // Backtest
int    input  lots            = 5;            // Lots


string        symbolName      = _Symbol;      // variável para armazenamento

bool          restrictedHours = true;         // Restringir horários?
int           hourToStart     = 10;           // Início
int           hourToFinish    = 16;           // Término

double        profitLimit     = (lots * 10) * 10;        // Limite diário de ganho
double        lossLimit       = (lots * 10) * 2;         // Limite diário de perda


bool          isMiniDolar     = StringFind(_Symbol, "WDO") != -1;
int           tp              = 1000;
int           sl              = 15000;



int OnInit() {
  
  setMagicNumber(expertId);
  
  InitADX(14);
  
  InitEMA(10);
  
  candlesToClose = 5;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
      
    double currentBalance = getCurrentBalance();
  
    if (workTime() && !isEnoughForToday(currentBalance)) {
          
      if (previousBalance != currentBalance) {
      
        Print(currentBalance > previousBalance ? "Lucro" : "Prejuízo", currentBalance);
        
        
        // if (currentBalance < previousBalance) ExpertRemove();
      
        if (currentBalance > previousBalance) PlaySound("request.wav");
      }
      
      
      
      if (!PositionSelect(symbolName)) {
        
        CopyADXBuffers();
        
        CandlePattern *cp = new CandlePattern();
        
        CopyEMABuffer();
        
        
        
        // BULLISH DRAGONFLY
        if (
          cp.isUpperDragonfly(iEMABuffer[1])
        ) {
        
          strategy.lots     = lots;
          strategy.target   = tp * 2;
          strategy.stopLoss = sl;
        
          BuyAtMarket((double) TimeCurrent(), (double) TimeCurrent() + 10);
      
          candleCount = 0;
        } else
        
        // BEARISH ENGULFING
        if (
          cp.isBearishEngulfing(iEMABuffer[1])
        ) {
        
          strategy.lots     = lots;
          strategy.target   = tp * 2;
          strategy.stopLoss = sl;
        
          SellAtMarket((double) TimeCurrent(), (double) TimeCurrent() + 10);
      
          candleCount = 0;
        } else
        
        // MORNING STAR
        if (
          cp.isMorningStar(iEMABuffer[1])
        ) {
        
          strategy.lots     = lots;
          strategy.target   = tp;
          strategy.stopLoss = sl;
        
          BuyAtMarket((double) TimeCurrent(), (double) TimeCurrent() + 10);
      
          candleCount = 0;
          
        // EVENING STAR
        } else if (
          cp.isEveningStar(iEMABuffer[1])
        ) {
        
          strategy.lots     = lots;
          strategy.target   = tp;
          strategy.stopLoss = sl;
        
          SellAtMarket((double) TimeCurrent(), (double) TimeCurrent() + 10);
      
          candleCount = 0;
          
        // SHUTTING STAR
        } else if (
          cp.isShuttingStar(iEMABuffer[1])
          &&
          DI_plusBuffer[1] > DI_minusBuffer[1]
          &&
          DI_plusBuffer[2] > DI_minusBuffer[2]
        ) {
        
          strategy.lots     = lots;
          strategy.target   = tp;
          strategy.stopLoss = sl;
        
          SellAtMarket((double) TimeCurrent(), (double) TimeCurrent() + 10);
      
          candleCount = 0;
          
        // BEARISH GRAVESTONE
        } else  if (
          cp.isBearishGravestone(iEMABuffer[1])
        ) {
          
            strategy.lots     = lots;
            strategy.target   = tp;
            strategy.stopLoss = sl;
          
            SellAtMarket((double) TimeCurrent(), (double) TimeCurrent() + 10);
        
            candleCount = 0;
        }
      } else {
        candleCount++;
        
        if (candleCount > candlesToClose) ClosePosition();
      }
    }
      
    previousBalance = currentBalance;
  }
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





bool workTime() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  if (
    (structNow.hour >= hourToStart && structNow.hour < hourToFinish)
  ) return true;
  
  return false;
}