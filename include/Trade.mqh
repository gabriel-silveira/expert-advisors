// requisições HTTP
#include "./HTTP-Request.mqh"

// Expert ID
int magic_number;

MqlTick tick; // últimos preços do ativo

ENUM_ORDER_TYPE_FILLING typeFilling = ORDER_FILLING_FOK;

// int strategy[];

int       candleCount = 0;
int       candlesToClose;


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
//| Classe TradeOrder                                                |
//+------------------------------------------------------------------+

class TradeOrder {
  
  private:
  
    int magicNumber;
    
    double tp;
    double sl;
    double lots;
    string comment;
    
    int candleCount;
    
    int startTime;
    int finishTime;
    
    double Send(
      MqlTradeRequest& request,
      MqlTradeResult& result
    );
  
  public:
  
    bool ReadyToGo(void);
  
    TradeOrder(
      int pMagic,
      double pTp,
      double pSl,
      double pLots,
      string pComment,
      int pStartTime,
      int pFinishTime
    );
    
    bool WorkTime(void);
    
    double Buy();
    
    double Sell();
    
    double Close(void);
    
    void CheckForClosure();
    
    void drawVerticalLine(
      string label,
      double firstValue,
      double secondValue,
      color lineColor
    );
};


//+------------------------------------------------------------------+
//| Métodos da classe TradeOrder                                     |
//+------------------------------------------------------------------+

bool TradeOrder::ReadyToGo(void) {

  return (
    Candle::newBar()
    &&
    WorkTime()
    &&
    !isEnoughForToday()
    &&
    !PositionSelect(_Symbol)
  );
}


void TradeOrder::TradeOrder(
  int pMagic,
  double pTp,
  double pSl,
  double pLots,
  string pComment,
  int pStartTime,
  int pFinishTime
) {

  magicNumber = pMagic;
  tp = pTp;
  sl = pSl;
  lots = pLots;
  comment = pComment;
  
  startTime = pStartTime;
  finishTime = pFinishTime;
}


bool TradeOrder::WorkTime() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  return structNow.hour >= startTime && structNow.hour < finishTime;
}


double TradeOrder::Buy() {

  SymbolInfoTick(_Symbol, tick);

  MqlTradeRequest request;
  MqlTradeResult response;

  ZeroMemory(request);
  ZeroMemory(response);

  //--- For Buy Order
  request.action        = TRADE_ACTION_DEAL; // Trade operation type
  request.magic         = magicNumber; // Magic number
  request.symbol        = _Symbol; // Trade symbol
  request.volume        = lots; // Lots number

  request.sl            = NormalizeDouble(tick.ask - sl * _Point, _Digits); // Stop Loss Price
  request.tp            = NormalizeDouble(tick.ask + tp * _Point, _Digits); // Take Profit
  
  request.deviation     = 0; // Maximal possible deviation from the requested price
  request.type          = ORDER_TYPE_BUY; // Order type
  request.type_filling  = typeFilling; // Order execution type
  request.comment       = comment;
  
  drawVerticalLine(comment, tick.ask, tick.last, clrBlue);
  
  return Send(request, response);
}


double TradeOrder::Sell() {

  SymbolInfoTick(_Symbol, tick);

  MqlTradeRequest request;
  MqlTradeResult response;
  
  ZeroMemory(request);
  ZeroMemory(response);
  
  //--- For Sell Order
  request.action        = TRADE_ACTION_DEAL; // Trade operation type
  request.magic         = magicNumber; // Magic number
  request.symbol        = _Symbol; // Trade symbol
  request.volume        = lots; // Lots number
  
  request.sl            = NormalizeDouble(tick.bid + sl * _Point, _Digits); // Stop Loss Price
  request.tp            = NormalizeDouble(tick.bid - tp * _Point, _Digits); // Take Profit
  
  request.deviation     = 0; // Maximal possible deviation from the requested price
  request.type          = ORDER_TYPE_SELL; // Order type
  request.type_filling  = typeFilling; // Order execution type
  request.comment       = comment;
  
  drawVerticalLine(comment, tick.bid, tick.last, clrRed);
  
  return Send(request, response);
}


