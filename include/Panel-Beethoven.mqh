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

CLabel    label_lots;


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
  ON_EVENT(ON_CHANGE, m_combo_strategy, ChangeStrategy)
EVENT_MAP_END(CAppDialog)


//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate



bool CreateControlPanel() {

  if(!ExtDialog.Create(
    "Beethoven ("+symbolName+")",
    10, 25, 200, 200
    // 10, 25, 500, 500
  )) return false;
  
  createStrategiesField();
  
  createStrategiesDataPanel();
  
  ExtDialog.Run();
  
  return true;
}


bool createStrategiesDataPanel() {

  label_lots.Create(
    0,
    label_lots.Name()+"Label",
    0,
    INDENT_LEFT,
    80,
    100,
    100
  );
  
  label_lots.Text("Contratos: "+strategy.lots);
  
  if (!ExtDialog.Add(label_lots)) return(false);
  
  return true;
}


bool createStrategiesField() {

  // cria o label do combo de estratégias
  m_label_strategy.Create(
    0,
    m_label_strategy.Name()+"ComboBox",
    0,
    INDENT_LEFT,
    INDENT_TOP,
    100,
    20
  );
  
  m_label_strategy.Text("Estratégias");
  
  if (!ExtDialog.Add(m_label_strategy)) return(false);
  
  
  
  int x1 =  INDENT_LEFT;
  int y1 =  40;
  int x2 =  170;
  int y2 =  y1 + EDIT_HEIGHT;
  
  // cria o combo de estratégias
  if (!m_combo_strategy.Create(
    0,
    m_combo_strategy.Name()+"ComboBox",
    0,
    x1,
    y1,
    x2,
    y2
  )) {
    return(false);
  }
  
  if (!ExtDialog.Add(m_combo_strategy)) return(false);
  
  int strategiesSize = ArraySize(strategies);
  
  for (int i = 0; i < strategiesSize; i++) {
  
    m_combo_strategy.ItemAdd(
      strategies[i].name+" - "+strategies[i].symbol,
      i
    );
  }
  
  return true;
}


void ChangeStrategy(void) {

  int index = m_combo_strategy.Value();
  
  setStrategy(strategies[index]);
  
  label_lots.Text("Contratos: "+strategies[index].lots);
}


void OnChartEvent(const int id,           // event ID  
                  const long& lparam,     // event parameter of the long type
                  const double& dparam,   // event parameter of the double type
                  const string& sparam) { // event parameter of the string type
   
    ExtDialog.ChartEvent(id, lparam, dparam, sparam);
}
