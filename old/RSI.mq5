#include "config/RSI.mqh"
#include "include/Candle.mqh"
#include "include/Trade.mqh"
#include "include/HTTP-Request.mqh"

#property copyright "Gabriel Silveira, Desenvolvedor de software e trader"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "WDO / WIN"
#property description "RSI"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

//--- desenhando iRSI
#property indicator_label1  "iRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- buffer do indicador
double iRSIBuffer[];

//--- variável para armazenar o manipulador do indicator iRSI
int handle;

//--- variável para armazenamento
string name;

//--- nome do indicador num gráfico
string short_name;

//--- manteremos o número de valores no indicador Relative Strength Index
int    bars_calculated = 0;


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
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);

  // horário restrito de operação
  if (structNow.hour > 9 && structNow.hour < 17) {

    if (
      PositionSelect(_Symbol) == false
      && !stopOperation
    ) {
    
      candleCount = 0;
    
      if (Candle::newDay()) {
      
        enoughForToday = false;
        
        initialAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      }
    
      double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE) - initialAccountBalance;
      
      
      
      if (currentBalance >= 500 || currentBalance < -500) {
      
        if (!enoughForToday) {
          Print("- - - - - - - - - - - - - - - - - - - - - ");
          Print("Enough for today! R$ ", currentBalance);
          Print("- - - - - - - - - - - - - - - - - - - - - ");
      
          enoughForToday = true;
        }
        
        // ExpertRemove();
      } else if (!enoughForToday) {
      
        if (previousBalance != currentBalance) {
      
          registerBalance(currentBalance);
          
          Print("- - - - - Balanço: ", currentBalance, " - - - - -");
        }
        
        CopyBuffer(handle, 0, 0, 3, iRSIBuffer);
        
        ArraySetAsSeries(iRSIBuffer, true);
        
        double rsiAfter = iRSIBuffer[0];
        
        double rsiBefore = iRSIBuffer[1];
        
        if (
          (int) iRSIBuffer[1] < low
        ) {
        
            tradePrice = BuyAtMarket(stopLoss, takeProfit);
            
            if (tradePrice)
               buyed = true;
            else 
               stopOperation = true;
        
            Print("Horário: ", structNow.hour, ":", structNow.min);
        }
        
        if (
          (int) rsiAfter > high
        ) {
        
            tradePrice = SellAtMarket(stopLoss, takeProfit);
            
            if (tradePrice)
               buyed = false;
            else 
               stopOperation = true;
            
        
            Print("Horário: ", structNow.hour, ":", structNow.min);
        }
        
        previousBalance = currentBalance;
        
        if (stopOperation) Print("Operação encerrada.");
      }
    } else {
      
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

  HttpRequest *axios = new HttpRequest("http://127.0.0.1:7000");
  
  char body[];
  
  string queryParams;
  StringConcatenate(queryParams, "amount=", amount, "&symbol=", _Symbol);
  
  axios.get("balance", queryParams);
}

