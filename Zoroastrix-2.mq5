#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Crossing Moving Averages"

#include "./include/inc.mqh"

// indicador RSI
#include "./indicators/ADX.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int           expertId        = 7;

string        expertName      = "ZOROASTRIX ADX";


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
int           hourToFinish    = 17;       // Término

double        profitLimit     =  200;      // Limite diário de ganho
double        lossLimit       = 1500;       // Limite diário de perda


double input tp = 15000; // Take profit
double input sl = 15000; // Stop loss

int profitCount = 0;

int lossCount   = 0;



int OnInit() {
  
  setMagicNumber(expertId);
  
  candlesToClose = 10;
  
  
  if (!backtest) {
  
    strategy.id       = 999;
    strategy.symbol   = _Symbol;
    strategy.name     = expertName + "Backtest";
    strategy.lots     = isMiniDolar ?       2 :   10;
    strategy.target   = isMiniDolar ?      tp :  100;
    strategy.stopLoss = isMiniDolar ?      sl : 2500;
    
  } else {
  
    if (setStrategy(expertId, symbolName)) {
    
      profitLimit     = strategy.goal;
      lossLimit       = strategy.riskLimit;
      
      if (!CreateControlPanel(expertName)) return(INIT_FAILED);
    }
  }
  
  // InitADX(14);
  
  return(INIT_SUCCEEDED);
}


void OnTick() {

  if (Candle::newBar()) {
      
    double currentBalance = getCurrentBalance();
  
    if (workTime() && !isEnoughForToday(currentBalance)) {
    
    
      if (previousBalance != currentBalance) {
      
        if (currentBalance > previousBalance) PlaySound("request.wav");
        
        // if (!backtest) registerLastDeal(1, 1);
      }
      
      
      // CopyADXBuffers();
      
      if (!PositionSelect(symbolName)) {
        
        Candle *c1 = new Candle(1, 5);
        Candle *c2 = new Candle(2, 5);
        Candle *c3 = new Candle(3, 5);
        Candle *c4 = new Candle(4, 5);
        
        hook(c1, c2, c3, c4);
        
        upSoldiers(c1, c2, c3, c4);
        
        downSoldiers(c1, c2, c3, c4);
      }
    }
      
    previousBalance = currentBalance;
    
    
    /*if (PositionSelect(symbolName)) {
    
      checkPositionStatus();
    }*/
  }
}



void upSoldiers(
  Candle &c1,
  Candle &c2,
  Candle &c3,
  Candle &c4
) {
  
  if (!PositionSelect(symbolName)) {

    Candle *c5 = new Candle(5, 5);
  
    if (
      c1.getTrend() == BULLISH && c1.getHeight() > 1 && c1.getHeight() < 8
      &&
      c1.getLowerShadow() < c1.getHeight()
      &&
      !(c1.getUpperShadow() > 1 && c2.getUpperShadow() > 1)
      &&
      c2.getTrend() == BULLISH && c2.getHeight() > 1
      &&
      c3.getTrend() == BULLISH && c3.getHeight() > 1
      &&
      c4.getTrend() == BEARISH && c4.getHeight() < 8
    ) {
      
      strategy.target   = 1000;
      strategy.stopLoss = 15000;
      
      BuyAtMarket(0, 1);
    }
  }
}



void downSoldiers(
  Candle &c1,
  Candle &c2,
  Candle &c3,
  Candle &c4
) {
  
  if (!PositionSelect(symbolName)) {

    Candle *c5 = new Candle(5, 5);
  
    if (
      c1.getTrend() == BEARISH && c1.getHeight() > 1 && c1.getHeight() < 8 && c1.getUpperShadow() < c1.getHeight()
      &&
      c2.getTrend() == BEARISH && c2.getHeight() > 1
      &&
      c3.getTrend() == BEARISH && c3.getHeight() > 1
      &&
      c4.getTrend() == BULLISH
    ) {
      
      strategy.target   = 1000;
      strategy.stopLoss = 15000;
      
      SellAtMarket(0, 1);
    }
  }
}



void hook(
  Candle &c1,
  Candle &c2,
  Candle &c3,
  Candle &c4
) {

  if (!PositionSelect(symbolName)) {
  
    if (
      c4.getTrend() == BULLISH && c4.getHeight() >= 2
      &&
      c3.getTrend() == BULLISH && c3.getHeight() >= 2
      &&
      c2.getTrend() == BULLISH && c2.getHeight() >= 2
      &&
      c1.getTrend() == BEARISH
      &&
      c1.getHeight() > 1
      &&
      !(c1.getLowerShadow() > 2 && c1.getUpperShadow() < 1)
    ) {
      
      strategy.target   = 1000;
      strategy.stopLoss = 15000;
    
      if (c1.getHeight() >= 4)
        BuyAtMarket(0, 1);
      else
        SellAtMarket(0, 1);
    }
  }
}



void checkPositionStatus() {
  
  candleCount++;
  
  Candle *candle1 = new Candle(1, 0);
  
  if (
    candleCount > 30
  ) {
  
    if (
      PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
      &&
      candle1.getClose() > currentPrice
    ) {
    
      ClosePosition();
    } else if (
      PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
      &&
      candle1.getClose() < currentPrice
    ) {
    
      ClosePosition();
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





bool workTime() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  if (
    structNow.hour > 9 && structNow.hour < 17
  ) return true;
  
  return false;
}