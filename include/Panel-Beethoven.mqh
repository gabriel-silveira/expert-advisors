#include "./Panel.mqh"

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;

//+------------------------------------------------------------------+
//| Control Fields Handlers                                          |
//+------------------------------------------------------------------+

CLabel      m_label_target;
CEdit       m_input_target;

CLabel      m_label_lots;
CEdit       m_input_lots;

CLabel      m_label_shift;
CComboBox   m_combo_shift;



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
    10, 25, 180, 200
    // 10, 25, 500, 500
  )) return false;
  
  
  Print(INDENT_TOP + (EDIT_HEIGHT+CONTROLS_GAP_Y) +
            (BUTTON_HEIGHT + CONTROLS_GAP_Y)+
            (EDIT_HEIGHT + CONTROLS_GAP_Y));
  int x1 =  INDENT_LEFT;
  int y1 =  14;
  int x2 =  150;
  int y2 =  y1 + EDIT_HEIGHT;
  
  //--- create
  if (!m_combo_shift.Create(0,m_combo_shift.Name()+"ComboBox",0,x1,y1,x2,y2)) {
    return(false);
  }
  
  if (!ExtDialog.Add(m_combo_shift)) return(false);
  
  m_combo_shift.ItemAdd("Scalp 10");
  
  ExtDialog.Run();
  
  return true;
}


void createShiftField() {
  
  // shift label
  ExtDialog.CreateLabel(
    m_label_shift,
    lblLeft,
    fieldTop[2],
    lblWidth,
    lblHeight,
    "Turno"
  );
  
  // shift comboBox
  ExtDialog.CreateComboBox(
    "comboShiftStart",
    m_combo_shift,
    100,
    fieldTop[1],
    60,
    txtHeight,
    "3"
  );
}




void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) { // event parameter of the string type
   
    ExtDialog.ChartEvent(id,lparam,dparam,sparam);
}
