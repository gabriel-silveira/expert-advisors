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

void InitStochastic(int pK, int pD, int pSlowing) {

  SetIndexBuffer(0, StochasticBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);
  
  handleStoch = iStochastic(_Symbol, PERIOD_CURRENT, pK, pD, pSlowing, MODE_SMA, STO_LOWHIGH);
}

void CopyStochasticBuffers() {

  CopyBuffer(handleStoch, MAIN_LINE, 0, 5, StochasticBuffer);
  
  ArraySetAsSeries(StochasticBuffer, true);
  
  CopyBuffer(handleStoch, SIGNAL_LINE, 0, 5, SignalBuffer);
  
  ArraySetAsSeries(SignalBuffer, true);
}