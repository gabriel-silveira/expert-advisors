#include "./Candle.mqh"


class CandlePattern : public Candle {

  private:
  
    double mrbz;
  
    Candle c0;
    Candle c1;
    Candle c2;
    Candle c3;
    Candle c4;
    
  public:
  
    CandlePattern(double mrbzHeight);
    
    void PrintPatternName(string name);
    
    
    bool isUpperDragonfly(
      double iEMA1
    );
    
    bool isShuttingStar(
      double iEMA1
    );
    
    bool isBearishGravestone(
      double iEMA1
    );
    
    bool isMorningStar(
      double iEMA1
    );
    
    bool isEveningStar(
      double iEMA1
    );
    
    bool isBearishEngulfing(
      double iEMA1
    );
    
    bool isUpSoldiers(void);
    
    bool isBullishAbandonedBaby(void);
};



CandlePattern::CandlePattern(double mrbzHeight) {
  
  mrbz = mrbzHeight;
  
  c0 = new Candle(0, mrbz);
  c1 = new Candle(1, mrbz);
  c2 = new Candle(2, mrbz);
  c3 = new Candle(3, mrbz);
  c4 = new Candle(4, mrbz);
}




static CandlePattern::PrintPatternName(string name) {
  Print("");
  Print(name);
  Print("");
}


bool CandlePattern::isUpperDragonfly(
  double iEMA1
) {
  if (
    c1.getHeight() < (mrbz / 6)
    &&
    c1.getUpperShadow() == 0
    &&
    c1.getLowerShadow() >= (mrbz / 2)
    &&
    c1.getClose() > iEMA1
  ) {
    PrintPatternName("UPPER DRANGONFLY");
    return true;
  }
  
  return false;
}


bool CandlePattern::isBearishEngulfing(
  double iEMA1
) {
  if (
    c2.isBullish()
    &&
    c2.getHeight() >= (mrbz / 3)
    &&
    c2.getClose() > iEMA1
    
    &&
    c1.isBearish()
    &&
    c1.getOpen() > c2.getClose()
    &&
    c1.getClose() < c2.getOpen()
    
    &&
    c1.getOpen() > iEMA1
    &&
    c1.getClose() > iEMA1
  ) {
    PrintPatternName("BEARISH ENGULFING");
    return true;
  }
  
  return false;
}


bool CandlePattern::isMorningStar(
  double iEMA1
) {
  if (
    c3.isBearish()
    &&
    c3.getHeight() > (mrbz / 3)
    && 
    c3.getClose() < iEMA1
    
    &&
    c2.getHeight() == 0
    && 
    c2.getClose() < iEMA1
    
    && 
    c1.isBullish()
    &&
    c1.getHeight() > (mrbz / 3)
    &&
    c1.getHeight() < c3.getHeight()
  ) {
    PrintPatternName("MORNING STAR");
    return true;
  }
  
  return false;
}


bool CandlePattern::isEveningStar(
  double iEMA1
) {
  if (
    c3.isBullish()
    &&
    c3.getHeight() > (mrbz / 3)
    && 
    c3.getClose() > iEMA1
    
    &&
    c2.getHeight() == 0
    && 
    c2.getClose() > iEMA1
    
    && 
    c1.isBearish()
    &&
    c1.getHeight() > (mrbz / 3)
    &&
    c1.getHeight() < c3.getHeight()
    && 
    c1.getClose() > iEMA1
  ) {
    PrintPatternName("EVENING STAR");
    return true;
  }
  
  return false;
}



bool CandlePattern::isShuttingStar(
  double iEMA1
) {
  if (
    c1.getHeight() < (mrbz / 6)
    &&
    c1.getUpperShadow() > (mrbz / 2)
    &&
    c1.getLowerShadow() < (mrbz / 6)
    && 
    c1.getClose() > iEMA1
  ) {
    PrintPatternName("SHUTTING STAR");
    return true;
  }
  
  return false;
}



bool CandlePattern::isBearishGravestone(
  double iEMA1
) {
  
  if (
    c1.isBearish()
    &&
    c1.getHeight() == 0
    &&
    c1.getUpperShadow() >= (mrbz / 2)
    &&
    c1.getLowerShadow() == 0
    && 
    c1.getClose() > iEMA1
  ) {
    PrintPatternName("SHUTTING STAR");
    return true;
  }
  
  return false;
}



bool CandlePattern::isUpSoldiers() {
  
  if (
    c1.isBullish() && c1.getHeight() >= (mrbz / 2)
    &&
    c2.isBullish() && c2.getHeight() >= (mrbz / 2)
    &&
    c3.isBullish() && c3.getHeight() >= (mrbz / 2)
  ) {
  
    return true;
  }
  
  return false;
}



bool CandlePattern::isBullishAbandonedBaby() {
  
  if (
    c1.isBullish() && c1.getHeight() > (mrbz / 2)
    &&
    c2.getHeight() == 0
    &&
    c3.isBearish() && c3.getHeight() > (mrbz / 2)
  ) {
  
    return true;
  }
  
  return false;
}

