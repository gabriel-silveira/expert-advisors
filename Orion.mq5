#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Objetivo:"
#property description "Atingir um lucro diário de R$ 200"
#property description "\n"
#property description "Sinal:"
#property description "Quando o ADX estiver acima de 40 e subindo, (em up trend) ao aparecer um shutting star entra numa venda e, (em down trend) ao aparecer um martelo entra numa compra."
#property description "\n"
#property description "Alvo:"
#property description "50 pts, Mini Índice 1m, 25 lotes"

#include "./include/inc.mqh"

#include "./indicators/ADX.mqh"

#include "./indicators/RSI.mqh"

#include "./indicators/Stochastic.mqh"


bool          backtest              = false;

string        expertName            = "Orion";

bool          restrictedHours       = true;
int           hourToStart           = 10;             // Início
int           hourToFinish          = 16;             // Término

double        profitLimit           = 200;            // Limite diário de ganho
double        lossLimit             = 9999;           // Limite diário de perda

double        input maxADX          = 40;             // ADX Máximo

int           input lots            = 25;             // Lots
double        input tp              = 50;             // Take profit
double        input sl              = 100;            // Stop loss

int OnInit() {
  
  setMagicNumber(777999);
  
  InitADX(14);
  
  strategy.lots     = lots;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {

  if (Candle::newBar()) {
      
    double currentBalance = getCurrentBalance();
    
    
    CopyADXBuffers();
    
    
    if (workTime() && !isEnoughForToday(currentBalance)) {
    
      if (!PositionSelect(_Symbol)) {
        
        // ADX acima de 40 e subindo...
        if (
          ADXBuffer[1] > maxADX
          &&
          ADXBuffer[1] > ADXBuffer[2]
          &&
          ADXBuffer[2] > ADXBuffer[3]
        ) {
        
          Candle *c1 = new Candle(1, 100);
          
          
          // BUY
          if (
            // bullish trend
            DI_plusBuffer[1] > DI_minusBuffer[1]
            &&
            c1.getFigure() == SHUTTING_STAR
          ) {
          
            SellAtMarket(expertName+" - Sell");
          }
          
          
          // SELL
          if (
            // bearish trend
            DI_minusBuffer[1] > DI_plusBuffer[1]
            &&
            c1.getFigure() == HAMMER
          ) {
            
            BuyAtMarket(expertName+" - Buy");
          }
        }
      }
    }
  }
}


