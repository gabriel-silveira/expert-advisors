#include "./indicators/CrossingMAs.mqh"

#include "./include/Candle.mqh"
#include "./include/Trade.mqh"
#include "./include/HTTP-Request.mqh"
#include "./include/Chart.mqh"
#include "./include/Panel-Beethoven.mqh"


#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "BEETHOVEN Crossing Moving Averages"
#property description "..."

//--- variável para armazenamento
string symbolName = _Symbol;


//+------------------------------------------------------------------+
//| PARÂMETROS WIN / WDO                                             |
//+------------------------------------------------------------------+
int win_settings[] = { 10, 0,  1000,  10, 10, 16, 9999, 9999, 100 }; // WIN
int wdo_settings[] = { 10, 0, 20000, 500, 10, 16, 9999, 9999,   5 }; // WDO

int     num_lots          = win_settings[0]; // Contratos
int     deviation         = win_settings[1]; // Desvio
double  stopLoss          = win_settings[2]; // Stop loss
double  takeProfit        = win_settings[3]; // Take profit

bool    restrictedHours   = true;            // Restringir horários?
int     hourToStart       = win_settings[4]; // Início
int     hourToFinish      = win_settings[5]; // Término

int     profitLimit       = win_settings[6]; // Limite diário de ganho
int     lossLimit         = win_settings[7]; // Limite diário de perda

int mrbzheight = win_settings[8];

// variáveis de controle
int     candleCount       = 0;
double  initialBalance    = 0;
double  previousBalance   = 0;
bool    crossedUp         = false;

double  currentPrice;

bool isWDO = false;



int OnInit() {

  initCrossingMAs();
  
  if (!CreateControlPanel()) return(INIT_FAILED);

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
      
        CopyCrossingMAsBuffers();
        
        if (!PositionSelect(symbolName)) {
        
          if (!checkExceptions()) {
          
            checkSignal();
          }
        } else {
          
          checkPosition();
        }
      }
    }
    
    previousBalance = currentBalance;
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
  
    if (isWDO) {
    
      currentPrice = SellAtMarket(stopLoss, takeProfit);
    } else {
      
      currentPrice = BuyAtMarket(stopLoss, takeProfit);
    }
    
    candleCount = 0;
  }
  
  if (crossingDown()) {
  
    if (isWDO) {
    
      currentPrice = BuyAtMarket(stopLoss, takeProfit);
    } else {
    
      currentPrice = SellAtMarket(stopLoss, takeProfit);
    }
    
    candleCount = 0;
  }
}



void checkPosition() {
  
  candleCount++;
  
  if (candleCount > 10) {
    
    ClosePosition();
  }
}


double getCurrentBalance() {

  if (Candle::newDay()) {
  
    initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  }
  
  return AccountInfoDouble(ACCOUNT_BALANCE) - initialBalance;
}



bool restrictHours() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);

  if (restrictedHours) {
  
    if (structNow.hour < hourToStart) return true;
    
    if (structNow.hour > hourToFinish) return true;
  }
  
  return false;
}



bool isEnoughForToday(double balance) {

  return balance >= profitLimit || balance < (lossLimit * -1);
}
