// #include "config/Morning-Scalper-WDO.mqh"
#include "config/Morning-Scalper-WIN.mqh"
#include "include/Candle.mqh"
#include "include/Trade.mqh"

#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "O indicador demonstra como obter dados"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- desenhando iRSI
#property indicator_label1  "iRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- limites para mostrar os valores na janela do indicador
#property indicator_maximum 100
#property indicator_minimum 0

//--- níveis horizontais na janela de indicador
#property indicator_level1  70.0
#property indicator_level2  30.0


//--- parâmetros de entrada
input int                  ma_period = 10;                 // Períodos
input ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;    // tipo de preço
input ENUM_TIMEFRAMES      period = PERIOD_CURRENT;        // timeframe

//--- buffer do indicador
double iRSIBuffer[];

//--- variável para armazenar o manipulador do indicator iRSI
int handle;

//--- variável para armazenamento
string name = _Symbol;

//--- nome do indicador num gráfico
string short_name;

//--- manteremos o número de valores no indicador Relative Strength Index
int    bars_calculated=0;


//--- variáveis de controle
double initialAccountBalance = 0;
double previousBalance = 0;
double todayBalance;
double enoughForToday = false;


//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+
int OnInit() {

  //--- atribuição de array para buffer do indicador
  SetIndexBuffer(0, iRSIBuffer, INDICATOR_DATA);
  
  //--- determinar o símbolo do indicador
  name = _Symbol;
  
  handle = iRSI(name, period, ma_period, applied_price);
  
  if (handle == INVALID_HANDLE) {
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador iRSI para o símbolo %s/%s, código de erro %d",
      name,
      EnumToString(period),
      GetLastError()
    );
    
    //--- o indicador é interrompido precocemente
    return(INIT_FAILED);
  }
  
  //--- mostra que o símbolo/prazo do indicador é Relative Strength Index
  short_name = StringFormat(
    "Índice de Força Relativa %d - %s",
    ma_period,
    name
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  
  initialAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  
  //--- inicialização normal do indicador
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (PositionSelect(_Symbol) == false && Candle::newBar()) {

    CopyBuffer(handle, 0, 0, 3, iRSIBuffer);
    
    ArraySetAsSeries(iRSIBuffer, true);
    
    double rsi = iRSIBuffer[0];
    
    Print(rsi);
  }
}


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- número de valores copiados a partir do indicador iRSI
   int values_to_copy;
//--- determinar o número de valores calculados no indicador
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() retornando %d, código de erro %d",calculated,GetLastError());
      return(0);
     }
//--- se for o princípio do cálculo do indicador, ou se o número de valores é modificado no indicador iRSI
//--- ou se é necessário cálculo do indicador para duas ou mais barras (isso significa que algo mudou no histórico do preço)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- se o array iRSIBuffer é maior do que o número de valores no indicador iRSI para o símbolo/período, então não copiamos tudo
      //--- caso contrário, copiamos menor do que o tamanho dos buffers do indicador
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- isso significa que não é a primeira vez do cálculo do indicador, é desde a última chamada de OnCalculate())
      //--- para o cálculo não mais do que uma barra é adicionada
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- preencher o array com valores do indicador iRSI
//--- se FillArrayFromBuffer retorna falso, significa que a informação não está pronta ainda, sair da operação
   if(!FillArrayFromBuffer(iRSIBuffer,handle,values_to_copy)) return(0);
//--- formar a mensagem
   string comm=StringFormat("%s ==>  Valor atualizado no indicador %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            short_name,
                            values_to_copy);
//--- exibir a mensagem de serviço no gráfico
   Comment(comm);
//--- memorizar o número de valores no indicador Relative Strength Index
   bars_calculated=calculated;
//--- retorna o valor prev_calculated para a próxima chamada
   return(rates_total);
  }














//+------------------------------------------------------------------+
//| Preencher buffers do indicador a partir do indicador             |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &rsi_buffer[],  // buffer do indicator para valores do Relative Strength Index
                         int ind_handle,        // manipulador do indicador iRSI
                         int amount             // número de valores copiados
                         )
  {
//--- redefinir o código de erro
   ResetLastError();
//--- preencher uma parte do array iRSIBuffer com valores do buffer do indicador que tem índice 0 (zero)
   if(CopyBuffer(ind_handle,0,0,amount,rsi_buffer)<0)
     {
      //--- Se a cópia falhar, informe o código de erro
      PrintFormat("Falha ao copiar dados do indicador iRSI, código de erro %d",GetLastError());
      //--- parar com resultado zero - significa que indicador é considerado como não calculado
      return(false);
     }
//--- está tudo bem
   return(true);
  }




void OnDeinit(const int reason) {
  if(handle!=INVALID_HANDLE) {
    IndicatorRelease(handle);
  }
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}
