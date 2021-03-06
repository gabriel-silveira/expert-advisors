enum TREND {
  BULLISH,
  BEARISH
};

enum CANDLE_FIGURE {
  DEFAULT_UP,
  DEFAULT_DOWN,
  MAROBOZU_UP,
  MAROBOZU_DOWN,
  SUPER_MAROBOZU_UP,
  SUPER_MAROBOZU_DOWN,
  HYPER_MAROBOZU_UP,
  HYPER_MAROBOZU_DOWN,
  SHUTTING_STAR,
  HAMMER,
  DOJI,
};

enum CANDLE_PATTERN {
  NON_PATTERN,
  BULLISH_ENGULFING,
  BEARISH_ENGULFING,
};


int candlesCounter = 0;

CANDLE_FIGURE testingCandleStrategy = false;

MqlDateTime auxToday;
MqlDateTime today;

int firstCandleTrend;


//+------------------------------------------------------------------+
//| CLASSE CANDLE                                                    |
//+------------------------------------------------------------------+

class Candle {

  private:
  
    datetime time;
    
    double open;
    double close;
    double low;
    double high;
    
    double upperShadow;
    double lowerShadow;
    
    double bodyHeight;
    
    CANDLE_FIGURE figure;

    long tick_volume;
    long real_volume;
    
    TREND trend;
    
    double marobozuHeight;
    
    void setCandleProperties(
      double pOpen,
      double pHigh,
      double pLow,
      double pClose,
      datetime pTime
    );
  
  
  public:
    Candle() {};
    
    Candle(
      int day,
      double baseHeight
    );
    
    Candle(
      double pOpen,
      double pHigh,
      double pLow,
      double pClose,
      double baseHeight,
      datetime pTime
    );
    
    
    static bool newBar(void);
    
    static bool newDay(void);
    
    static CANDLE_PATTERN getPattern(Candle &candle1, Candle &candle2);

    double getHeight(void);

    double getOpen(void);

    double getClose(void);

    double getHigh(void);

    double getLow(void);
    
    datetime getTime(void);
    
    double getUpperShadow(void);
    
    double getLowerShadow(void);
    
    TREND getTrend(void);
    
    CANDLE_FIGURE getFigure(void);
    
    
    bool isFigure(CANDLE_FIGURE figure);
    
    bool isBullish(void);
    
    bool isBearish(void);
    
    bool crossedDown(double currMa, double lastMa);
};



//+------------------------------------------------------------------+
//| CONSTRUTOR                                                       |
//+------------------------------------------------------------------+

Candle::Candle (
  int day,
  double baseHeight
) {

  MqlRates candle[];

  int copied = CopyRates(_Symbol, _Period, 0, day + 1, candle);

  if(copied <= 0) {

    Print("Erro ao copiar dados de preços", GetLastError());
  } else {

    ArraySetAsSeries(candle, true);
    
    setCandleProperties(
      candle[day].open,
      candle[day].high,
      candle[day].low,
      candle[day].close,
      candle[day].time
    );
    
    marobozuHeight = baseHeight;
  }
}


void Candle::Candle(
  double pOpen,
  double pHigh,
  double pLow,
  double pClose,
  double baseHeight,
  datetime pTime
) {

  setCandleProperties(
    pOpen,
    pHigh,
    pLow,
    pClose,
    pTime
  );
  
  marobozuHeight = baseHeight;
}


void Candle::setCandleProperties(
  double pOpen,
  double pHigh,
  double pLow,
  double pClose,
  datetime pTime
) {
    
    open = pOpen;
    
    high = pHigh;
    
    low = pLow;
    
    close = pClose;
    
    time = pTime;
    
    bodyHeight = MathAbs(open - close);
    
    trend = close > open ? BULLISH : BEARISH;
    
    figure = getFigure();
    
    upperShadow = high - (trend == BULLISH ? close : open);
    
    lowerShadow = MathAbs(low - (trend == BEARISH ? close : open));
}


//+------------------------------------------------------------------+
//| getters para acessar atributos privados da classe Candle         |
//+------------------------------------------------------------------+

double Candle::getOpen() {

  return open;
}

