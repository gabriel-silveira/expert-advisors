#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "iATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

int           atr_period;

//--- buffer do indicador
double        iATRBuffer[];

//--- variável para armazenamento do manipulador do indicador iAC
int           handleATR;

//--- nome do indicador num gráfico
string        short_name_atr;


bool InitATR(int pAtr_period) {
  
  atr_period = pAtr_period;

  SetIndexBuffer(0, iATRBuffer, INDICATOR_DATA);
  
  handleATR = iATR(
    _Symbol,
    PERIOD_CURRENT,
    atr_period
  );
  
  if (handleATR == INVALID_HANDLE) {
  
    PrintFormat(
      "Falha ao criar o manipulador do indicador iATR para o símbolo %s/%s, código de erro %d",
      _Symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );
    
    return false;
  }
  
  short_name_atr = StringFormat(
    "iATR(%s/%s, period=%d)",
    _Symbol,
    EnumToString(PERIOD_CURRENT),
    atr_period
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name_atr);
  
  return true;
}


bool CopyATRBuffer() {

  ResetLastError();
  
  if(CopyBuffer(handleATR, 0, 0, 5, iATRBuffer) < 0) {
  
    PrintFormat(
      "Falha ao copiar a partir do indicador iATR , código de erro %d",
      GetLastError()
    );
    
    return false;
  } else {
  
    ArraySetAsSeries(iATRBuffer, true);
    
    return true;
  }
}


