#property copyright "Copyright 2020, Silveira Trading Systems"
#property link      "https://www.gabrielsilveira.com.br"
#property version   "1.00"
#property description "Objetivo:"
#property description "Atingir um lucro diário de R$ 200"
#property description "\n"
#property description "Sinal:"
#property description "Entra em compra ou venda ao cruzar a média móvel institucional. O candle que atravessou deve ter altura entre 20 e 50 pts e fechar próximo da média."
#property description "\n"
#property description "Alvo:"
#property description "50 pontos, Mini Índice 1m, 20 lotes"

#include "./include/inc.mqh"

#include "./indicators/BollingerBands.mqh"


bool          backtest              = false;

string        expertName            = "Eros";

bool          restrictedHours       = true;
int           hourToStart           = 13;             // Início
int           hourToFinish          = 16;             // Término

double        profitLimit           = 9999;            // Limite diário de ganho
double        lossLimit             = 9999;           // Limite diário de perda

int           input lots            = 20;             // Lots
double        tp                    = 50;             // Take profit
double        sl                    = 200;            // Stop loss


int OnInit() {
  
  setMagicNumber(777999);
  
  InitBollingerBands();
  
  strategy.lots     = lots;
  strategy.target   = tp;
  strategy.stopLoss = sl;
  
  return(INIT_SUCCEEDED);
}



void OnTick() {
      
  if(CopyBollingerBandsBuffer()) {

    if (Candle::newBar()) {
        
      double currentBalance = getCurrentBalance();
      
      if (workTime() && !isEnoughForToday(currentBalance)) {
      
        if (!PositionSelect(_Symbol)) {
          
          Candle *c1 = new Candle(1, 150);
          
          Candle *c2 = new Candle(2, 150);
          
          double distanceFromMA = MathAbs(c1.getClose() - MiddleBuffer[1]);
          
          if (
            c1.getClose() > MiddleBuffer[1]
            &&
            c1.getOpen()  < MiddleBuffer[1]
            &&
            c1.getHeight() < 50
            &&
            c1.getHeight() > 30
            &&
            distanceFromMA < 10
          ) {
          
            BuyAtMarket(expertName+" - Buy");
          }
          
          
          if (
            c1.getClose() < MiddleBuffer[1]
            &&
            c1.getOpen()  > MiddleBuffer[1]
            &&
            c1.getHeight() < 50
            &&
            c1.getHeight() > 30
            &&
            distanceFromMA < 10
          ) {
          
            SellAtMarket(expertName+" - Sell");
          }
        }
      }
    }
  }
}


