void OnStart() {

  color BuyColor  = clrBlue;
  color SellColor = clrRed;
  
  datetime start = D'2020.05.25';
  
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
      
      if (profit != 0) {
      
        int strategy = (symbol == "WINM20") ? 1 : 2;
      
        query = "INSERT INTO `history` (`ts_id`, `strategy_id`, `ticket`, `result`, `createdAt`) VALUES ('1', '"+strategy+"', '"+ticket+"', '"+profit+"', '"+(int)time+"');";
        
        writeSqlQuery("insertDeals.sql", "Data", query);
        
        totalResult += profit;
      }
    }
    
    Print(symbol);
    Print("Result: ", totalResult);
  }
  
  //--- apply on chart
  ChartRedraw();
}




void writeSqlQuery(
  string InpFileName,
  string InpDirectoryName,
  string query
) {

  ResetLastError();
  
  int file_handle = FileOpen(InpDirectoryName+"//"+InpFileName, FILE_READ|FILE_WRITE);
  
  if(file_handle != INVALID_HANDLE) {
  
    FileSeek(file_handle, 0, SEEK_END);
    
    PrintFormat("%s arquivo está disponível para ser escrito", InpFileName);
    PrintFormat("Caminho do arquivo: %s\\Files\\", TerminalInfoString(TERMINAL_DATA_PATH));
    
    
    FileWriteString(file_handle, query+"\r\n");
    
    FileClose(file_handle);
    
    PrintFormat("Os dados são escritos, %s arquivo esta fechado", InpFileName);
  } else {
  
    PrintFormat("Falha para abrir %s arquivo, Código de erro = %d", InpFileName, GetLastError());
  }
}