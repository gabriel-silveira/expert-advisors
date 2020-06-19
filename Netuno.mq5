#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "SAR + ADX"

#include "./include/inc.mqh"

#include "./indicators/ADX.mqh"
#include "./indicators/SAR.mqh"


string        symbolName            = _Symbol;      // variável para armazenamento

int           expertId              = 777;
string        expertName            = "NETUNO";


bool          backtest              = false;        // Backtest
double        input profitLimit     = 9999;         // Limite diário de ganho
double        input lossLimit       = 9999;         // Limite diário de perda

int           input lots            = 5;            // Lots

bool          restrictedHours       = true;         // Restringir horários?
int           hourToStart           = 11;           // Início
int           hourToFinish          = 16;           // Término


int           input tp              = 20000;
int           input sl              = 12000;

double        maxADXLevel           = 26;           // Nível máximo do ADX


int OnInit() {
  
  setMagicNumber(expertId);
  
  InitADX(14);
  
  // InitSAR();
  
  strategy.lots     = lots;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
        
    CopyADXBuffers();
    
    CopySARBuffer();
  
    // CheckPositionToClose();
  
  
    double currentBalance = getCurrentBalance();
  
    if (workTime() && !isEnoughForToday(currentBalance)) {
      
      if (!PositionSelect(symbolName)) {
        
        CheckForSignal();
      }
    }
    
    
    // encerra posição em caso de demora em atingir o alvo
    if (PositionSelect(symbolName)) {
    
      candleCount++;
      
      if (
        candleCount > 12
      ) {
      
        Candle *c1 = new Candle(1, 0);
      
        if (
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
          &&
          currentPrice < c1.getClose()
        ) {
        
          ClosePosition();
        }
      
        if (
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
          &&
          currentPrice > c1.getClose()
        ) {
        
          ClosePosition();
        }
      }
    }
      
    previousBalance = currentBalance;
  }
}



void CheckForSignal() {

  if (ADXBuffer[1] < maxADXLevel) {
    
    if (
      (
        DI_plusBuffer[1] > DI_minusBuffer[1]
        &&
        DI_plusBuffer[2] < DI_minusBuffer[2]
      )
    ) {
    
      currentPrice = BuyAtMarket(
        DI_plusBuffer[1] - DI_minusBuffer[1],
        DI_plusBuffer[2] - DI_minusBuffer[2]
      );
      
      candleCount = 0;
    } else if (
      (
        DI_plusBuffer[1] < DI_minusBuffer[1]
        &&
        DI_plusBuffer[2] > DI_minusBuffer[2]
      )
    ) {
    
      currentPrice = SellAtMarket(
        DI_plusBuffer[1] - DI_minusBuffer[1],
        DI_plusBuffer[2] - DI_minusBuffer[2]
      );
      
      candleCount = 0;
    }
  }
}



void CheckPositionToClose() {
      
  Candle *c1 = new Candle(1, 6);
  Candle *c2 = new Candle(2, 6);

  if (PositionSelect(symbolName)) {
    
    if (
      PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
    ) {
      
      if (
        (
          DI_plusBuffer[1] < DI_minusBuffer[1]
          &&
          DI_plusBuffer[2] > DI_minusBuffer[2]
        )
        ||
        (
          iSARBuffer[1] > c1.getClose()
          &&
          iSARBuffer[2] < c2.getClose()
        )
      ) {
      
        ClosePosition();
      }
    }
    
    
    if (
      PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
    ) {
      
      if (
        (
          DI_plusBuffer[1] > DI_minusBuffer[1]
          &&
          DI_plusBuffer[2] < DI_minusBuffer[2]
        )
        ||
        (
          iSARBuffer[1] < c1.getClose()
          &&
          iSARBuffer[2] > c2.getClose()
        )
      ) {
      
        ClosePosition();
      }
    }
  }
}


datetime getHour() {

  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  return structNow.hour;
}


void OnDeinit(const int reason) {
  
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