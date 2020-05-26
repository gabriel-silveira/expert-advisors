#include "./include/Candle.mqh"
#include "./include/Trade.mqh"
#include "./include/HTTP-Request.mqh"
#include "./include/Chart.mqh"

#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "DOPPELGANGER"
#property description "..."

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "iRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

double  iRSIBuffer[];

int     handleRSI;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_label2  "Stochastic"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLightSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

double    StochasticBuffer[];
double    SignalBuffer[];

int       handleStoch;



string symbol = _Symbol;



//+------------------------------------------------------------------+
//| PARÂMETROS                                                       |
//+------------------------------------------------------------------+
input double  num_lots          = 10;    // Contratos
input int     deviation         = 0;    // Desvio
input double  stopLoss          = 500;  // Stop loss
input double  takeProfit        = 5;   // Take profit

input bool    restrictedHours   = true; // Restringir horários?
input int     hourToStart       = 10;    // Início
input int     hourToFinish      = 15;   // Término

int   input   profitLimit       = 99999;
int   input   lossLimit         = 25000;


int   input   minimumRSI        = 40;
int   input   maximumRSI        = 70;
int   input   minimumStc        = 40;
int   input   maximumStc        = 80;
int   input   minimumCandleSize = 10;


int OnInit() {

  SetIndexBuffer(0, iRSIBuffer,INDICATOR_DATA);
  
  handleRSI = iRSI(symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  
  if(handleRSI == INVALID_HANDLE) {
  
    PrintFormat(
      "Falha ao criar o manipulador do indicador iRSI.",
      symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );
    
    return(INIT_FAILED);
  }
  
  
  
  SetIndexBuffer(0, StochasticBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);
  
  handleStoch = iStochastic(symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
  
  
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (!restrictHours()) {
  
    if (Candle::newBar()) {
    
      bool hasPosition = PositionSelect(_Symbol);
      
      if (!hasPosition) {
        
        CopyBuffer(handleRSI, 0, 0, 5, iRSIBuffer);
        
        CopyBuffer(handleStoch, MAIN_LINE, 0, 5, StochasticBuffer);
        
        CopyBuffer(handleStoch, SIGNAL_LINE, 0, 5, SignalBuffer);
        
        if (isOverbought()) {
        
          SellAtMarket(stopLoss, takeProfit);
        } else if (isOversold()) {
        
          BuyAtMarket(stopLoss, takeProfit);
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
    &&
    candle3.getTrend() == BULLISH && candle3.getHeight() > minimumCandleSize
  ) {
    
    drawVerticalLine(iRSIBuffer[0], StochasticBuffer[0], clrSpringGreen);
  
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
    &&
    candle3.getTrend() == BEARISH && candle3.getHeight() > minimumCandleSize
  ) {
    
    drawVerticalLine(iRSIBuffer[0], StochasticBuffer[0], clrSpringGreen);
  
    return true;
  }
  
  return false;
}


void OnDeinit(const int reason) {

  if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
  
  if(handleStoch != INVALID_HANDLE) IndicatorRelease(handleStoch);
  
  Comment("");
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

