#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"

#include "./include/inc.mqh"

#include "./indicators/BollingerBands.mqh"


string        expertName              = "Beethoven";

ENUM_TIMEFRAMES input tf = PERIOD_M1; // Timeframe

double        profitLimit;            // Limite diário de ganho
double        lossLimit;              // Limite diário de perda

int           input tp                = 200;             // TP
int           input sl                = 100;            // SL

int           input lots              = 1;              // Lots

ulong         orderCode;



TradeOrder *Order = new TradeOrder(
  83310731,
  tp,
  sl,
  lots,
  expertName,
  9,
  17
);



int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, tf);

  profitLimit = (tp * 0.2) * 2;
  lossLimit   = (tp * 0.2) * 1;
  
  
  InitBollingerBands(20);
  
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (
    Order.ReadyToGo()
  ) {
  
    CopyBollingerBandsBuffer(5);
    
    CheckSignals();
  }
}



void CheckSignals() {
  
  orderCode = Order.BuyLimit(LowerBuffer[1] - 100);
}



void OnDeinit(const int reason) {

  if(handleBollinger != INVALID_HANDLE) IndicatorRelease(handleBollinger);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}
