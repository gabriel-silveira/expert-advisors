// leitura de candles
#include "./include/Candle.mqh"

//+------------------------------------------------------------------+
#property copyright "GST"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"



int OnInit() {
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {

    MqlRates rates[];
  
    int copied = CopyRates(Symbol(), Period(), 0, 2, rates);
  
    if(copied <= 0) {
  
      Print("Erro ao copiar dados de preços", GetLastError());
    } else {
  
      ArraySetAsSeries(rates, true);
      
      string line = ""
        + (string) rates[1].open + ";"
        + (string) rates[1].high + ";"
        + (string) rates[1].low + ";"
        + (string) rates[1].close + ";"
        + (string) rates[1].time + ";"
        + (string) rates[1].real_volume + ";"
        + (string) rates[1].tick_volume + ";"
        + (string) rates[1].spread;
      
      // Print(line);
      
      string filename = TimeToString(TimeCurrent(), TIME_DATE);

      WriteStockData(filename+".txt", line);
    }
  }
}



void WriteStockData(
  string filename,
  string content
) {
  
  int h = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
  
   if(h == INVALID_HANDLE) {
      Alert("Error opening file");
      return;
   }
   
   FileSeek(h, 0, SEEK_END);
   
   FileWrite(h, content);
   
   FileClose(h);
}
