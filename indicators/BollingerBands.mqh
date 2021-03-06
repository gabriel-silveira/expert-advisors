#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plotar linha superior
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plotar linha inferior
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plotar linha média
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1


//--- parâmetros de entrada
int                  bands_period  = 20;             // período da média móvel
int                  bands_shift   = 0;              // deslocamento
double               deviation     = 2.0;            // número de desvios padrão
ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;    // tipo de preço

//--- buffers do indicador
double              UpperBuffer[];
double              LowerBuffer[];
double              MiddleBuffer[];

//--- variável para armazenar o manipulador do indicador iBands
int                 handleBollinger;

//--- nome do indicador num gráfico
string              short_name_bollinger;



bool InitBollingerBands(
  int periods
) {
  
  //--- atribuição de arrays para buffers do indicador
  SetIndexBuffer(0, UpperBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, LowerBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, MiddleBuffer, INDICATOR_DATA);
  
  //--- definir o deslocamento de cada linha
  PlotIndexSetInteger(0, PLOT_SHIFT, bands_shift);
  PlotIndexSetInteger(1, PLOT_SHIFT, bands_shift);
  PlotIndexSetInteger(2, PLOT_SHIFT, bands_shift);
  
  handleBollinger = iBands(
    _Symbol,
    PERIOD_CURRENT,
    periods,
    bands_shift,
    deviation,
    applied_price
  );
  
  //--- se o manipulador não é criado
  if(handleBollinger == INVALID_HANDLE) {
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador iBands para o símbolo %s/%s, código de erro %d",
      _Symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );
    
    //--- o indicador é interrompido precocemente
    return false;
  }
  
  //--- mostra que o símbolo/prazo do indicador Bollinger Bands é calculado para
  short_name_bollinger = StringFormat(
    "iBands(%s/%s, %d,%d,%G,%s)",
    _Symbol,
    EnumToString(PERIOD_CURRENT),
    bands_period,
    bands_shift,
    deviation,
    EnumToString(applied_price)
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name_bollinger);
  
  return true;
}



bool CopyBollingerBandsBuffer(int amount) {
  
  
  //--- preencher uma parte do array MiddleBuffer com valores do buffer do indicador que tem índice 0 (zero)
  if(CopyBuffer(handleBollinger, 0, 0, amount, MiddleBuffer) < 0) {
  
    //--- Se a cópia falhar, informe o código de erro
    PrintFormat("Falha ao copiar dados do indicador iBands, código de erro %d",GetLastError());
    
    //--- parar com resultado zero - significa que indicador é considerado como não calculado
    return(false);
  }
  
  ArraySetAsSeries(MiddleBuffer, true);
  
  
  
  //--- preencher uma parte do array UpperBuffer com valores do buffer do indicador que tem índice 1
  if(CopyBuffer(handleBollinger, 1, 0, amount, UpperBuffer) < 0) {
  
    //--- Se a cópia falhar, informe o código de erro
    PrintFormat("Falha ao copiar dados do indicador iBands, código de erro %d",GetLastError());
    
    //--- parar com resultado zero - significa que indicador é considerado como não calculado
    return(false);
  }
  
  ArraySetAsSeries(UpperBuffer, true);
  
  
  
  //--- preencher uma parte do array LowerBuffer com valores do buffer do indicador que tem o índice 2
  if(CopyBuffer(handleBollinger, 2, 0, amount, LowerBuffer) < 0) {
  
    //--- Se a cópia falhar, informe o código de erro
    PrintFormat("Falha ao copiar dados do indicador iBands, código de erro %d",GetLastError());
    
    //--- parar com resultado zero - significa que indicador é considerado como não calculado
    return(false);
  }
  
  ArraySetAsSeries(LowerBuffer, true);
  
  
  return true;
}
