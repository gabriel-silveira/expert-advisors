// #include "config/Morning-Scalper-WDO.mqh"
#include "config/Morning-Scalper-WIN.mqh"
#include "include/Candle.mqh"
#include "include/Trade.mqh"

#property copyright "Gabriel Silveira, Desenvolvedor de software e trader"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "WDO / WIN"
#property description " "
#property description "Este EA é composto basicamente de 2 estratégias:"
#property description "1. No período da manhã realiza scalps ao identificar cruzamentos de candles sobre média móvel simples;"
#property description "2. No período da tarde utiliza o distanciamento da média móvel como gatilho para negociação."
#property description " "
#property description "Observação:"
#property description "Todos testes realizados foram no tempo gráfico de 2 minutos."

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plotar iMA
#property indicator_label1  "iMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreenYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- buffer do indicador
double iMABuffer[];

//--- variável para armazenar o manipulador do indicator iMA
int handle;

enum TRADE_CONDITION {
  NONE,
  BUY,
  SELL,
  BUY_SCALP,
  SELL_SCALP
};


//--- variáveis de controle
double initialAccountBalance = 0;
double previousBalance = 0;
double todayBalance;
double enoughForToday = false;
//---



//+------------------------------------------------------------------+
//| Função de inicialização do indicador customizado                 |
//+------------------------------------------------------------------+
int OnInit() {
  //--- atribuição de array para buffer do indicador
  SetIndexBuffer(0, iMABuffer, INDICATOR_DATA);

  //--- definir deslocamento
  PlotIndexSetInteger(0, PLOT_SHIFT, 0);

  //--- criar manipulador do indicador
  handle = iMA(_Symbol, PERIOD_CURRENT, ma_period, 0, ma_method, PRICE_CLOSE);

  //--- se o manipulador não é criado
  if (handle == INVALID_HANDLE) {
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador iMA para o símbolo %s/%s, código de erro %d",
      _Symbol,
      EnumToString(PERIOD_CURRENT),
      GetLastError()
    );

    //--- o indicador é interrompido precocemente
    return(INIT_FAILED);
  }
  
  
  initialAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);

  //--- inicialização normal do indicador
  return(INIT_SUCCEEDED);
}


void OnTick() {

  if (PositionSelect(_Symbol) == false && Candle::newBar()) {
  
    // SendRequest();
  
    if (Candle::newDay()) {
    
      enoughForToday = false;
      
      initialAccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }
    
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE) - initialAccountBalance;
    
    if (previousBalance != currentBalance) Print("- - - - - Balanço: ", currentBalance, " - - - - -");
    
    if (currentBalance >= 20000 || currentBalance < -2000) {
    
      if (!enoughForToday) {
        Print("- - - - - - - - - - - - - - - - - - - - - ");
        Print("Resultado final do dia: ", currentBalance);
        Print("- - - - - - - - - - - - - - - - - - - - - ");
    
        enoughForToday = true;
      }
      
      // ExpertRemove();
    } else if (!enoughForToday) {
  
      TRADE_CONDITION tradeCondition = NONE;
      
      CopyBuffer(handle, 0, 0, 3, iMABuffer);
      
      ArraySetAsSeries(iMABuffer, true);
    
      // candle anterior
      Candle *lastCandle = new Candle(1, candleBaseHeight);
      
      // candle que precede o anterior
      Candle *precedingCandle = new Candle(2, candleBaseHeight);
      
      // candle que precede o anterior
      Candle *earlierCandle = new Candle(3, candleBaseHeight);
      
      
      tradeCondition = getTradeCondition(
        lastCandle,
        precedingCandle,
        earlierCandle,
        iMABuffer[0],
        iMABuffer[1]
      );
      
      
      
      
      if (tradeCondition == BUY) {
      
        BuyAtMarket(stopLoss, takeProfit);
        
      } else if (tradeCondition == SELL) {
      
        SellAtMarket(stopLoss, takeProfit);
        
      } else if (tradeCondition == BUY_SCALP) {
      
        SellAtMarket(SL_Scalp, TP_Scalp);
        
      } else if (tradeCondition == SELL_SCALP) {
      
        BuyAtMarket(SL_Scalp, TP_Scalp);
      }
    }
    
    previousBalance = currentBalance;
  }
}


//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

  if(handle!=INVALID_HANDLE) IndicatorRelease(handle);

  //--- limpar o gráfico após excluir o indicador
  Comment("Morning Scalper finished its job.");
}


