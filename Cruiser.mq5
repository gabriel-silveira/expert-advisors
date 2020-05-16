#include "include/Candle.mqh"
#include "include/Trade.mqh"
#include "include/HTTP-Request.mqh"

#property copyright "Gabriel Silveira, Desenvolvedor de Software e Trader"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Este EA tem o objetivo de fazer scalps de 50 pontos"
#property description "quando um candle cruza a média móvel de 9 períodos"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- desenhando iRSI
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1



//+------------------------------------------------------------------+
//| Configuração do mini índice para CRUISER                         |
//+------------------------------------------------------------------+

input bool restrictedHours = true;

input double num_lots   = 1; // Contratos
input int deviation     = 0;   // Desvio

input int div3; //  - - - Lucro / Risco - - -
input double stopLoss   = 100;
input double takeProfit = 50;

input int hourToStart = 10;
input int hourToFinish = 13;

input int                  ma_period      = 9; // Períodos
input ENUM_APPLIED_PRICE   applied_price  = PRICE_CLOSE; // Tipo de preço
input ENUM_TIMEFRAMES      period         = PERIOD_CURRENT; // Timeframe


//--- buffer do indicador
double iEMABuffer[];

//--- variável para armazenar o manipulador do indicator iRSI
int handle;

//--- variável para armazenamento
string name;

//--- nome do indicador num gráfico
string short_name;


//--- variáveis de controle
double initialAccountBalance = 0;
double previousBalance = 0;
double todayBalance;
double enoughForToday = false;

int candleCount = 0;

double tradePrice;

bool stopOperation = false;

enum OrderType {
  NONE,
  BUY,
  SELL
};


//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+

int OnInit() {

  name = _Symbol;

  //--- atribuição de array para buffer do indicador
  SetIndexBuffer(0, iEMABuffer, INDICATOR_DATA);
  
  //--- determinar o símbolo do indicador
  name = _Symbol;
  
  handle = iMA(name, period, ma_period, 0, MODE_EMA, applied_price);
  
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

  // horário restrito de operação
  if (!checkRestrictedHours()) {

    if (
      PositionSelect(_Symbol) == false
      && !stopOperation
    ) {
      
      double currentBalance = getCurrentBalance();
      
      if (
        !isEnoughForToday(currentBalance)
        && Candle::newBar()
      ) {
        
        candleCount++;
      
        // fechou posição
        if (previousBalance != currentBalance) {
        
          candleCount = 4;
          
          Print("- - - - - Balanço: ", currentBalance, " - - - - -");
      
          // registerBalance(currentBalance);
        }
        
        
        
        //if (candleCount > 5)
          startTrade();
        
        
        
        previousBalance = currentBalance;
        
        if (stopOperation) Print("Operação encerrada por falha execução da ordem.");
      }
    }// else
    
      // checkOrderClosure();
  }
}



void checkOrderClosure() {
      
  if (Candle::newBar()) candleCount++;
  
  // Print("Candles: ", candleCount);

  if (candleCount > 3) {
  
    SymbolInfoTick(_Symbol, tick);
    
    bool positionBuyed = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? true : false;
    
    Print(tick.bid, " < ", tradePrice, " | ", tradePrice - 25);
    Print(tick.ask, " > ", tradePrice, " | ", tradePrice + 25);
    
    if (
      (positionBuyed && tick.bid < tradePrice - 25)
      ||
      (!positionBuyed && tick.ask > tradePrice + 25)
    )
      ClosePosition();
  }
}



void startTrade() {
        
  CopyBuffer(handle, 0, 0, 3, iEMABuffer);
  
  ArraySetAsSeries(iEMABuffer, true);
  
  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  Candle *candle1 = new Candle(1, 0);
  Candle *candle2 = new Candle(2, 0);
  
  double iEMABuffer1 = iEMABuffer[1];
  double iEMABuffer2 = iEMABuffer[2];
  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  
  OrderType type = NONE;
  
  
  // bool crossingUp = candle1.getClose() > iEMABuffer1 && candle2.getClose() < iEMABuffer2;
  // bool crossingDown = candle1.getClose() < iEMABuffer1 && candle2.getClose() > iEMABuffer2;
  
  bool crossingUp = candle1.getOpen() < iEMABuffer1 && candle1.getClose() > iEMABuffer1;
  bool crossingDown = candle1.getOpen() > iEMABuffer1 && candle1.getClose() < iEMABuffer1;
  
  // distância entre a FECHAMENTO do candle anterior
  // e a média móvel anterior
  double distanceFromEMA1 = MathAbs(candle1.getClose() - iEMABuffer1);

  if (distanceFromEMA1 < 80) {
  
    if (crossingDown)
      type = BUY;
    
    
    if (crossingUp)
      type = SELL;
    
    
    if (type == BUY)
      tradePrice = BuyAtMarket(stopLoss, takeProfit);
    
    if (type == SELL)
      tradePrice = SellAtMarket(stopLoss, takeProfit);
    
    
    if (type != NONE) {
    
      if (!tradePrice)
         stopOperation = true;
  
      candleCount = 0;
    }
  }
}



bool isEnoughForToday(double currentBalance) {

  return currentBalance >= 200 || currentBalance < -100;
}



bool closeCondition(Candle &candle) {
  
  double diff = MathAbs(candle.getClose() - tradePrice);
  
  Print(candle.getClose(), " | ", tradePrice);
  
  bool positionBuyed = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? true : false;

  return (positionBuyed && candle.getClose() < tradePrice)
    || (!positionBuyed && candle.getClose() > tradePrice);
  
  return false;
}



void registerBalance(double amount) {

  HttpRequest *http = new HttpRequest("http://127.0.0.1:7000");
  
  char body[];
  
  string queryParams;
  StringConcatenate(
    queryParams,
    "amount=", amount,
    "&symbol=", _Symbol,
    "&lots=", num_lots,
    "&robot=Cruiser"
  );
  
  http.post("balance", queryParams);
}



double getCurrentBalance() {

  if (Candle::newDay()) {
    
    initialAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  }

   return AccountInfoDouble(ACCOUNT_BALANCE) - initialAccountBalance;
}



bool checkRestrictedHours() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);

  if (restrictedHours) {
  
    if (structNow.hour < hourToStart) return true;
    
    if (structNow.hour > hourToFinish) return true;
  }
  
  return false;
}