double TradeOrder::Send(
  MqlTradeRequest& request,
  MqlTradeResult& result
) {

  bool res = OrderSend(request, result);
  
  if (res && (result.retcode == 10008 || result.retcode == 10009)) {
  
    candleCount = 0;
  
    //--- ENVIA DADOS DA ORDEM PARA A API externa
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


void TradeOrder::CheckForClosure() {

  candleCount++;
  
  if (candleCount > candlesToClose) {
    
    Close();
  }
}


double TradeOrder::Close() {

  MqlTradeRequest   request;
  MqlTradeResult    response;

  ZeroMemory(request);
  ZeroMemory(response);

  //--- For Buy Order
  request.action = TRADE_ACTION_DEAL;
  request.magic = magicNumber;
  request.symbol = _Symbol;
  request.volume = lots;
  request.price = 0;
  
  bool buyed = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? true : false;
  request.type = buyed ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
  
  request.type_filling = ORDER_FILLING_RETURN;

  drawVerticalLine("Closed", 0, 0, clrYellow);
  
  return Send(request, response);
}



void TradeOrder::drawVerticalLine(
  string label,
  double firstValue,
  double secondValue,
  color lineColor
) {

  Candle *candle1 = new Candle(1, 0);

  string lineName = 
    label + 
    " (" 
    + DoubleToString(NormalizeDouble(firstValue, 1))
    + ", " 
    + DoubleToString(NormalizeDouble(secondValue, 1))
    + ")";

  ObjectCreate(0, lineName, OBJ_VLINE, 0, candle1.getTime(), 0);
  ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
  ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);
}


/*
bool setStrategy(int pExpertId, string pSymbol) {

  HttpRequest *http = new HttpRequest("http://127.0.0.1:7000");
  
  string response = http.get(
    "strategies/search",
    "ts_id="+IntegerToString(pExpertId)+"&symbol="+pSymbol
  );
  
  if (response != "") {
    
    string semicolon    = ";";
    
    ushort u_sep = StringGetCharacter(semicolon, 0);
  
    string fields[];
    
    int fieldsSize      = StringSplit(response, u_sep, fields);
    
    strategy.id         = (int)    fields[0];
    strategy.name       =          fields[1];
    strategy.symbol     =          fields[2];
    strategy.lots       = (int)    fields[3];
    strategy.target     = (double) fields[4];
    strategy.stopLoss   = (double) fields[5];
    strategy.goal       = (double) fields[6];
    strategy.riskLimit  = (double) fields[7];
    strategy.startTime  = (int) fields[8];
    strategy.endTime    = (int) fields[9];
    strategy.broker     = fields[10];
  }
  
  return true;
    
  return false;
}
*/

/*
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
*/



/*
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
    
    PlaySound("ok.wav");
    
    return(result.price);
  } else {
  
    Print("Erro ao enviar ordem. Erro =", GetLastError());
    
    ResetLastError();
  
    return(0.0);
  }
}
*/


/*

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

  drawVerticalLine("Closed", 0, 0, clrYellow);
  
  return SendOrder(request, response);
}
*/



/*
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


void registerLastDeal(
  int ts_id,
  int strategy_id
) {

  if (!backtest) {
  
    getLastDeal();
    
    HttpRequest *axios = new HttpRequest("http://127.0.0.1:7000");
    
    string msgBody = "ts_id="+ITS(ts_id)+"&strategy_id="+ITS(strategy_id)+"&ticket="+(string)lastDeal.ticket+"&result="+(string)lastDeal.profit+"&createdAt="+(string)(int)lastDeal.time;
    
    string response = axios.post("history", msgBody);
  }
}




string ITS(int number) {

  return IntegerToString(number);
}


string DTS(int number) {

  return DoubleToString(number);
}
*/
