#include "./include/Candle.mqh"
#include "./include/Trade.mqh"
#include "./include/HTTP-Request.mqh"

#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "MOZART"
#property description "..."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plotar iAMA
#property indicator_label1  "iAMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFuchsia
#property indicator_style1  STYLE_DASH
#property indicator_width1  2

//--- plotar iEMA
#property indicator_label1  "iEMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- buffer do indicador
double          iAMABuffer[];
int             handleAMA;
double          iEMABuffer[];
int             handleEMA;


//--- buffers do indicador ADX
int             handleADX;
double          ADX_buffer[];
double          DIP_buffer[];
double          DIM_buffer[];

//--- variável para armazenamento
string name = _Symbol;

enum TYPE {
  NONE,
  BUYER,
  SELLER
};

//+------------------------------------------------------------------+
//| PARÂMETROS                                                       |
//+------------------------------------------------------------------+
input double  num_lots          = 1;    // Contratos
input int     deviation         = 0;    // Desvio
input double  stopLoss          = 500;  // Stop loss
input double  takeProfit        = 20;   // Take profit

input bool    restrictedHours   = true; // Restringir horários?
input int     hourToStart       = 9;   // Início
input int     hourToFinish      = 16;   // Término

int   input   profitLimit       = 25000;
int   input   lossLimit         = 25000;

int   input   candlesToClosePosition = 5; // Encerrar posição após N candles

// int   input   maxDI             = 20;

// variáveis de controle
int           candleCount       = 0;
double        initialBalance    = 0;
double        previousBalance   = 0;
bool          crossedUp         = false;

double  currentPrice;

double maxDistanceFromMA = 150;


//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+
int OnInit() {

  initAMA();
  
  initEMA();
  
  initADX();

  //--- inicialização normal do indicador
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (!restrictHours()) {
      
    double currentBalance = getCurrentBalance();
  
  
    if (isEnoughForToday(currentBalance)) {
    
      if (previousBalance != currentBalance) {
      
        Print("YOU WIN!!! R$ ", currentBalance);
        Print("- - - - - - - - - - - - - - -");
      }
    } else {
      
      if (Candle::newBar()) {
      
        CopyBuffers();
        
        bool hasPosition = PositionSelect(_Symbol);
        
        if (!hasPosition) {
        
          if (checkEntryPoint()) candleCount = 0; 
        } else {
          
          checkPositionState();
        }
      }
    }
    
    previousBalance = currentBalance;
  }
}



void OnDeinit(const int reason) {

  if(handleAMA != INVALID_HANDLE) IndicatorRelease(handleAMA);
  if(handleEMA != INVALID_HANDLE) IndicatorRelease(handleEMA);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}



void initAMA() {

  SetIndexBuffer(0, iAMABuffer, INDICATOR_DATA);
  
  handleAMA = iMA(name, PERIOD_CURRENT, 21, 0, MODE_SMA, PRICE_CLOSE);
}



void initEMA() {

  SetIndexBuffer(0, iEMABuffer, INDICATOR_DATA);
  
  handleEMA = iMA(name, PERIOD_CURRENT, 8, 0, MODE_EMA, PRICE_CLOSE);
}



void initADX() {

  SetIndexBuffer(0, ADX_buffer, INDICATOR_DATA);
  SetIndexBuffer(1, DIP_buffer, INDICATOR_DATA);
  SetIndexBuffer(2, DIM_buffer, INDICATOR_DATA);
  
  handleADX = iADX(name, PERIOD_CURRENT, 21);
}



