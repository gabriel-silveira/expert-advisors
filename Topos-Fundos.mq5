#include "./include/inc.mqh"

#include "./indicators/Volume.mqh"

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

int           periods                 = 40;


double        currentPeak;
double        currentBottom;


double        priceRange;


string        highLevelName           = "Topo";

string        lowLevelName            = "Fundo";


int           candleCountDown         = 0;


TradeOrder *Order = new TradeOrder(
  351,
  200,
  200,
  lots,
  expertName,
  10,
  16
);



int OnInit() {

  ChartSetSymbolPeriod(0, _Symbol, timeframe);

  profitLimit = inputProfitLimit;
  
  lossLimit   = profitLimit / 2;
  
  
  InitVolume();
  
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (
    Candle::newBar()
    &&
    Order.WorkTime()
  ) {
    
    if (
      !PositionSelect(_Symbol)
    ) {
    
      // saindo de uma posição
      if (
        candleCount > 0
      ) {
        
        candleCountDown = 10;
        
        candleCount = 0;
      } else if (
        candleCountDown == 0
      ) {
    
        CopyVolumeBuffer(10);
      
        CheckSignals();
      } else {
      
        candleCountDown--;
      }
    } else {
    
      candleCount++;
    }
  } else {
  
    ClearChart();
  }
}



void CheckSignals() {

  MqlRates ticks[];
  
  int copied = CopyRates(_Symbol, _Period, 0, periods, ticks);
  
  
  if(copied <= 0) {
  
    Print("Erro ao copiar dados de preços", GetLastError());
  } else {
  
    ArraySetAsSeries(ticks, true);
    
    Candle *c1 = new Candle(1, 100);
    
    if (
      c1.getClose() > currentPeak
      &&
      iVolumesBuffer[1] > 10000
    ) {
      Print("Rompimento de topo: ", iVolumesBuffer[1]);
      Print("");
      
      // Order.Buy();
    }
    
    if (
      c1.getClose() < currentBottom
      &&
      iVolumesBuffer[1] > 10000
    ) {
      Print("Rompimento de fundo: ", iVolumesBuffer[1]);
      Print("");
      
      // Order.Sell();
    }
    
    
    FindPeak(ticks);
    
    FindBottom(ticks);
  }
}



void FindPeak(
  MqlRates &ticks[]
) {
  
  double lastHigh = ticks[periods - 1].high;
  

  for (int i = (periods / 2); i < periods; i++) {
    
    // topo
    if (ticks[i].high > lastHigh) {
    
      lastHigh = ticks[i].high;
    }
  }
  
  currentPeak = lastHigh;
  
  drawLevelLine(highLevelName, currentPeak, clrRed);
}



void FindBottom(
  MqlRates &ticks[]
) {

  double lastLow = ticks[periods - 1].low;
  

  for (int i = (periods / 2); i < periods; i++) {
    
    // fundo
    if (ticks[i].low < lastLow) {
    
      lastLow = ticks[i].low;
    }
  }
  
  currentBottom = lastLow;
  
  drawLevelLine(lowLevelName, currentBottom, clrGreen);
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
