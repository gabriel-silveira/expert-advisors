void OnStart() {

  color BuyColor  = clrBlue;
  color SellColor = clrRed;
  
  datetime start = D'2020.05.26';
  
  datetime end = D'2020.05.27';
  
  //--- request trade history
  HistorySelect(start, end);
  
  //--- create objects
  string   name;
  uint     total = HistoryDealsTotal();
  ulong    ticket=0;
  double   price;
  double   profit;
  datetime time;
  string   symbol;
  long     type;
  long     entry;
  
  double totalResult = 0;
  
  string query = "";
  
  //--- for all deals
  for (uint i = 0; i < total; i++) {
  
    //--- try to get deals ticket
    if ((ticket = HistoryDealGetTicket(i)) > 0) {
    
      //--- get deals properties
      price  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      time   = (datetime) HistoryDealGetInteger(ticket, DEAL_TIME);
      symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      type   = HistoryDealGetInteger(ticket, DEAL_TYPE);
      entry  = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      
      Print(".");
      query = "INSERT INTO `history` (`ts_id`, `strategy_id`, `result`, `createdAt`) VALUES ('1', '2', '"+profit+"', '"+(int)time+"');";
      Print(query);
      
      totalResult += profit;
      
      //--- only for current symbol
      if (price && time && symbol == Symbol()) {
      
        //--- create price object
        name = "TradeHistory_Deal_" + string(ticket);
        
        if (entry)
          ObjectCreate(0, name, OBJ_ARROW_RIGHT_PRICE, 0, time, price, 0, 0);
        else
          ObjectCreate(0, name, OBJ_ARROW_LEFT_PRICE, 0, time, price, 0, 0);
        
        //--- set object properties
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0);
        ObjectSetInteger(0, name, OBJPROP_BACK, 0);
        ObjectSetInteger(0, name, OBJPROP_COLOR, type ? SellColor : BuyColor);
        
        // ObjectSetString(0, name, OBJPROP_TEXT, profit);
        
        if (profit != 0) ObjectSetString(0, name, OBJPROP_TEXT, "Profit: "+string(profit));
      }
    }
    
    Print(symbol);
    Print("Result: ", totalResult);
  }
  
  //--- apply on chart
  ChartRedraw();
}

