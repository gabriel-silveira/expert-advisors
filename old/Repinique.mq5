#property copyright "Copyright 2020, GS Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Se às 11h o preço estiver acima / abaixo da abertura do dia, realiza compras / vendas sucessivas até atingir a meta."

#include "./include/inc.mqh"

// painel do expert
#include "./include/General-Panel.mqh"


int           expertId        = 5;

string        expertName      = "Repinique";


bool  input   backtest        = false; // Backtest


//+------------------------------------------------------------------+
//| CANDLE HEIGHT                                                    |
//+------------------------------------------------------------------+
bool          isMiniDolar     = StringFind(_Symbol, "WDO") != -1;

int           mrbzHeight      = isMiniDolar ?  4 :  40;

int           dojiHeight      = isMiniDolar ?  2 :  20;



string        symbolName      = _Symbol;   // variável para armazenamento

bool          restrictedHours = true;      // Restringir horários?
int           hourToStart     = 11;        // Início
int           hourToFinish    = 13;        // Término

double        profitLimit     = 200;       // Limite diário de ganho
double        lossLimit       = 250;       // Limite diário de perda


int OnInit() {
  
  setMagicNumber(expertId);
  
  candlesToClose = 100;
  
  
  if (backtest) {
  
    strategy.id       = 999;
    strategy.symbol   = _Symbol;
    strategy.name     = expertName + " Backtest";
    strategy.lots     = 1;
    strategy.target   = isMiniDolar ?  5000 :  500;
    strategy.stopLoss = isMiniDolar ? 50000 :  250;
    
  } else {
  
    if (setStrategy(expertId, symbolName)) {
    
      profitLimit     = strategy.goal;
      lossLimit       = strategy.riskLimit;
      
      if (!CreateControlPanel(expertName)) return(INIT_FAILED);
    }
  }
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
  
  if (Candle::newBar()) {
      
    double currentBalance = getCurrentBalance();
  
    if (currentBalance > previousBalance) {
      
      PlaySound("request.wav");
    }
  
    if (!PositionSelect(symbolName)) {
    
      Candle *candle1 = new Candle(1, mrbzHeight);
    
      if (candle1.getFigure() == MAROBOZU_UP) {
        SellAtMarket(candle1.getOpen(), candle1.getClose());
      }
      
      if (candle1.getFigure() == MAROBOZU_DOWN) {
        BuyAtMarket(candle1.getOpen(), candle1.getClose());
      }
    }
    
    previousBalance = currentBalance;
  }
}


void OnDeinit(const int reason) {
  
  ExtDialog.Destroy(reason);
  
  Comment("");
}
