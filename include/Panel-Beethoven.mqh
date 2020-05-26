#include "./Panel.mqh"

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;

//+------------------------------------------------------------------+
//| Control Fields Handlers                                          |
//+------------------------------------------------------------------+
CLabel  m_label_lots;
CEdit   m_input_lots;

CLabel  m_label_target;
CEdit   m_input_target;



//+------------------------------------------------------------------+
//| Manipuladores de eventos                                         |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
  ON_EVENT(ON_END_EDIT, m_input_lots, OnChangeLots)
  ON_EVENT(ON_END_EDIT, m_input_target, OnChangeTarget)
EVENT_MAP_END(CAppDialog)



bool CreateControlPanel() {

  // Painel de Controle
  if(!ExtDialog.Create(
    "Beethoven ("+symbolName+")",
    10, 25, 190, 200
  )) return false;
  
  // quantidade de contratos
  ExtDialog.CreateInputField(
    m_label_lots,
    m_input_lots,
    14,
    14,
    "Contratos",
    "5"
  );
  
  // Take Profit
  /*ExtDialog.CreateInputField(
    m_label_target,
    m_input_target,
    10,
    100,
    "Alvo",
    "10"
  );*/
  
  ExtDialog.Run();
  
  return true;
}



//+------------------------------------------------------------------+
//| Event handlers                                                   |
//+------------------------------------------------------------------+
void OnChangeLots() {

  Print("OK!");
  
  num_lots = (int) m_input_lots.Text();
  
  Print("Quantidade de lotes alterado: " + m_input_lots.Text());
}


void OnChangeTarget() {

  Print("OK!");
  
  takeProfit = (int) m_input_target.Text();
  
  Print("Alvo alterado: " + m_input_target.Text());
}




void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) { // event parameter of the string type
   
    ExtDialog.ChartEvent(id,lparam,dparam,sparam);
}