void CopyBuffers() {

  //+------------------------------------------------------------------+
  //| iAMA                                                             |
  //+------------------------------------------------------------------+
  CopyBuffer(handleAMA, 0, 0, 5, iAMABuffer);
  ArraySetAsSeries(iAMABuffer, true);
  
  //+------------------------------------------------------------------+
  //| iEMA                                                             |
  //+------------------------------------------------------------------+
  CopyBuffer(handleEMA, 0, 0, 5, iEMABuffer);
  ArraySetAsSeries(iEMABuffer, true);
  
  //+------------------------------------------------------------------+
  //| ADX                                                              |
  //+------------------------------------------------------------------+
  CopyBuffer(handleADX, 0, 0, 3, ADX_buffer);
  CopyBuffer(handleADX, 1, 0, 3, DIP_buffer);
  CopyBuffer(handleADX, 2, 0, 3, DIM_buffer);
  
  ArraySetAsSeries(ADX_buffer, true);
  ArraySetAsSeries(DIP_buffer, true);
  ArraySetAsSeries(DIM_buffer, true);
}


void resetAll() {
  
  candleCount = 0;
  
  crossedUp = false;
}



//+------------------------------------------------------------------+
//| VERIFICA SINAL DE ENTRADA                                        |
//+------------------------------------------------------------------+
bool checkEntryPoint() {
  
  Candle *candle1 = new Candle(1, 0);
  Candle *candle2 = new Candle(2, 0);
  
  if (
       candle1.getHeight() > 20
    && candle2.getHeight() > 20
    // && DIP_buffer[0] < 25
    // && DIM_buffer[0] < 25
  ) {
    
    if (checkMAZoneEntrance(candle1)) return true;
    
    if (checkAboveMACandle(candle1)) return true;
    
    if (checkBelowMACandle(candle1)) return true;
  }
  
  return false;
}



bool checkMAZoneEntrance(Candle &candle1) {
    
  // entrando na zona de médias móveis
  if (
       candle1.getOpen()  < iEMABuffer[1]
    && candle1.getClose() > iEMABuffer[1]
    
    && candle1.getOpen()  < iAMABuffer[1]
    && candle1.getClose() < iAMABuffer[1]
  ) {
  
    currentPrice = BuyAtMarket(stopLoss, takeProfit);
    
    return true;
  }
  
  return false;
}



// ACIMA das MAs
bool checkAboveMACandle(Candle &candle1) {
  
  Candle *candle0 = new Candle(0, 0);
  
  if (
       candle1.getOpen()  > iEMABuffer[1]
    && candle1.getClose() > iEMABuffer[1]
    
    && candle1.getOpen()  > iAMABuffer[1]
    && candle1.getClose() > iAMABuffer[1]
    
    && candle1.getTrend() == BULLISH
    
    && candle0.getOpen() >= candle1.getClose()
  ) {
  
    double distanceFromMA = candle0.getOpen() - iEMABuffer[0];
    
    if (distanceFromMA > maxDistanceFromMA) {
    
      Print("Open: ", candle0.getOpen());
      Print("iEMA: ", iEMABuffer[0]);
      Print("Distance: ", distanceFromMA);
      
      currentPrice = SellAtMarket(stopLoss, takeProfit);
    } else {
    
      currentPrice = BuyAtMarket(stopLoss, takeProfit);
    }
    
    
    return true;
  }
  
  return false;
}



// ABAIXO das MAs
bool checkBelowMACandle(Candle &candle1) {
  
  Candle *candle0 = new Candle(0, 0);
  
  if (
       candle1.getOpen()  < iEMABuffer[1]
    && candle1.getClose() < iEMABuffer[1]
    
    && candle1.getOpen()  < iAMABuffer[1]
    && candle1.getClose() < iAMABuffer[1]
    
    && candle1.getTrend() == BEARISH
    
    && candle0.getOpen() <= candle1.getClose()
  ) {
  
    double distanceFromMA = iEMABuffer[0] - candle0.getOpen();
  
    if (distanceFromMA > maxDistanceFromMA) {
      
      currentPrice = BuyAtMarket(stopLoss, takeProfit);
    } else {
    
      currentPrice = SellAtMarket(stopLoss, takeProfit);
    }
    
    return true;
  }
  
  return false;
}



//+------------------------------------------------------------------+
//| VERIFICA COMO ESTÁ A POSIÇÃO E SE FOR O CASO, ENCERRA!           |
//+------------------------------------------------------------------+
void checkPositionState() {
  
  candleCount++;
  
  if (candleCount > candlesToClosePosition) {
  
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


