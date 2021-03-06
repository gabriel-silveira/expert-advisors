#include "./Panel.mqh"

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;

//+------------------------------------------------------------------+
//| Control Fields Handlers                                          |
//+------------------------------------------------------------------+


CLabel    m_label_strategy;
CComboBox m_combo_strategy;

CLabel    label_symbol;
CLabel    label_lots;
CLabel    label_target;
CLabel    label_stopLoss;
CLabel    label_shift;
CLabel    label_broker;




int   fieldTop[]  = { 14, 45, 77 };

int   lblLeft     = 14;
int   lblWidth    = 100;
int   lblHeight   = 100;

int   txtLeft     = 114;
int   txtWidth    = 50;
int   txtHeight   = 20;


//+------------------------------------------------------------------+
//| Manipuladores de eventos                                         |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
  //
EVENT_MAP_END(CAppDialog)



bool CreateControlPanel(
  string EAName
) {

  if(!ExtDialog.Create(
    EAName+" ("+_Symbol+")",
    10, 25, 215, 290
    // 10, 25, 500, 500
  )) return false;
  
  createStrategyInfo();
  
  ExtDialog.Run();
  
  return true;
}


bool createStrategyInfo() {
  
  createLabel(
    m_label_strategy,
    "labelStrategy",
    "Strategy: "+strategy.name,
    21
  );
  
  createLabel(
    label_symbol,
    "labelSymbol",
    "Symbol: "+ (string) strategy.symbol,
    60
  );
  
  createLabel(
    label_lots,
    "labelLots",
    "Lots: "+(string) strategy.lots,
    85
  );
  
  createLabel(
    label_target,
    "labelTarget",
    "Target: "+(string)(int) strategy.target,
    110
  );
  
  createLabel(
    label_stopLoss,
    "labelStopLoss",
    "Stop loss: "+(string)(int) strategy.stopLoss,
    135
  );
  
  createLabel(
    label_shift,
    "labelShift",
    "Shift: "+(string) strategy.startTime + " - " + (string) strategy.endTime + "h",
    160
  );
  
  createLabel(
    label_broker,
    "labelBroker",
    "Broker: "+strategy.broker,
    200
  );
  
  return true;
}


void OnChartEvent(const int id,           // event ID  
                  const long& lparam,     // event parameter of the long type
                  const double& dparam,   // event parameter of the double type
                  const string& sparam) { // event parameter of the string type
   
    ExtDialog.ChartEvent(id, lparam, dparam, sparam);
}



bool createLabel(
  CLabel &labelhandler,
  string id,
  string value,
  int top
) {
   

  labelhandler.Create(
    0,
    id,
    0,
    11, top, 100, top + 20
  );
  
  labelhandler.Text(value);
  if (!ExtDialog.Add(labelhandler)) return(false);
  
  return true;
}