#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Estratégia:"
#property description ""
#property description "\n"
#property description "Objetivo:"
#property description "Buscar lucro de R$ 200 por negociação / loss de R$ 160"
#property description "\n"
#property description "Alvo:"
#property description "400 pontos, 2 lotes"
#property description "\n"
#property description "Lucro / Risco:"
#property description "Alta 0.8"

#include "./include/inc.mqh"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plotar iAMA
#property indicator_label1  "iAMA_Close"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFuchsia
#property indicator_style1  STYLE_DASH
#property indicator_width1  2

//--- plotar iEMA
#property indicator_label1  "iAMA_Open"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2


//--- buffer do indicador
double          iAMAOpenBuffer[];
int             handle_OpenAMA;

double          iAMACloseBuffer[];
int             handle_CloseEMA;


#include "./indicators/ADX.mqh"


string        expertName              = "CMAS";

ENUM_TIMEFRAMES input tf = PERIOD_M10; // Timeframe

double        profitLimit;                              // Limite diário de ganho
double        input lossLimit         = 1;              // Limite diário de perda

int           input tp                = 400;             // TP
int           input sl                = 400;            // SL

int           input lots              = 1;              // Lots

int           input minVolume         = 30000;          // Volume mínimo

TradeOrder *Order = new TradeOrder(
  115599,
  tp,
  sl,
  lots,
  expertName,
  10,
  17
);


int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, tf);

  profitLimit = (tp * 0.2) * 2;
  

  SetIndexBuffer      (0, iAMAOpenBuffer, INDICATOR_DATA);
  PlotIndexGetInteger (0, PLOT_LINE_COLOR, clrSpringGreen);
  PlotIndexGetInteger (0, PLOT_LINE_WIDTH, 2);
  handle_OpenAMA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_OPEN);
  
  SetIndexBuffer      (0, iAMACloseBuffer, INDICATOR_DATA);
  PlotIndexGetInteger (0, PLOT_LINE_COLOR, clrFuchsia);
  PlotIndexGetInteger (0, PLOT_LINE_WIDTH, 2);
  handle_CloseEMA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
  
  
  InitADX(14);
  
  
  return(INIT_SUCCEEDED);
}





void OnTick() {
  
  if (
    Order.ReadyToGo()
  ) {
  
    CopyADXBuffers();
    
    CopyBuffer(handle_OpenAMA, 0, 0, 10, iAMAOpenBuffer);
    ArraySetAsSeries(iAMAOpenBuffer, true);
  
    CopyBuffer(handle_CloseEMA, 0, 0, 10, iAMACloseBuffer);
    ArraySetAsSeries(iAMACloseBuffer, true);
    
    CheckSignals();
  }
}



void CheckSignals() {
    
  Candle *c1 = new Candle(1, 150);
  
  if (
    iAMAOpenBuffer[1] > iAMACloseBuffer[1]
    &&
    iAMAOpenBuffer[2] > iAMACloseBuffer[2]
    &&
    iAMAOpenBuffer[3] < iAMACloseBuffer[3]
    &&
    iAMAOpenBuffer[4] < iAMACloseBuffer[4]
    
    &&
    DI_plusBuffer[1] > DI_minusBuffer[1]
  ) {
  
    Order.Sell();
  }
  
  
  if (
    iAMAOpenBuffer[1] < iAMACloseBuffer[1]
    &&
    iAMAOpenBuffer[2] < iAMACloseBuffer[2]
    &&
    iAMAOpenBuffer[3] > iAMACloseBuffer[3]
    &&
    iAMAOpenBuffer[4] > iAMACloseBuffer[4]
    
    &&
    DI_plusBuffer[1] < DI_minusBuffer[1]
  ) {
  
    Order.Buy();
  }
}



void OnDeinit(const int reason) {

  if(handle_OpenAMA != INVALID_HANDLE) IndicatorRelease(handle_OpenAMA);
  
  if(handle_CloseEMA != INVALID_HANDLE) IndicatorRelease(handle_CloseEMA);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}
