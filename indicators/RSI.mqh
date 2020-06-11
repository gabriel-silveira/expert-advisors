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

void InitRSI(int rsi_period) {

  SetIndexBuffer(0, iRSIBuffer,INDICATOR_DATA);
  
  handleRSI = iRSI(_Symbol, PERIOD_CURRENT, rsi_period, PRICE_CLOSE);
  
  if(handleRSI == INVALID_HANDLE) {
  
    PrintFormat(
      "Falha ao criar o manipulador do indicador iRSI.",
      _Symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );
  }
}


void CopyRSIBuffers() {

  CopyBuffer(handleRSI, 0, 0, 5, iRSIBuffer);
  
  ArraySetAsSeries(iRSIBuffer, true);
}