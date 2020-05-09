#include "./include/Candle.mqh"
#include "./include/Trade.mqh"
#include "./include/HTTP-Request.mqh"

#property copyright "Gabriel Silveira, Desenvolvedor de Software e Trader"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Este EA tem o objetivo de fazer scalps de 70 pontos"
#property description "se guiando pelo movimento dos últimos 10 candles"


//+------------------------------------------------------------------+
//| ADX                                                              |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- ADX
#property indicator_label1  "ADX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- DI+
#property indicator_label2  "DI_plus"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- DI-
#property indicator_label3  "DI_minus"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWheat
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- buffers do indicador
double         ADX[];
double         DIP[];
double         DIM[];

//--- variável para armazenar o manipulador do indicador iADX
int    handle;

string short_name;



//+------------------------------------------------------------------+
//| PARÂMETROS                                                       |
//+------------------------------------------------------------------+
input double num_lots   = 1; // Contratos
input int deviation     = 5;   // Desvio
input double stopLoss   = 210; // Stop loss
input double takeProfit = 70; // Trake profit
input bool restrictedHours = true; // Restringir horários?

int candleCount;

int numCandles;

MqlRates candleRates[];

int lastTrendIndex;
int trendIndex;

enum Trend {
  NONE,
  BUY,
  SELL
};

Trend currTrend;

//+------------------------------------------------------------------+
//| BALANCE                                                          |
//+------------------------------------------------------------------+
double initialAccountBalance = 0;
double previousBalance = 0;



int OnInit() {

  //--- atribuição de arrays para buffers do indicador
  SetIndexBuffer(0, ADX, INDICATOR_DATA);
  SetIndexBuffer(1, DIP, INDICATOR_DATA);
  SetIndexBuffer(2, DIM, INDICATOR_DATA);
  
  handle = iADX(_Symbol, _Period, 14);
  
  if (handle == INVALID_HANDLE) return(INIT_FAILED);
  
  ArraySetAsSeries(ADX, true);
  ArraySetAsSeries(DIP, true);
  ArraySetAsSeries(DIM, true);
  
  short_name = StringFormat(
    "iADX(%s/%s period=%d)",
    _Symbol,
    EnumToString(_Period),
    14
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  
  
  
  candleCount = 0;
  
  numCandles = 10;
  
  lastTrendIndex = 0;
  
  trendIndex = 0;
  
  currTrend = NONE;
  
  previousBalance = 0;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  CopyBuffer(handle, 0, 0, 3, ADX);
  CopyBuffer(handle, 1, 0, 3, DIP);
  CopyBuffer(handle, 2, 0, 3, DIM);
  
  // horário restrito de operação
  if (!checkRestrictedHours()) {
    
    if (Candle::newBar()) {
          
      double currentBalance = getCurrentBalance();
      
      if (previousBalance != currentBalance) {
      
        candleCount = 0;
        
        // registerBalance(currentBalance);
      }
      else
        candleCount++;
      
      
      if (PositionSelect(_Symbol) == true) {
      
        currTrend = NONE;
      } else {
        
        // no início da operação e após um fechamento de ordem
        // após 10 candles
        if (candleCount > 10) {
        
          if (getRates()) {
            
            setTrendIndex();
            
            if (bullish()) {
              BuyAtMarket(stopLoss, takeProfit);
              logADX();
            }
            
            if (bearish()) {
              SellAtMarket(stopLoss, takeProfit);
              logADX();
            }
            
            lastTrendIndex = trendIndex;
          }
        }
        
        previousBalance = currentBalance;
      }
    }
  }
}


void logADX() {

  Print("ADX: ", ADX[0]);
  Print("DI+: ", DIP[0]);
  Print("DI-: ", DIM[0]);
  Print(". . . . . . . . ");
}


bool getRates() {

  int copied = CopyRates(_Symbol, _Period, 0, numCandles + 2, candleRates);
  
  if (copied > 0) {
  
    ArraySetAsSeries(candleRates, true);
    
    return true;
  } else {
    
    return false;
  }
}


bool bullish() {

  if (
    ADX[0] < DIP[0]
    && ADX[0] < DIM[0]
  ) return false;

  if (
    trendIndex > 0
    && lastTrendIndex < 0
    && currTrend != NONE
  ) {
  
    return !(ADX[0] < 25 && DIP[0] < DIM[0]);
  } else {
  
    currTrend = BUY;
    
    return false;
  }
}


bool bearish() {

  if (
    ADX[0] < DIP[0]
    && ADX[0] < DIM[0]
  ) return false;

  if (
    trendIndex < 0 && lastTrendIndex > 0
    && currTrend != NONE
  ) {
  
    return !(ADX[0] < 25 && DIM[0] < DIP[0]);
  } else {
  
    currTrend = SELL;
    
    return false;
  }
}


void setTrendIndex() {
       
  trendIndex = 0;
  
  for (int i = numCandles + 1; i > 0; i--) {
    
    if (candleRates[i-1].close > candleRates[i].close)
      trendIndex++;
    else
      trendIndex--;
  }
}



double getCurrentBalance() {

  if (Candle::newDay()) {
  
    initialAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  }
  
  return AccountInfoDouble(ACCOUNT_BALANCE) - initialAccountBalance;
}



bool checkRestrictedHours() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);

  if (restrictedHours) {
  
    // if (structNow.hour < 10) return true;
    
    if (structNow.hour > 16) return true;
  }
  
  return false;
}


