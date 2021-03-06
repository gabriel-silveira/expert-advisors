#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Objetivo:"
#property description "Atingir um lucro diário de R$ 200"
#property description "\n"
#property description "Sinais:"
#property description "BULLISH DRAGONFLY, BEARISH ENGULFING, MORNING STAR, EVENING STAR, SHUTTING STAR, BEARISH GRAVESTONE"
#property description "\n"
#property description "Alvo dólar:"
#property description "1 pt, 20 lotes, Timeframe 1m"
#property description "Alvo índice:"
#property description "15 pts, 50 lotes, Timeframe 1m"

#include "./include/inc.mqh"

#include "./indicators/CrossingMAs.mqh"

#include "./indicators/ADX.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


string        symbolName            = _Symbol;      // variável para armazenamento

bool          isMiniDolar     = StringFind(_Symbol, "WDO") != -1;

int           expertId              = isMiniDolar ? 7 : 8;
string        expertName            = "Z-"+symbolName;


bool          backtest              = false;        // Backtest
double        input profitLimit     = 100;          // Limite diário de ganho
double        input lossLimit       = 100;          // Limite diário de perda

int           input marobozuHeightinput = 100; // Altura do marobozu

int           lots                  = isMiniDolar ? 20  : 50; // Lots

bool          restrictedHours       = true;         // Restringir horários?
int           hourToStart           = 10;           // Início
int           hourToFinish          = 16;           // Término


int           tp                    = isMiniDolar ? 1000  : 15;
int           sl                    = isMiniDolar ? 15000 : 300;

double        marobozuHeight        = isMiniDolar ? 6 : marobozuHeightinput;


int OnInit() {
  
  setMagicNumber(expertId);
  
  InitADX(14);
  
  InitEMA(10);
  
  strategy.lots     = lots;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  candlesToClose = 5;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
      
    double currentBalance = getCurrentBalance();
  
    if (workTime() && !isEnoughForToday(currentBalance)) {
      
      
      
      if (!PositionSelect(symbolName)) {
        
        CopyADXBuffers();
        
        CandlePattern *cp = new CandlePattern(marobozuHeight);
        
        CopyEMABuffer();
        
        
        
        // BULLISH DRAGONFLY
        if (
          cp.isUpperDragonfly(iEMABuffer[1])
        ) {
        
          BuyAtMarket(expertName+" - Buy");
      
          candleCount = 0;
        } else
        
        // BEARISH ENGULFING
        if (
          cp.isBearishEngulfing(iEMABuffer[1])
        ) {
        
          SellAtMarket(expertName+" - Sell");
      
          candleCount = 0;
        } else
        
        // MORNING STAR
        if (
          cp.isMorningStar(iEMABuffer[1])
        ) {
        
          BuyAtMarket(expertName+" - Buy");
      
          candleCount = 0;
          
        // EVENING STAR
        } else if (
          cp.isEveningStar(iEMABuffer[1])
        ) {
        
          SellAtMarket(expertName+" - Sell");
      
          candleCount = 0;
          
        // SHUTTING STAR
        } else if (
          cp.isShuttingStar(iEMABuffer[1])
          &&
          DI_plusBuffer[1] > DI_minusBuffer[1]
          &&
          DI_plusBuffer[2] > DI_minusBuffer[2]
        ) {
        
          SellAtMarket(expertName+" - Sell");
      
          candleCount = 0;
          
        // BEARISH GRAVESTONE
        } else  if (
          cp.isBearishGravestone(iEMABuffer[1])
        ) {
          
          SellAtMarket(expertName+" - Sell");
        
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




