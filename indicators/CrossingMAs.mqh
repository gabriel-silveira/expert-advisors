#property indicator_chart_window
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


void initCrossingMAs() {

  initAMA();
  
  initEMA();
}


bool crossingUp() {

  // EMA 8 > AMA 21
  if (
       iAMABuffer[0] < iEMABuffer[0]
    && iAMABuffer[1] > iEMABuffer[1]
  ) {
  
    drawVerticalLine("Cruzamento para cima", iAMABuffer[0], iEMABuffer[0], clrSpringGreen);
    
    return true;
  }
  
  return false;
}



bool crossingDown() {

  // EMA 8 < AMA 21
  if (
       iAMABuffer[0] > iEMABuffer[0]
    && iAMABuffer[1] < iEMABuffer[1]
  ) {
  
    drawVerticalLine("Cruzamento para baixo", iAMABuffer[0], iEMABuffer[0], clrFuchsia);
    
    return true;
  }
  
  return false;
}



void initAMA() {

  SetIndexBuffer(0, iAMABuffer, INDICATOR_DATA);
  PlotIndexGetInteger(0, PLOT_LINE_COLOR, clrFuchsia);
  PlotIndexGetInteger(0, PLOT_LINE_WIDTH, 2);
  
  handleAMA = iMA(symbolName, PERIOD_CURRENT, 21, 0, MODE_SMA, PRICE_CLOSE);
}



void initEMA() {

  SetIndexBuffer(0, iEMABuffer, INDICATOR_DATA);
  PlotIndexGetInteger(0, PLOT_LINE_COLOR, clrSpringGreen);
  PlotIndexGetInteger(0, PLOT_LINE_WIDTH, 2);
  
  handleEMA = iMA(symbolName, PERIOD_CURRENT, 8, 0, MODE_EMA, PRICE_CLOSE);
}


void CopyCrossingMAsBuffers() {

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
}


