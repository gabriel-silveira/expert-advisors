#include "./include/inc.mqh"

#include "./indicators/ADX.mqh"

string        expertName              = "ToposFundos";

ENUM_TIMEFRAMES input timeframe       = PERIOD_M1; // Timeframe

double        profitLimit;            // Limite diário de ganho
double        lossLimit;              // Limite diário de perda

double        input inputProfitLimit  = 200; // Limite diário de ganho

int           input lots              = 1; // Lots

double        input minRange          = 300; // Minimum range
double        input maxRange          = 600; // Minimum range



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int           periods                 = 25;

double        lastHigh                = 0;
datetime      lastHighTime;

double        lastLow                 = 0;
datetime      lastLowTime;

double        priceRange;


string        highLevelName           = "Topo";

string        lowLevelName            = "Fundo";



TradeOrder *Order = new TradeOrder(
  351,
  200,
  200,
  lots,
  expertName,
  9,
  16
);



int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, timeframe);

  profitLimit = inputProfitLimit;
  
  lossLimit   = profitLimit / 2;
  
  InitADX(14);
  
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (
    Candle::newBar()
  ) {
    
    CopyADXBuffers(periods);
    
    
    if (
      Order.WorkTime()
    ) {
    
      CheckSignals();
      
    } else {
      
      ClearChart();
    }
  }
}



void CheckSignals() {

  MqlRates ticks[];
  
  int copied = CopyRates(_Symbol, _Period, 0, periods, ticks);
  
  
  if(copied <= 0) {
  
    Print("Erro ao copiar dados de preços", GetLastError());
  } else {
  
    ArraySetAsSeries(ticks, true);
    
    double lastHighBefore = lastHigh;
    
    
    FindPeak(ticks);
    
    FindBottom(ticks);
    
    
    priceRange = lastHigh - lastLow;
    
    
    Candle *c1 = new Candle(1, 150);
    
    // rompimento da resistência
    if (
      priceRange > minRange
      &&
      priceRange < maxRange
      &&
      // nova máxima
      lastHigh > lastHighBefore
      &&
      // momento de baixa
      DI_plusBuffer[10] < DI_minusBuffer[10]
      &&
      !PositionSelect(_Symbol)
      &&
      !isEnoughForToday()
    ) {
      
      double target = c1.getClose() - lastLow;
      
      Print("Target: ", target);
      
      Order.SetStopLoss(target);
      
      Order.SetTakeProfit(target);
      
      Order.Buy();
    }
  }
}



void FindPeak(
  MqlRates &ticks[]
) {
  
  lastHigh = ticks[periods - 1].high;
  

  for (int i = 0; i < periods; i++) {
    
    // topo
    if (ticks[i].high > lastHigh) {
    
      lastHigh = ticks[i].high;
      
      lastHighTime = ticks[i].time;
    }
  }
  
  drawLevelLine(highLevelName, lastHigh, clrRed);
}



void FindBottom(
  MqlRates &ticks[]
) {
  
  lastLow  = ticks[periods - 1].low;
  

  for (int i = 0; i < periods; i++) {
    
    // fundo
    if (ticks[i].low < lastLow) {
    
      lastLow = ticks[i].low;
      
      lastLowTime = ticks[i].time;
    }
  }
  
  drawLevelLine(lowLevelName, lastLow, clrGreen);
}



void drawLevelLine(
  string name,
  double price,
  color lineColor
) {

  if (ObjectFind(0, name) > -1) {
  
     MoveObject(name, price);
    
  } else {
    
    ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
    
    ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
    
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
  }
  
  ChartRedraw(0);
}



bool MoveObject(
  string name,
  double price
) {
  
  //--- redefine o valor de erro
  ResetLastError();
  
  
  if (!ObjectMove(0, name, 0, 0, price)) {
  
    Print(__FUNCTION__, ": falha ao mover um linha horizontal! Código de erro = ", GetLastError());
    
    return(false);
  }
  
  
  
  return(true);
}


void ClearChart() {

  ObjectDelete(0, lowLevelName);
  
  ObjectDelete(0, highLevelName);
}
