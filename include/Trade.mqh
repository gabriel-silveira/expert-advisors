int magic_number = 123456; // número mágico

MqlTick tick; // últimos preços do ativo


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


double BuyAtMarket(double sl, double tp) {

  SymbolInfoTick(_Symbol, tick);

  MqlTradeRequest request;
  MqlTradeResult response;

  ZeroMemory(request);
  ZeroMemory(response);

  //--- For Buy Order
  request.action = TRADE_ACTION_DEAL; // Trade operation type
  request.magic = magic_number; // Magic number
  request.symbol = _Symbol; // Trade symbol
  request.volume = num_lots; // Lots number
  // request.price = NormalizeDouble(tick.ask, _Digits); // Price to buy
  request.sl = NormalizeDouble(tick.ask - sl * _Point, _Digits); // Stop Loss Price
  request.tp = NormalizeDouble(tick.ask + tp * _Point, _Digits); // Take Profit
  request.deviation = deviation; // Maximal possible deviation from the requested price
  request.type = ORDER_TYPE_BUY; // Order type
  request.type_filling = ORDER_FILLING_FOK; // Order execution type
  request.comment = "";
  
  
  return SendOrder(request, response);
}


double SellAtMarket(double sl, double tp) {

  SymbolInfoTick(_Symbol, tick);

  MqlTradeRequest request;
  MqlTradeResult response;
  
  ZeroMemory(request);
  ZeroMemory(response);
  
  //--- For Sell Order
  request.action = TRADE_ACTION_DEAL; // Trade operation type
  request.magic = magic_number; // Magic number
  request.symbol = _Symbol; // Trade symbol
  request.volume = num_lots; // Lots number
  // request.price = NormalizeDouble(tick.bid, _Digits); // Price to sell
  request.sl = NormalizeDouble(tick.bid + sl * _Point, _Digits); // Stop Loss Price
  request.tp = NormalizeDouble(tick.bid - tp * _Point, _Digits); // Take Profit
  request.deviation = deviation; // Maximal possible deviation from the requested price
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
  request.volume = num_lots; 
  request.price = 0; 
  request.type = buyed ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
  request.type_filling = ORDER_FILLING_RETURN;

  return SendOrder(request, response);
}