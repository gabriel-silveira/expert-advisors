
double  initialBalance    = 0;
double  previousBalance   = 0;

double  currentPrice;



double getCurrentBalance() {

  if (Candle::newDay()) {
  
    initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  }
  
  return AccountInfoDouble(ACCOUNT_BALANCE) - initialBalance;
}



bool isEnoughForToday() {

  double balance = getCurrentBalance();
  
  return balance >= profitLimit || balance < (lossLimit * -1);
}


