#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Indicadores:"
#property description "RSI (8), ATR (14) 3.6"
#property description "\n"
#property description "Objetivo:"
#property description "Buscar 500 pontos no mini índice no timeframe de 1m. O stop loss é em função da volatilidade média de 14 períodos com desvio de 3.6."
#property description "\n"
#property description "Alvo:"
#property description "500 pontos com 1 mini contrato / stop ATR"

#include "./include/inc.mqh"

#include "./indicators/RSI.mqh"

#include "./indicators/ATR.mqh"


string        expertName              = "RSI-sATR";

ENUM_TIMEFRAMES input timeframe       = PERIOD_M1; // Timeframe


double        profitLimit;            // Limite diário de ganho
double        lossLimit;              // Limite diário de perda

double        input maxProfits        = 1; // Limite diário de ganho
double        input maxLosses         = 2; // Limite diário de perda

double        input tp                = 500; // TP
double        currSl                  = 200; // SL
double        input ATRStopLevel      = 3.6; // Nível de ATR Stop

int           input lots              = 1; // Lots

double        input highRSI           = 75;
double        input lowRSI            = 25;


TradeOrder *Order = new TradeOrder(
  351,
  tp,
  currSl,
  lots,
  expertName,
  10,
  17
);



int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, timeframe);

  profitLimit = ((tp * 0.2) * lots) * maxProfits;
  lossLimit   = profitLimit / 2;
  
  
  InitRSI(8);
  
  InitATR(14);
  
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (
    Order.ReadyToGo()
  ) {
    
    if (CopyATRBuffer()) {
    
      currSl = iATRBuffer[1] * ATRStopLevel;
    
      Order.SetStopLoss(currSl);
      
    
      CopyRSIBuffers();
      
      
      CheckSignals();
    }
  }
}



void CheckSignals() {

  if (
    iRSIBuffer[3] < (lowRSI - 5)
    &&
    iRSIBuffer[2] < lowRSI
    &&
    iRSIBuffer[1] > lowRSI
  ) {
  
    Order.Buy();
  }
  
  
  if (
    iRSIBuffer[3] > (highRSI + 5)
    &&
    iRSIBuffer[2] > highRSI
    &&
    iRSIBuffer[1] < highRSI
  ) {
  
    //Order.SetStopLoss(sl);
    
    Order.Sell();
  }
}



void OnDeinit(const int reason) {

  if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
  
  //--- limpar o gráfico após excluir o indicador
  Comment("");
}