//+------------------------------------------------------------------+
//| Analisa se a condição é compra / venda e retorna                 |
//+------------------------------------------------------------------+

TRADE_CONDITION getTradeCondition(Candle &candle1, Candle &candle2, Candle &candle3, double ma1, double ma2) {
  
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  
  
  if (structNow.hour > 12) {
  
    if (structNow.hour == 17 && structNow.min > 30) return NONE;
  
    double distance = MathAbs(candle1.getClose() - ma1);

    // AFASTAMENTO DA MÉDIA MÓVEL ABAIXO de minDistance && ACIMA de maxDistance
    if (
      distance > minDistance && distance < maxDistance
    ) {
      if (
      // abaixo da MA
        candle1.getClose() < ma1
        
        // candle anterior bearish
        && candle2.getTrend() == BEARISH
        
        // candle anterior < 250
        && candle2.getHeight() < 250
      ) {
      
        return SELL;
      }
      
      if (
        // acima da MA
        candle1.getClose() > ma1
        
        // candle anterior bullish
        && candle2.getTrend() == BULLISH
        
        // candle anterior < 250
        && candle2.getHeight() < 250
      ) {
      
        return BUY;
      }
      
    }
    
  } else {
  
    // CANDLE CRUZANDO MÉDIA MÓVEL
    // - - - - - - - - - - - - - -
    
    
    // distância de fechamento e abertura considerável acima da MA
    // bool distanceNeeded = MathAbs(candle1.getClose() - ma1) > 50 && MathAbs(candle1.getClose() - ma1) > 50;
    
    // BULLISH
    if (
      // cruzamento de alta
      candle1.getClose() > ma1 && candle2.getClose() < ma2
      
      // candle anterior de tamanho considerável
      // && (candle1.getHeight() > 50 && candle1.getHeight() < 150)
      
      // && distanceNeeded
    ) {
      return SELL_SCALP;
    }
    
    // BEARISH
    if (
      
      // cruzamento de baixa
      candle1.getClose() < ma1 && candle2.getClose() > ma2
      
      // candle anterior de tamanho considerável
      // && (candle1.getHeight() > 50 && candle1.getHeight() < 150)
      
      // && distanceNeeded
    ) {
      return BUY_SCALP;
    }
  }

  
  
  
  return NONE;
}




bool SendRequest() {

  string baseUrl = "http://127.0.0.1:7000/";

  string cookie = NULL, headers;
  
  char   post[], result[];
  
  //--- para trabalhar com o servidor é necessário adicionar a URL "https://finance.yahoo.com"
  //--- na lista de URLs permitidas (menu Principal->Ferramentas->Opções, guia "Experts"):
  //--- redefinimos o código do último erro
  ResetLastError();
  
  //--- download da página html do Yahoo Finance
  int res = WebRequest(
    "GET", // método HTTP
    baseUrl+"trades", // URL
    headers, // cabeçalho 
    60000, // tempo esgotado
    post, // A matriz do corpo da mensagem HTTP
    result, // Uma matriz contendo dados de resposta do servidor
    headers // cabeçalhos de resposta do servidor
  );
  
  
  
  if (res == -1) {
  
    Print("Erro: ", GetLastError());
    
    //--- é possível que a URL não esteja na lista, exibimos uma mensagem sobre a necessidade de adicioná-la
    MessageBox("É necessário adicionar um endereço '"+baseUrl+"' à lista de URL permitidas na guia 'Experts'","Erro",MB_ICONINFORMATION);
  } else {
  
    if (res == 200) {
    
      //--- download bem-sucedido
      PrintFormat("O arquivo foi baixado com sucesso, tamanho %d bytes.", ArraySize(result));
      
      //PrintFormat("Cabeçalhos do servidor: %s",headers);
      //--- salvamos os dados em um arquivo
      int filehandle = FileOpen("url.htm", FILE_WRITE|FILE_BIN);
      
      if(filehandle != INVALID_HANDLE) {
      
        //--- armazenamos o conteúdo do array result[] no arquivo
        FileWriteArray(filehandle, result, 0, ArraySize(result));
        
        //--- fechamos o arquivo
        FileClose(filehandle);
      } else {
      
        Print("Erro em FileOpen. Código de erro =",GetLastError());
      }
    } else {
    
      PrintFormat("Erro de download '%s', código %d", baseUrl, res);
    }
  }
  
  return true;
}
