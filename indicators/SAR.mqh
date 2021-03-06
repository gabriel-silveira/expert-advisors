#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- desenhando iSAR
#property indicator_label1  "iSAR"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrPurple
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1



//--- parâmetros de entrada
input double               step     = 0.02;                    // passo - o fator de aceleração para arrastar as paradas
input double               maximum  = 0.2;                  // máximo valor do passo
input string               symbol   = " ";                   // símbolo


//--- buffers do indicador
double          iSARBuffer[];

//--- variável para armazenar o manipulador do indicator iSAR
int             SARhandle;

//--- nome do indicador num gráfico
string          short_sar_name;

//--- manteremos o número de valores no indicador Parabolic SAR
int             bars_calculated = 0;


void InitSAR() {

  //--- atribuição de array para buffer do indicador
  SetIndexBuffer(0, iSARBuffer, INDICATOR_DATA);
  
  //--- definir um código de símbolo do conjunto de caracteres Wingdings para a propriedade PLOT_ARROW para exibir num gráfico
  PlotIndexSetInteger(0, PLOT_ARROW, 159);
  
  SARhandle = iSAR(_Symbol, PERIOD_CURRENT, step, maximum);
  
  if(SARhandle == INVALID_HANDLE) {
  
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador iSAR para o símbolo %s/%s, código de erro %d",
      _Symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );
    
   short_sar_name = StringFormat(
    "iSAR(%s/%s, %G, %G)",
    _Symbol,
    EnumToString(PERIOD_CURRENT),
    step,
    maximum
   );
   
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  }
}



void CopySARBuffer() {

  CopyBuffer(SARhandle, 0, 0, 5, iSARBuffer);
  
  ArraySetAsSeries(iSARBuffer, true);
}


