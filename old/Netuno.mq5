#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Objetivo:"
#property description "Atingir um lucro diário de R$ 200"
#property description "\n"
#property description "Sinal:"
#property description "Quando o ADX estiver abaixo de 26 (maxADXLevel) e houver um cruzamento veemente entre DI+ e DI-, entra em uma compra ou venda."
#property description "\n"
#property description "Alvo:"
#property description "20 / 12pts, Mini Dólar 5m, 1 lote"


#include "./include/inc.mqh"

#include "./indicators/ADX.mqh"


string        symbolName            = _Symbol;      // variável para armazenamento

int           expertId              = 777;
string        expertName            = "NETUNO";


bool          backtest              = false;        // Backtest
double        input profitLimit     = 150;         // Limite diário de ganho
double        input lossLimit       = 9999;         // Limite diário de perda

int           input lots            = 1;            // Lots

bool          restrictedHours       = true;         // Restringir horários?
int           hourToStart           = 11;           // Início
int           hourToFinish          = 16;           // Término


int           input tp              = 20000;
int           input sl              = 12000;

double        maxADXLevel           = 26;           // Nível máximo do ADX


int OnInit() {
  
  setMagicNumber(expertId);
  
  InitADX(14);
  
  strategy.lots     = lots;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
        
    CopyADXBuffers();
    
    
    CheckPositionToClose();
  
  
    double currentBalance = getCurrentBalance();
  
    if (workTime() && !isEnoughForToday(currentBalance)) {
      
      if (!PositionSelect(symbolName)) {
        
        CheckForSignal();
      }
    }
      
    previousBalance = currentBalance;
  }
}



void  CheckForSignal() {

  if (ADXBuffer[1] < maxADXLevel) {
    
    if (
      (
        DI_plusBuffer[0] > DI_minusBuffer[0]
        &&
        DI_plusBuffer[1] > DI_minusBuffer[1]
        &&
        DI_plusBuffer[2] < DI_minusBuffer[2]
        &&
        DI_plusBuffer[3] < DI_minusBuffer[3]
      )
    ) {
    
      currentPrice = BuyAtMarket(expertName+" - Buy");
      
      candleCount = 0;
    } else if (
      (
        DI_plusBuffer[0] < DI_minusBuffer[0]
        &&
        DI_plusBuffer[1] < DI_minusBuffer[1]
        &&
        DI_plusBuffer[2] > DI_minusBuffer[2]
        &&
        DI_plusBuffer[3] > DI_minusBuffer[3]
      )
    ) {
    
      currentPrice = SellAtMarket(expertName+" - Sell");
      
      candleCount = 0;
    }
  }
}



void CheckPositionToClose() {

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
}


datetime getHour() {

  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  return structNow.hour;
}


void OnDeinit(const int reason) {
  
  Comment("");
}



