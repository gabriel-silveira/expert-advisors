#include "./include/Candle.mqh"
#include "./include/Trade.mqh"
#include "./include/HTTP-Request.mqh"

//+------------------------------------------------------------------+
//|                                             Demo_iStochastic.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            ;https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Scalping realizado através de sinais do indicador estocástico e do índice de movimento direcional médio."
 
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plotar Stochastic
#property indicator_label1  "Estocástico"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plotar Signal
#property indicator_label2  "Sinal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- definir o limite dos valores do indicador
#property indicator_minimum 0
#property indicator_maximum 100

//--- níveis horizontais na janela de indicador
#property indicator_level1  -100.0
#property indicator_level2  100.0

//--- parâmetros de entrada
int                  Kperiod = 5;                 // o período K ( o número de barras para cálculo)
int                  Dperiod = 3;                 // o período D (o período da suavização primária)
int                  slowing = 3;                 // período final da suavização
ENUM_MA_METHOD       ma_method = MODE_SMA;        // tipo de suavização
ENUM_STO_PRICE       price_field = STO_LOWHIGH;   // método de cálculo do Estocástico
string               symbol = " ";                // símbolo
ENUM_TIMEFRAMES      period = PERIOD_CURRENT;     // timeframe

//--- buffers do indicador Estocástico
int         handle;
double      StochasticBuffer[];
double      SignalBuffer[];

//--- buffers do indicador ADX
int         handleADX;
double      ADX_buffer[];
double      DIP_buffer[];
double      DIM_buffer[];

//--- variável para armazenamento
string name = _Symbol;

//--- nomes dos indicadores no gráfico
string short_name;
string short_name_ADX;


//+------------------------------------------------------------------+
//| PARÂMETROS                                                       |
//+------------------------------------------------------------------+
input double  num_lots          = 5;    // Contratos
input int     deviation         = 0;    // Desvio
input double  stopLoss          = 400;  // Stop loss
input double  takeProfit        = 50;   // Trake profit

input bool    restrictedHours   = true; // Restringir horários?
input int     hourToStart       = 10;   // Início
input int     hourToFinish      = 16;   // Término
input int     stocMin           = 20;   // Mínimo
input int     stocMax           = 80;   // Máximo
input int     adxLimit          = 60;   // Limite de ADX


// variáveis de controle
int     candleCount       = 0;
double  initialBalance    = 0;
double  previousBalance   = 0;
bool    aboveStochastic   = false;
bool    belowStochastic   = false;



//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+
int OnInit() {

  //+------------------------------------------------------------------+
  //| Estocástico                                                      |
  //+------------------------------------------------------------------+  
  //--- atribuição de arrays para buffers do indicador
  SetIndexBuffer(0, StochasticBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);
  
  //--- criar manipulador do indicador
  handle = iStochastic(
    name,
    period,
    Kperiod,
    Dperiod,
    slowing,
    ma_method,
    price_field
  );
  
  //+------------------------------------------------------------------+
  //| ADX                                                              |
  //+------------------------------------------------------------------+
  SetIndexBuffer(0, ADX_buffer, INDICATOR_DATA);
  SetIndexBuffer(1, DIP_buffer, INDICATOR_DATA);
  SetIndexBuffer(2, DIM_buffer, INDICATOR_DATA);
  
  handleADX = iADX(name, period, 9);
  
  
  //--- se o manipulador não é criado
  if(handle == INVALID_HANDLE || handleADX == INVALID_HANDLE) {
  
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador para o símbolo %s/%s, código de erro %d",
      name,
      EnumToString(period),
      GetLastError()
    );
    
    //--- o indicador é interrompido precocemente
    return(INIT_FAILED);
  }
  
  //--- labels dos indicadores
  
  short_name = StringFormat(
    "iStochastic(%s/%s, %d, %d, %d, %s, %s)",
    name,
    EnumToString(period),
    Kperiod,
    Dperiod,
    slowing,
    EnumToString(ma_method),
    EnumToString(price_field)
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  
  
  short_name_ADX = StringFormat(
    "iADX(%s/%s period=%d)",
    name,
    EnumToString(period),
    period
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name_ADX);
   
   
  
  //--- inicialização normal do indicador
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (!restrictHours()) {
      
    double currentBalance = getCurrentBalance();
    
    // reinicia contador após sair da posição
    if (
      PositionSelect(_Symbol) == false
      && previousBalance != currentBalance
    ) {
    
      candleCount = 0;
    }
  
  
    if (isEnoughForToday(currentBalance)) {
    
      if (previousBalance != currentBalance) {
      
        Print("Lucro do dia atingido! ", currentBalance);
        Print("- - - - - - - - - - - - - - -");
      }
    } else {
      
      if (Candle::newBar()) {
      
        candleCount++;
      
        CopyBuffers();
        
        CheckPosition();
      
        CheckForSignals();
      }
    }
    
    
    previousBalance = currentBalance;
  }
}



