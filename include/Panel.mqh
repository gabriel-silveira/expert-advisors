#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Painel de controle do Beethoven v0.1"

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh>


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


/*
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

  //--- limpamos os comentários
  Comment("");
  
  //--- destroy dialog
  ExtDialog.Destroy(reason);
}

//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) { // event parameter of the string type
   
    ExtDialog.ChartEvent(id,lparam,dparam,sparam);
}
*/


//+------------------------------------------------------------------+
//| Classe CControlsDialog                                           |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog {
  private:
    CButton           m_button;
  
  public:
     CControlsDialog(void);
    ~CControlsDialog(void);
    
    //--- cria label do campo de texto
    bool CreateLabel(
      CLabel &labelHandler,
      int x,
      int y,
      int width,
      int height,
      string label
    );
    
    //--- cria campo de texto
    bool CreateEdit(
      string id,
      CEdit &editHandler,
      int x,
      int y,
      int width,
      int height,
      string value
    );
    
    
    bool CreateComboBox(
      string id,
      CComboBox &comboHandler,
      int x,
      int y,
      int width,
      int height,
      string value
    );
    
    
  
  //--- criar diálogo
  virtual bool Create(
    const string  name,
    const int     x1,
    const int     y1,
    const int     x2,
    const int     y2
  );
  
  bool CreateInputField(
    CLabel &labelField,
    CEdit   &editField,
    int x,
    int y,
    int width,
    int height,
    string label,
    string value
  );
  
  //--- manipulador de eventos do gráfico
  virtual bool OnEvent(
    const int     id,
    const long    &lparam,
    const double  &dparam,
    const string  &sparam
  );
};



//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void) {}


//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void) {}



//+------------------------------------------------------------------+
//| Cria o diálogo CAppDialog                                        |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(
  const string name,
  const int x1,
  const int y1,
  const int x2,
  const int y2
) {

  if(!CAppDialog::Create(0,name,0,x1,y1,x2,y2)) return(false);
  
  // setBackColor(clrBlack);
  
  // if(!CreateButton()) return(false);
  
  // if(!CreateEdit("Contratos", 10, 10)) return(false);
  
  return(true);
}



bool CControlsDialog::CreateLabel(
  CLabel &labelHandler,
  int x,
  int y,
  int width,
  int height,
  string label
) {

  int x1 = x;
  int y1 = y;
  
  int x2 = x1 + width;
  int y2 = y1 + height;
  
  if(!labelHandler.Create(
    m_chart_id,
    m_name + label,
    m_subwin,
    x1,
    y1,
    x2,
    y2
  )) return(false);
  
  if(!labelHandler.Text(label)) return(false);
  
  if(!Add(labelHandler)) return(false);
  
  return(true);
}



bool CControlsDialog::CreateEdit(
  string id,
  CEdit &editHandler,
  int x,
  int y,
  int width,
  int height,
  string value
) {
  //--- coordinates
  int x1 = x;
  int y1 = y;
  int x2 = x1 + width;
  int y2 = y1 + height;
  
  //--- create
  if(!editHandler.Create(
    m_chart_id,
    id,
    m_subwin,
    x1,
    y1,
    x2,
    y2
  )) return(false);
  
  editHandler.TextAlign(ALIGN_CENTER);
  editHandler.Text(value);
  
  //--- permitimos modificar o conteúdo
  if(!editHandler.ReadOnly(false)) return(false);
  
  if(!Add(editHandler)) return(false);
  
  //--- succeed
  return(true);
}



bool CControlsDialog::CreateComboBox(
  string id,
  CComboBox &comboHandler,
  int x,
  int y,
  int width,
  int height,
  string value
) {

  //--- coordinates
  int x1 = x;
  int y1 = y;
  int x2 = x1 + width;
  int y2 = y1 + height;
  
  if(!comboHandler.Create(
    m_chart_id,
    id,
    m_subwin,
    x1,
    y1,
    x2,
  y2
  )) return(false);
  
  if (!comboHandler.Create(m_chart_id, m_name+"ComboBox", m_subwin,x1,y1,x2,y2)) return(false);
  
  if(!Add(comboHandler)) return(false);
  
  //--- fill out with strings
  for (int i = 9; i < 17; i++) {
  
    if (!comboHandler.ItemAdd(IntegerToString(i)+"h")) return(false);
  }
  
  //--- succeed
  return(true);
}
