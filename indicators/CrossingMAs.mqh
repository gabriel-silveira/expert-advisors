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


void InitCrossingMAs(
  int simplePeriods,
  int exponentialPeriods
) {

  InitAMA(simplePeriods);
  
  InitEMA(exponentialPeriods);
}


bool crossingUp() {

  Print(iAMABuffer[0], " < ", iEMABuffer[0]);
  Print(iAMABuffer[1], " > ", iEMABuffer[1]);
  Print("");

  // EMA 8 > AMA 21
  if (
       iAMABuffer[0] < iEMABuffer[0]
    && iAMABuffer[1] > iEMABuffer[1]
  ) {
    
    return true;
  }
  
  return false;
}



bool crossingDown() {

  Print(iAMABuffer[0], " > ", iEMABuffer[0]);
  Print(iAMABuffer[1], " < ", iEMABuffer[1]);
  Print("");

  // EMA 8 < AMA 21
  if (
       iAMABuffer[0] > iEMABuffer[0]
    && iAMABuffer[1] < iEMABuffer[1]
  ) {
    
    return true;
  }
  
  return false;
}



void InitAMA(int simplePeriods) {

  SetIndexBuffer      (0, iAMABuffer, INDICATOR_DATA);
  PlotIndexGetInteger (0, PLOT_LINE_COLOR, clrFuchsia);
  PlotIndexGetInteger (0, PLOT_LINE_WIDTH, 2);
  
  handleAMA = iMA(_Symbol, PERIOD_CURRENT, simplePeriods, 0, MODE_SMA, PRICE_CLOSE);
}



void InitEMA(int exponentialPeriods) {

  SetIndexBuffer      (0, iEMABuffer, INDICATOR_DATA);
  PlotIndexGetInteger (0, PLOT_LINE_COLOR, clrSpringGreen);
  PlotIndexGetInteger (0, PLOT_LINE_WIDTH, 2);
  
  handleEMA = iMA(_Symbol, PERIOD_CURRENT, exponentialPeriods, 0, MODE_EMA, PRICE_CLOSE);
}


bool CopyAMABuffer() {

  CopyBuffer(handleAMA, 0, 0, 10, iAMABuffer);
  ArraySetAsSeries(iAMABuffer, true);
  
  return true;
}

bool CopyEMABuffer() {

  //+------------------------------------------------------------------+
  //| iEMA                                                             |
  //+------------------------------------------------------------------+
  CopyBuffer(handleEMA, 0, 0, 10, iEMABuffer);
  ArraySetAsSeries(iEMABuffer, true);
  
  return true;
}

void CopyCrossingMAsBuffers() {
  
  CopyAMABuffer();
  
  CopyEMABuffer();
}


