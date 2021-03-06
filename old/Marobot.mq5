#include "../include/Candle.mqh"

input double marobozuHeight                     = 200;

double candlesSettings[1];

input double             StopLoss               = 100.0;
input double             TakeProfit             = 100.0;


int OnInit() {

  candlesSettings[0] = marobozuHeight;
  
  TimeToStruct(TimeCurrent(), today);

  return(INIT_SUCCEEDED);
}


void OnTick() {

  bool positioned = PositionSelect(_Symbol) == true;
  
  if (!positioned) {
  
    if (Candle::newBar()) {
      
      Candle *yesterdayCandle = new Candle(1, candlesSettings, true);
      
      if(yesterdayCandle.openPosition(StopLoss, TakeProfit)) {
        
        yesterdayCandle.resetCounters();
      
        Print("Posição aberta!");
      }
    }
  }
}

