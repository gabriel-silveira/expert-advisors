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
  string  symbol;
  int     lots;
  double  target;
  double  stopLoss;
};

Strategy strategy;

Strategy strategies[];

// Expert ID
int magic_number;

// int strategy[];

int candleCount = 0;


MqlTick tick; // últimos preços do ativo



string getExpertStrategies(int pExpertId) {

  HttpRequest *http = new HttpRequest("http://127.0.0.1:7000");
  
  string response = http.get(
    "strategies/search",
    "ts_id="+IntegerToString(pExpertId)
  );
  
  return response;
}



bool handleStrategiesResponse(string response) {
  
  string lines[];     // linhas lidas no csv

  ushort u_sep;       // O código do caractere separador

  string breakLine = "\n";
  u_sep = StringGetCharacter(breakLine, 0);
  
  
  int size = StringSplit(response, u_sep, lines);
  
  ArrayResize(strategies, (size - 1));
  
  
  string semicolon = ";";
  u_sep = StringGetCharacter(semicolon, 0);
  
  
  // itera pelas linhas
  for (int i = 0; i < size; i++) {
  
    string fields[];
    
    int fieldsSize = StringSplit(lines[i], u_sep, fields);
    
    if (ArraySize(fields) > 0) {
    
      Strategy currStrategy;
      currStrategy.id       = (int)    fields[0];
      currStrategy.name     =          fields[1];
      currStrategy.symbol   =          fields[2];
      currStrategy.lots     = (int)    fields[3];
      currStrategy.target   = (double) fields[4];
      currStrategy.stopLoss = (double) fields[5];
      
      strategies[i] = currStrategy;
    }
  }
  
  return true;
}



bool setStrategy(Strategy &data) {
  
  strategy.id       = (int)    data.id;
  strategy.name     =          data.name;
  strategy.symbol   =          data.symbol;
  strategy.lots     = (int)    data.lots;
  strategy.target   = (double) data.target;
  strategy.stopLoss = (double) data.stopLoss;
  
  Print("");
  Print(". . . Estratégia . . .");
  Print("#", strategy.id,": ", strategy.name);
  Print("Symbol: ", strategy.symbol);
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
  
  string msgBody = "ts_id="+ITS(ts_id)+"&strategy_id="+ITS(strategy_id)+"&ticket="+(string)lastDeal.ticket+"&result="+(string)lastDeal.profit+"&createdAt="+(string)(int)lastDeal.time;
  
  string response = axios.post("history", msgBody);
  
  return true;
}




string ITS(int number) {

  return IntegerToString(number);
}


string DTS(int number) {

  return DoubleToString(number);
}