void CopyBuffers() {

  //+------------------------------------------------------------------+
  //| Estocástico                                                      |
  //+------------------------------------------------------------------+
  CopyBuffer(handle, MAIN_LINE, 0, 3, StochasticBuffer);
  CopyBuffer(handle, SIGNAL_LINE, 0, 3, SignalBuffer);
  
  ArraySetAsSeries(StochasticBuffer, true);
  ArraySetAsSeries(SignalBuffer, true);
  
  
  //+------------------------------------------------------------------+
  //| ADX                                                              |
  //+------------------------------------------------------------------+
  CopyBuffer(handleADX, 0, 0, 3, ADX_buffer);
  CopyBuffer(handleADX, 1, 0, 3, DIP_buffer);
  CopyBuffer(handleADX, 2, 0, 3, DIM_buffer);
  
  ArraySetAsSeries(ADX_buffer, true);
  ArraySetAsSeries(DIP_buffer, true);
  ArraySetAsSeries(DIM_buffer, true);
}



void CheckPosition() {
  
  if (
    PositionSelect(_Symbol)
    && candleCount > 3
  ) {
  
    Print("Encerrando em ", candleCount);
    ClosePosition();
  }
}



void CheckForSignals() {

  bool hasPosition = PositionSelect(_Symbol);
  
  if (aboveStochastic) { // verifica sinal de venda
  
    if (
      !hasPosition
      && !precededByBadCandles(false)
      && ADX_buffer[0] + DIP_buffer[0] < adxLimit
    ) {
      
        SellAtMarket(stopLoss, takeProfit);
    
        aboveStochastic = false;
        candleCount = 0;
    }
  } else if (belowStochastic) { // verifica sinal de compra

    if (
      !hasPosition
      && !precededByBadCandles(true)
      && ADX_buffer[0] + DIM_buffer[0] < adxLimit
    ) {
    
      BuyAtMarket(stopLoss, takeProfit);
    
      belowStochastic = false;
      candleCount = 0;
    }
  } else {
  
    if (candleCount > 3) {

      if (
        StochasticBuffer[1] > stocMax
        && SignalBuffer[1] > stocMax
      ) { // nível estocástico ALTO
      
        aboveStochastic = true;
      } else if (
        StochasticBuffer[1] < stocMin
        && SignalBuffer[1] < stocMin
      ) { // nível estocástico BAIXO
      
        belowStochastic = true;
      }
    }
  }
}



//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

  if(handle != INVALID_HANDLE)    IndicatorRelease(handle);
  if(handleADX != INVALID_HANDLE) IndicatorRelease(handleADX);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}



bool precededByBadCandles(bool buying) {

  Candle *candle1 = new Candle(1, 200);
  Candle *candle2 = new Candle(2, 200);
  
  // candles anteriores não podem ser dojis
  if (
    candle1.getHeight() <= 30
    && candle2.getHeight() <= 30
  ) return true;
  
  // candles anterior não pode ser marobozu
  if (
    candle1.getFigure() == MAROBOZU_UP
    || candle1.getFigure() == MAROBOZU_DOWN
  ) return true;
  
  if (
    buying &&
    Candle::getPattern(candle1, candle2) == BEARISH_ENGULFING
  ) return true;
  
  if (
    !buying &&
    Candle::getPattern(candle1, candle2) == BULLISH_ENGULFING
  ) return true;
  
  return false;
}



double getCurrentBalance() {

  if (Candle::newDay()) {
  
    initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  }
  
  return AccountInfoDouble(ACCOUNT_BALANCE) - initialBalance;
}



bool restrictHours() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);

  if (restrictedHours) {
  
    if (structNow.hour < hourToStart) return true;
    
    if (structNow.hour > hourToFinish) return true;
  }
  
  return false;
}



bool isEnoughForToday(double balance) {

  return balance >= 1000 || balance < -500;
}

