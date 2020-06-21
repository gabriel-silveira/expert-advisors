
double  initialBalance    = 0;
double  previousBalance   = 0;

double  currentPrice;


bool workTime() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);
  
  if (
    (structNow.hour >= hourToStart && structNow.hour < hourToFinish)
  ) return true;
  
  return false;
}


bool restrictHours() {
      
  MqlDateTime structNow;
  
  TimeToStruct(TimeCurrent(), structNow);

  if (restrictedHours) {
  
    if (structNow.hour < hourToStart) return true;
    
    if (structNow.hour > hourToFinish) return true;
  }
  
  return false;
}



double getCurrentBalance() {

  if (Candle::newDay()) {
  
    initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  }
  
  return AccountInfoDouble(ACCOUNT_BALANCE) - initialBalance;
}



bool isEnoughForToday(double balance) {

  if (balance >= profitLimit || balance < (lossLimit * -1)) {
      
    // PlaySound("alert.wav");
    
    return true;
  }

  return false;
}


