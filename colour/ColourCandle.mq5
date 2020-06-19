#include "../include/Candle.mqh"

#property indicator_chart_window                //Indicator in separate window

//Specify the number of buffers of the indicator
//4 buffer for candles + 1 color buffer + 1 buffer to serve the RSI data
#property indicator_buffers 6

//Specify the names in the Data Window
#property indicator_label1 "Open;High;Low;Close"

#property indicator_plots 1                     //Number of graphic plots
#property indicator_type1 DRAW_COLOR_CANDLES    //Drawing style - color candles
#property indicator_width1 3                    //Width of the graphic plot (optional)

//Declaration of buffers
double buffer_open[],buffer_high[],buffer_low[],buffer_close[]; //Buffers for data
double buffer_color_line[];    //Buffer for color indexes
double buffer_tmp[1];           //Temporary buffer for RSI data copying

int    input maroHeight = 150;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

  ChartSetInteger( 0, CHART_COLOR_BACKGROUND, C'11,17,14' );
  /**
    *       The order of the buffers assign is VERY IMPORTANT!
    *  The data buffers are first
    *       The color buffers are next
    *       And finally, the buffers for the internal calculations.
    */
  //Assign the arrays with the indicator's buffers
  SetIndexBuffer(0, buffer_open, INDICATOR_DATA);
  SetIndexBuffer(1, buffer_high, INDICATOR_DATA);
  SetIndexBuffer(2, buffer_low, INDICATOR_DATA);
  SetIndexBuffer(3, buffer_close, INDICATOR_DATA);
  
  //Assign the array with color indexes with the indicator's color indexes buffer
  SetIndexBuffer(4, buffer_color_line, INDICATOR_COLOR_INDEX);
  
  // Define the number of color indexes, used for a graphic plot
  PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 10);
  
  //Set color for each index
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, C'30,55,42');      // Default
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, C'94,147,120');    // Alta
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, C'55,96,75');      // Baixo
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, C'255,255,100');   // Shutting Star
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 4, C'0,255,0');       // Hammer
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 5, C'180,255,230');   // Maro Alta
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 6, C'30,55,42');      // Maro Baixo
  
  //Get handle of RSI indicator, it's necessary to get the RSI indicator values
  // handle_rsi=iCustom(_Symbol,_Period,  "Examples\\RSI");
  return(0);
}



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
                
  //In the loop we fill the data buffers and color indexes buffers for each bar
  for(int i=prev_calculated;i<=rates_total-1;i++) {
    
    //Set data for plotting
    buffer_open[i]  = open[i];   //Open price
    buffer_high[i]  = high[i];   //High price
    buffer_low[i]   = low[i];     //Low price
    buffer_close[i] = close[i]; //Close price
    
    Candle *c1 = new Candle(open[i], high[i], low[i], close[i], maroHeight, time[i]);
    
    if (
      c1.getFigure() == MAROBOZU_UP
    ) {
    
      buffer_color_line[i] = 5;
    
    } else if (
      c1.getFigure() == MAROBOZU_DOWN
    ) {
    
      buffer_color_line[i] = 6;
    
    } else if (
      c1.getFigure() == SHUTTING_STAR
      &&
      close[i-1] > open[i-1]
    ) {
    
      buffer_color_line[i] = 3;
      
    } else if (
      c1.getFigure() == HAMMER
      &&
      close[i-1] < open[i-1]
    ) {
    
      buffer_color_line[i] = 4;
      
    } else if (c1.getHeight() < ( maroHeight / 7)) {
    
      buffer_color_line[i] = 0;
    
    } else if(open[i] < close[i]) {
    
      buffer_color_line[i]  = 1;
      
    } else if (open[i] > close[i]) {
    
      buffer_color_line[i]   = 2;
      
    } else {
    
      buffer_color_line[i]   = 0;
    
    }
  }
  
  return(rates_total - 1); //Return the number of calculated bars,
  
  //Subtract 1 for the last bar recalculation
}
