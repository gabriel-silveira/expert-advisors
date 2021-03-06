#include  <Trade\Trade.mqh>

#include "./include/Candle.mqh"

#property copyright "Gabriel Silveira Tecnologia"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
 
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plotar iMA
#property indicator_label1  "Média Móvel 5"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1


//--- parâmetros de entrada
input int            ma_period=5;                  // período da média móvel
int                  ma_shift=0;                   // deslocamento
ENUM_MA_METHOD       ma_method=MODE_SMA;           // tipo de suavização
ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;    // tipo de preço
ENUM_TIMEFRAMES      period=PERIOD_CURRENT;        // timeframe


double               currentDeclive = 0.5;


//--- buffer do indicador
double          iMABuffer_1[];

//--- variável para armazenar o manipulador do indicator iMA
int             handle_1;



CTrade          m_trade;



int OnInit() {

  InitIndicator(iMABuffer_1, handle_1, ma_period);


  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
  
    CopyMABuffer(iMABuffer_1, handle_1);
  

    MqlRates candle[];
  
    int copied = CopyRates(_Symbol, _Period, 0, ma_period, candle);
    
    
    if(copied <= 0) {
  
      Print("Erro ao copiar dados de preços", GetLastError());
    } else {
    
      int lastItem = ma_period - 1;
  
      ArraySetAsSeries(candle, true);
      
      double declive = CalculateSteepness(
          iMABuffer_1[0],
          iMABuffer_1[lastItem],
          candle[0].time,
          candle[lastItem].time
        );
        
  
        
      double decliveNormalized = NormalizeDouble(declive, 2);
      
      
      Print("Declive: "+(string) decliveNormalized);
      Print("("+(string)iMABuffer_1[0]+" - "+(string)iMABuffer_1[lastItem]+") - ("+(string)candle[0].time+" - "+(string)candle[lastItem].time+")");
      Print("("+(string)(iMABuffer_1[0]-iMABuffer_1[lastItem])+") - ("+(string)(candle[0].time-candle[lastItem].time)+")");
      Print("");
      
      if (decliveNormalized > (currentDeclive * -1)) {
      
        Comment("COMPRA");
        
        /* if (
          !PositionSelect(_Symbol)
        ) {
          
          MqlTick tick; // últimos preços do ativo
          
          SymbolInfoTick(_Symbol, tick);
          
          m_trade.Buy(
            10,
            _Symbol,
            0,
            NormalizeDouble(tick.ask - 100 * _Point, _Digits),
            NormalizeDouble(tick.ask + 50 * _Point, _Digits)
          );
        } */
        
      } else if (decliveNormalized < currentDeclive) {
      
        Comment("VENDA");
        
        /* if (
          !PositionSelect(_Symbol)
        ) {
          MqlTick tick; // últimos preços do ativo
          
          SymbolInfoTick(_Symbol, tick);
          
          m_trade.Sell(
            10,
            _Symbol,
            0,
            NormalizeDouble(tick.bid + 100 * _Point, _Digits),
            NormalizeDouble(tick.bid - 50 * _Point, _Digits)
          );
        } */
            
      } else {
      
        Comment("Declive: "+(string) decliveNormalized);
      }
    }
  }
}



double CalculateSteepness(
  double y2,
  double y1,
  double x2,
  double x1
) {

  return (y2 - y1) / (x2 - x1);
}



void InitIndicator(
  double &currentBuffer[],
  int &currentHandler,
  int periods
) {
  
  SetIndexBuffer      (0, currentBuffer, INDICATOR_DATA);
  PlotIndexGetInteger (0, PLOT_LINE_COLOR, clrFuchsia);
  PlotIndexGetInteger (0, PLOT_LINE_WIDTH, 2);
  
  currentHandler = iMA(_Symbol, PERIOD_CURRENT, periods, 0, MODE_SMA, PRICE_CLOSE);
  
  IndicatorSetString(
    INDICATOR_SHORTNAME,
    StringFormat(
      "iMA(%s/%s, %d, %d, %s, %s)",
      _Symbol,
      EnumToString(_Period),
      ma_period,
      ma_shift,
      EnumToString(ma_method),
      EnumToString(applied_price)
    )
  );
}



bool CopyMABuffer(
  double &currentBuffer[],
  int &currentHandler
) {

  //+------------------------------------------------------------------+
  //| iEMA                                                             |
  //+------------------------------------------------------------------+
  CopyBuffer(currentHandler, 0, 0, ma_period, currentBuffer);
  
  ArraySetAsSeries(currentBuffer, true);
  
  return true;
}


