#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plotar ADX
#property indicator_label1  "ADX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plotar DI_plus
#property indicator_label2  "DI_plus"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plotar DI_minus
#property indicator_label3  "DI_minus"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWheat
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- buffers do indicador
double              ADXBuffer[];
double              DI_plusBuffer[];
double              DI_minusBuffer[];

//--- variável para armazenar o manipulador do indicador iADX
int                 handleADX;

//--- nome do indicador num gráfico
string              short_name;



void InitADX(int adx_period) {

  //--- atribuição de arrays para buffers do indicador
  SetIndexBuffer(0, ADXBuffer,       INDICATOR_DATA);
  SetIndexBuffer(1, DI_plusBuffer,   INDICATOR_DATA);
  SetIndexBuffer(2, DI_minusBuffer,  INDICATOR_DATA);
  
  handleADX = iADX(_Symbol, PERIOD_CURRENT, adx_period);
  
  //--- se o manipulador não é criado
  if (handleADX == INVALID_HANDLE) {
  
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador iADX para o símbolo %s/%s, código de erro %d",
      _Symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );
  }
  
  //--- mostrar o símbolo/prazo, o indicador de Average Directional Movement Index é calculado para
  short_name = StringFormat("iADX(%s/%s period=%d)", _Symbol, EnumToString(PERIOD_CURRENT), adx_period);
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
}



bool CopyADXBuffers(
  int amount
) {

  CopyBuffer(handleADX, 0, 0, amount, ADXBuffer);
  CopyBuffer(handleADX, 1, 0, amount, DI_plusBuffer);
  CopyBuffer(handleADX, 2, 0, amount, DI_minusBuffer);
  
  ArraySetAsSeries(ADXBuffer, true);
  ArraySetAsSeries(DI_plusBuffer, true);
  ArraySetAsSeries(DI_minusBuffer, true);
  
  return true;
}


