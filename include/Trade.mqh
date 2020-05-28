// requisições HTTP
#include "./HTTP-Request.mqh"



//+------------------------------------------------------------------+
//| Dados da última negociação                                       |
//+------------------------------------------------------------------+
struct LastDeal {

  ulong     ticket;
  datetime  time;
  double    profit;
};

LastDeal lastDeal;



//+------------------------------------------------------------------+
//| Dados da estratégia ativa                                        |
//+------------------------------------------------------------------+
struct Strategy {
  int     id;
  string  name;
  int     lots;
  double  target;
  double  stopLoss;
};

Strategy strategy;



// Expert ID
int magic_number;

// int strategy[];

int candleCount = 0;


MqlTick tick; // últimos preços do ativo



bool getExpertStrategies(int pExpertId, string &items[]) {

  HttpRequest *http = new HttpRequest("http://127.0.0.1:7000");
  
  string response = http.get(
    "strategies/search",
    "ts_id="+IntegerToString(pExpertId)
  );
  
  if (http.responseToArray(items, response)) {
    return true;
  }
  
  return false;
}

bool setStrategy(string &strategies[]) {
  
  strategy.id       = (int)    strategies[0];
  strategy.name     =          strategies[1];
  strategy.lots     = (int)    strategies[4];
  strategy.target   = (double) strategies[5];
  strategy.stopLoss = (double) strategies[6];
  
  Print("Estratégia: ", strategy.name, " (", strategy.id,")");
  Print("Lots: ", strategy.lots);
  Print("Target: ", strategy.target);
  Print("Stop Loss: ", strategy.stopLoss);
  
  return true;
}


void setMagicNumber(int number) {

  magic_number = number;
}



double SendOrder(
  MqlTradeRequest& request,
  MqlTradeResult& result
) {

  bool res = OrderSend(request, result);
  
  if (res && (result.retcode == 10008 || result.retcode == 10009)) {
  
    //--- ENVIA DADOS DA ORDEM PARA A API
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    
    
    return(result.price);
  } else {
  
    Print("Erro ao enviar ordem. Erro =", GetLastError());
    
    ResetLastError();
  
    return(0.0);
  }
}


double BuyAtMarket() {

  SymbolInfoTick(_Symbol, tick);

  MqlTradeRequest request;
  MqlTradeResult response;

  ZeroMemory(request);
  ZeroMemory(response);

  //--- For Buy Order
  request.action = TRADE_ACTION_DEAL; // Trade operation type
  request.magic = magic_number; // Magic number
  request.symbol = _Symbol; // Trade symbol
  request.volume = strategy.lots; // Lots number

  request.sl = NormalizeDouble(tick.ask - strategy.stopLoss * _Point, _Digits); // Stop Loss Price
  request.tp = NormalizeDouble(tick.ask + strategy.target * _Point, _Digits); // Take Profit
  
  request.deviation = 0; // Maximal possible deviation from the requested price
  request.type = ORDER_TYPE_BUY; // Order type
  request.type_filling = ORDER_FILLING_FOK; // Order execution type
  request.comment = "";
  
  
  return SendOrder(request, response);
}


double SellAtMarket() {

  SymbolInfoTick(_Symbol, tick);

  MqlTradeRequest request;
  MqlTradeResult response;
  
  ZeroMemory(request);
  ZeroMemory(response);
  
  //--- For Sell Order
  request.action = TRADE_ACTION_DEAL; // Trade operation type
  request.magic = magic_number; // Magic number
  request.symbol = _Symbol; // Trade symbol
  request.volume = strategy.lots; // Lots number
  
  request.sl = NormalizeDouble(tick.bid + strategy.stopLoss * _Point, _Digits); // Stop Loss Price
  request.tp = NormalizeDouble(tick.bid - strategy.target * _Point, _Digits); // Take Profit
  
  request.deviation = 0; // Maximal possible deviation from the requested price
  request.type = ORDER_TYPE_SELL; // Order type
  request.type_filling = ORDER_FILLING_FOK; // Order execution type
  
  
  return SendOrder(request, response);
}


double ClosePosition() {
  
  bool buyed = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? true : false;

  MqlTradeRequest   request;
  MqlTradeResult    response;

  ZeroMemory(request);
  ZeroMemory(response);

  //--- For Buy Order
  request.action = TRADE_ACTION_DEAL;
  request.magic = magic_number;
  request.symbol = _Symbol;
  request.volume = strategy.lots; 
  request.price = 0; 
  request.type = buyed ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
  request.type_filling = ORDER_FILLING_RETURN;

  return SendOrder(request, response);
}



void checkPosition() {
  
  candleCount++;
  
  if (candleCount > 10) {
    
    ClosePosition();
  }
}



LastDeal getLastDeal() {
  
  // obtém última negociação
  if (HistorySelect(0, TimeCurrent())) {
  
    for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
    
      lastDeal.ticket = (ulong) HistoryDealGetTicket(i);
  
      if (HistoryDealGetInteger(lastDeal.ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
      
        lastDeal.time   = (datetime) HistoryDealGetInteger(lastDeal.ticket, DEAL_TIME);
        lastDeal.profit = HistoryDealGetDouble(lastDeal.ticket, DEAL_PROFIT);
        
        break;
      }
    }
  }
  
  return lastDeal;
}



bool registerLastDeal(
  int ts_id,
  int strategy_id
) {

  getLastDeal();
  
  HttpRequest *axios = new HttpRequest("http://127.0.0.1:7000");
  
  string msgBody = "ts_id="+ts_id+"&strategy_id="+strategy_id+"&ticket="+lastDeal.ticket+"&result="+lastDeal.profit+"&createdAt="+(int)lastDeal.time;
  
  string response = axios.post("history", msgBody);
  
  return true;
}


