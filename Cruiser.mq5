#include "include/signature.mqh"
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

input bool restrictedHours = false;

input double num_lots   = 1; // Contratos
input int deviation     = 10;   // Desvio

input int div3; //  - - - Lucro / Risco - - -
input double stopLoss   = 250;
input double takeProfit = 50;

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

bool buyed = false;

double tradePrice;

bool stopOperation = false;

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
        
          candleCount = -2;
          
          Print("- - - - - Balanço: ", currentBalance, " - - - - -");
      
          registerBalance(currentBalance);
        }
        
        CopyBuffer(handle, 0, 0, 3, iEMABuffer);
        
        ArraySetAsSeries(iEMABuffer, true);
        
        
        
        Candle *candle1 = new Candle(1, 0);
        Candle *candle2 = new Candle(2, 0);
        
        
        if (candleCount > 0)
          startTrade(
            candle1,
            candle2,
            iEMABuffer[0],
            iEMABuffer[1]
          );
        
        
        
        previousBalance = currentBalance;
        
        if (stopOperation) Print("Operação encerrada por falha execução da ordem.");
      }
    } else {
        
      candleCount++;
      
      /* if (Candle::newBar()) {
      
        Candle *candle = new Candle(1, 0);
        
        candleCount++;
        
        Print("Candles: ", candleCount);
        
        //+------------------------------------------------------------------+
        //| ENCERRAR SOMENTE SE ESTIVER COM PERIGO DE LOSS                   |
        //+------------------------------------------------------------------+
        if (closeCondition(candle)) {
          
          
          Print("Diff: ", MathAbs(candle.getClose() - tradePrice));
          
          if (ClosePosition(buyed)) {
          
            Print("POSIÇÃO ENCERRADA POR RISCO");
          }
        }
      }*/
    }
  }
}



bool isEnoughForToday(double currentBalance) {

  return currentBalance >= 500 || currentBalance < -100;
}



bool closeCondition(Candle &candle) {
  
  double diff = MathAbs(candle.getClose() - tradePrice);
  
  if (candleCount > 10) {
  
    Print(candle.getClose(), " | ", tradePrice);
  
    return (buyed && candle.getClose() < tradePrice)
      || (!buyed && candle.getClose() > tradePrice);
  }
  
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
    "&lots=", num_lots
  );
  
  http.get("balance", queryParams);
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
  
    if (structNow.hour < 10) return true;
    
    if (structNow.hour > 16) return true;
  }
  
  return false;
}



void startTrade(
  Candle &candle1,
  Candle &candle2,
  double iEMABuffer1,
  double iEMABuffer2
) {
        
  double diff = MathAbs(candle1.getClose() - candle1.getOpen());
  
  bool crossingDown = candle1.getClose() > iEMABuffer1 && candle2.getClose() < iEMABuffer2;
  
  bool crossingUp = candle1.getClose() < iEMABuffer1 && candle2.getClose() > iEMABuffer2;

  if (diff < 100) {
  
    if (crossingDown) {
    
        tradePrice = BuyAtMarket(stopLoss, takeProfit);
        
        if (tradePrice)
           buyed = true;
        else 
           stopOperation = true;
    
        candleCount = 0;
    }
    
    if (crossingUp) {
    
        tradePrice = SellAtMarket(stopLoss, takeProfit);
        
        if (tradePrice)
           buyed = false;
        else 
           stopOperation = true;
    
        candleCount = 0;
    }
  }
  
  if (diff > 150) {
    
  }
}




