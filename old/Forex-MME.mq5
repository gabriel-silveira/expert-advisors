#include "../include/Candle.mqh"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

//--- the iMA plot
#property indicator_label1  "FEMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed,clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1


input int                FEMA_Period            = 18;
input int                SEMA_Period            = 36;
input int                MA_Shift               = 0;
input ENUM_APPLIED_PRICE MA_Applied             = PRICE_CLOSE;
input string             symbol                 = "EURUSD"; 


int FEMA_Handle;

double FEMA_Buffer[];

int SEMA_Handle;

double SEMA_Buffer[];

string fema_short_name;

string sema_short_name;

#define MA_MAGIC 1234501



input double marobozuHeight                     = 200;

double candlesSettings[1];

input double             StopLoss               = 100.0;
input double             TakeProfit             = 100.0;

input double             Lots                   = 0.1;


//+------------------------------------------------------------------+
//| OPERANDO EM FOREX: EURUSD COM MOVING AVERAGES                     |
//+------------------------------------------------------------------+

int OnInit() {

  candlesSettings[0] = marobozuHeight;
  
  FEMA_Handle = iMA(symbol, PERIOD_M1, FEMA_Period, MA_Shift, MODE_EMA, MA_Applied);
  SetIndexBuffer(0, FEMA_Buffer, INDICATOR_DATA);
  ChartIndicatorAdd(0, 0, FEMA_Handle);
  
  
  SEMA_Handle = iMA(symbol, PERIOD_M1, SEMA_Period, MA_Shift, MODE_EMA, MA_Applied);
  SetIndexBuffer(0, SEMA_Buffer, INDICATOR_DATA);
  ChartIndicatorAdd(0, 0, SEMA_Handle);

  return(INIT_SUCCEEDED);
}


void OnTick() {
  
  if (Candle::newBar()) {
    
    CopyBuffer(FEMA_Handle, 0, 0, 3, FEMA_Buffer);
    CopyBuffer(SEMA_Handle, 0, 0, 3, SEMA_Buffer);
  
    ArraySetAsSeries(FEMA_Buffer, true);
    ArraySetAsSeries(SEMA_Buffer, true);
  
    bool positioned = PositionSelect(_Symbol) == true;
    
    if (!positioned) {
    
      Candle *candle = new Candle(1, candlesSettings, true);
      
      if (
        FEMA_Buffer[0] > SEMA_Buffer[0]
        && FEMA_Buffer[1] < SEMA_Buffer[1]
      ) {
      
        Print("CRUZOU PRA CIMA");
        
        BuyAtMarket(StopLoss, TakeProfit);
      } else if (
        FEMA_Buffer[0] < SEMA_Buffer[0]
        && FEMA_Buffer[1] > SEMA_Buffer[1]
      ) {
      
        Print("CRUZOU PRA BAIXO");
        
        SellAtMarket(StopLoss, TakeProfit);
      }
    }
    /*
    Print(candle.getOpen());
    Print(candle.getClose());
    Print(FEMA_Buffer[0]);
    Print(candle.getClose() > FEMA_Buffer[0] && candle.getOpen() < FEMA_Buffer[0]); */
  }
}
