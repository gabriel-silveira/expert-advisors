#include "./include/Candle.mqh"
#include "./include/Trade.mqh"
#include "./include/HTTP-Request.mqh"

#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "BEETHOVEN Crossing Moving Averages"
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



//+------------------------------------------------------------------+
//| PARÂMETROS                                                       |
//+------------------------------------------------------------------+
input double  num_lots          = 5;    // Contratos
input int     deviation         = 0;    // Desvio
input double  stopLoss          = 15000;  // Stop loss
input double  takeProfit        = 1000;   // Take profit

input bool    restrictedHours   = true; // Restringir horários?
input int     hourToStart       = 9;   // Início
input int     hourToFinish      = 17;   // Término

int   input   profitLimit       = 99999;
int   input   lossLimit         = 99999;

int   input   adxLimit          = 10; 

// variáveis de controle
int     candleCount       = 0;
double  initialBalance    = 0;
double  previousBalance   = 0;
bool    crossedUp         = false;

double  currentPrice;



//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+
int OnInit() {

  initAMA();
  
  initEMA();
  
    //+------------------------------------------------------------------+
  //| ADX                                                              |
  //+------------------------------------------------------------------+
  SetIndexBuffer(0, ADX_buffer, INDICATOR_DATA);
  SetIndexBuffer(1, DIP_buffer, INDICATOR_DATA);
  SetIndexBuffer(2, DIM_buffer, INDICATOR_DATA);
  
  handleADX = iADX(name, PERIOD_CURRENT, 21);

  //--- inicialização normal do indicador
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (!restrictHours()) {
      
    double currentBalance = getCurrentBalance();
    
    // reinicia contador após sair da posição
    /* if (
      PositionSelect(_Symbol) == false
      && previousBalance != currentBalance
    ) {
    
      candleCount = 0;
    } */
  
  
    if (isEnoughForToday(currentBalance)) {
    
      if (previousBalance != currentBalance) {
      
        Print("Lucro do dia atingido! ", currentBalance);
        Print("- - - - - - - - - - - - - - -");
      }
    } else {
      
      if (Candle::newBar()) {
      
        CopyBuffers();
        

        bool hasPosition = PositionSelect(_Symbol);
        
        
        if (!hasPosition) {
        
          Candle *candle1 = new Candle(1, 0);
        
          if (
            crossingUp()
          ) {
          
            currentPrice = SellAtMarket(stopLoss, takeProfit);
          }
          
          if (
            crossingDown()
          ) {
          
            currentPrice = BuyAtMarket(stopLoss, takeProfit);
          }
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



bool crossingUp() {

  if (
       iAMABuffer[0] < iEMABuffer[0]
    && iAMABuffer[0] > iAMABuffer[1]
    
    && iAMABuffer[1] < iEMABuffer[1]
    && iAMABuffer[1] > iAMABuffer[2]
    
    && iAMABuffer[2] > iEMABuffer[2]
  ) {

    Print("- - - - - - -");
    Print("CRUZOU PRA CIMA!");
    
    return true;
  }
  
  return false;
}



bool crossingDown() {
  if (
       iAMABuffer[0] > iEMABuffer[0]
    && iAMABuffer[0] < iAMABuffer[1]
    
    && iAMABuffer[1] > iEMABuffer[1]
    && iAMABuffer[1] < iAMABuffer[2]
    
    && iAMABuffer[2] < iEMABuffer[2]
  ) {

    Print("- - - - - - -");
    Print("CRUZOU PRA BAIXO!");
    
    return true;
  }
  
  return false;
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

