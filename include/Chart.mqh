void drawVerticalLine(string label, double firstValue, double secondValue, color lineColor) {

  Candle *candle1 = new Candle(1, 0);

  string lineName = 
    label + 
    " (" 
    + NormalizeDouble(firstValue, 1) 
    + ", " 
    + NormalizeDouble(secondValue, 1) 
    + ")";

  ObjectCreate(0, lineName, OBJ_VLINE, 0, candle1.getTime(), 0);
  ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
  ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);
}