double Candle::getClose() {

  return close;
}

double Candle::getHigh() {

  return high;
}

double Candle::getLow() {

  return low;
}

double Candle::getUpperShadow() {

  return upperShadow;
}

double Candle::getLowerShadow() {

  return lowerShadow;
}


double Candle::getHeight() {

  return bodyHeight;
}

datetime Candle::getTime() {

  return time;
}

TREND Candle::getTrend() {

  return trend;
}



//+------------------------------------------------------------------+
//| MÉTODOS ESTÁTICOS                                                |
//+------------------------------------------------------------------+

CANDLE_PATTERN Candle::getPattern(Candle &candle1, Candle &candle2) {

  if (
    candle1.getOpen() > candle2.getClose()
    && candle1.getClose() < candle2.getOpen()
  ) {
    return BEARISH_ENGULFING;
  }
  
  if (
    candle1.getOpen() < candle2.getClose()
    && candle1.getClose() > candle2.getOpen()
  ) {
    return BULLISH_ENGULFING;
  }
  
  return NON_PATTERN;
}


bool Candle::newBar() {

  //--- memorize the time of opening of the last bar in the static variable
  static datetime last_time = 0;
  
  //--- current time
  datetime lastbar_time = (datetime) SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE); 
  
  //--- if it is the first call of the function
  if(last_time == 0) {
  
    //--- set the time and exit
    last_time = lastbar_time;
    
    return(false);
  }
  
  //--- if the time differs
  if(last_time != lastbar_time) {
  
    //--- memorize the time and return true
    last_time = lastbar_time;
    
    return(true);
  }
  
  //--- if we passed to this line, then the bar is not new; return false
  return(false);
}


bool Candle::newDay(void) {

  TimeToStruct(TimeCurrent(), auxToday);
  
  // um novo dia...
  if (auxToday.day > today.day) {
  
    Print("Operação iniciada! - Dia ", auxToday.day);
    
    TimeToStruct(TimeCurrent(), today);
    
    return true;
  } else {
  
    return false;
  }
}



//+------------------------------------------------------------------+
//| IDENTIFICANDO FIGURAS                                            |
//+------------------------------------------------------------------+

CANDLE_FIGURE Candle::getFigure(void) {
  

  if (upperShadow > 0 && bodyHeight > 0) {
  
    if (
      (upperShadow / bodyHeight) > 2
      &&
      lowerShadow < bodyHeight
    ) {
        return SHUTTING_STAR;
    }
  }
  
  
  if (lowerShadow > 0 && bodyHeight > 0) {
  
    if (
      (lowerShadow / bodyHeight) > 2
      &&
      upperShadow < (bodyHeight / 2)
    ) {
        return HAMMER;
    }
  }
  
  
  if (bodyHeight > (marobozuHeight * 3)) {
    
    return trend == BULLISH ? HYPER_MAROBOZU_UP : HYPER_MAROBOZU_DOWN;
  }
  
  
  if (bodyHeight > (marobozuHeight * 2)) {
    
    return trend == BULLISH ? SUPER_MAROBOZU_UP : SUPER_MAROBOZU_DOWN;
  }
  
  
  if (bodyHeight > marobozuHeight) {
    
    return trend == BULLISH ? MAROBOZU_UP : MAROBOZU_DOWN;
  }
  
  // 1. tem alguma sombra superior e inferior
  // 2. as sombras são maiores que 2 vezes o corpo
  // 3. o corpo é menor que um quarto de marobozu
  if (upperShadow > 0 && lowerShadow > 0) {
  
    if (
      (upperShadow > (bodyHeight * 2) && lowerShadow > (bodyHeight * 2))
      || bodyHeight < (marobozuHeight / 4)
    ) {
    
      return DOJI;
    }
  }
  
  
  return trend == BULLISH ? DEFAULT_UP : DEFAULT_DOWN;
}


bool Candle::isFigure(CANDLE_FIGURE figureCompare) {

  return figure == figureCompare;
}


bool Candle::isBullish(void) {

  return getTrend() == BULLISH;
}


bool Candle::isBearish(void) {

  return getTrend() == BEARISH;
}

