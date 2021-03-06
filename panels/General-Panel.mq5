#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Painel de controle do Beethoven v0.1"

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>


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



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  //--- create application dialog
  if(!ExtDialog.Create(
    0,
    "Beethoven",
    0,
    10,
    25,
    380,
    344
  )) return(INIT_FAILED);
  
  //--- run application
  ExtDialog.Run();
  
  //--- succeed
  return(INIT_SUCCEEDED);
}



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


//+------------------------------------------------------------------+
//| Classe CControlsDialog                                           |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog {
  private:
    CButton           m_button;
    CEdit             m_edit;
    CLabel            m_label;
  
  public:
     CControlsDialog(void);
    ~CControlsDialog(void);
  
  //--- criar diálogo
  virtual bool Create(
    const long    chart,
    const string  name,
    const int     subwin,
    const int     x1,
    const int     y1,
    const int     x2,
    const int     y2
  );
  
  //--- manipulador de eventos do gráfico
  virtual bool OnEvent(
    const int     id,
    const long    &lparam,
    const double  &dparam,
    const string  &sparam
  );
  
  protected:
    //--- controles dependentes
    bool CreateButton(void);
    
    bool CreateInputField(
      int x,
      int y,
      string label,
      string value
    );
    
    //--- cria campo de texto
    bool CreateEdit(
      int x,
      string value
    );
    
    bool CreateLabel(
      int x,
      int y,
      string label
    );
    
    //--- manipuladores dos eventos dos controles dependentes
    void OnClickButton(void);
    void OnEditInputText(void);
};



//+------------------------------------------------------------------+
//| Manipuladores de eventos                                         |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK, m_button, OnClickButton)
ON_EVENT(ON_END_EDIT, m_edit, OnEditInputText)
EVENT_MAP_END(CAppDialog)


//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void) {}


//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void) {}



//+------------------------------------------------------------------+
//| Cria o diálogo                                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(
  const long chart,
  const string name,
  const int subwin,
  const int x1,
  const int y1,
  const int x2,
  const int y2
) {

  if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)) return(false);
  
  CreateInputField(10, 10, "Contratos", "5");
  
  // if(!CreateButton()) return(false);
  
  // if(!CreateEdit("Contratos", 10, 10)) return(false);
  
  return(true);
}



bool CControlsDialog::CreateButton(void) {
  //--- coordinates
  int x1 = INDENT_LEFT;
  int y1 = INDENT_TOP + (EDIT_HEIGHT + CONTROLS_GAP_Y);
  int x2 = x1 + BUTTON_WIDTH;
  int y2 = y1 + BUTTON_HEIGHT;
  
  //--- create
  if(!m_button.Create(
    m_chart_id,
    m_name+"Button1",
    m_subwin,
    x1,
    y1,
    x2,
    y2
  )) return(false);
  
  if(!m_button.Text("Button1")) return(false);
  
  if(!Add(m_button)) return(false);
  
  //--- succeed
  return(true);
}


bool CControlsDialog::CreateInputField(
  int x,
  int y,
  string label,
  string value
) {
  
  if (CreateLabel(x, y, label)) {
    
    CreateEdit(m_label.Width(), value);
  }
  
  return true;
}


bool CControlsDialog::CreateEdit(
  int x,
  string value
) {
  
  //--- coordinates
  int x1 = x + 10;
  int y1 = 15;
  int x2 = x1 + 80;
  int y2 = 35;
  
  //--- create
  if(!m_edit.Create(
    m_chart_id,
    m_name + "Edit",
    m_subwin,
    x1,
    y1,
    x2,
    y2
  )) return(false);
  
  m_edit.TextAlign(ALIGN_CENTER);
  m_edit.Text(value);
  
  //--- permitimos modificar o conteúdo
  if(!m_edit.ReadOnly(false)) return(false);
  
  if(!Add(m_edit)) return(false);
  
  //--- succeed
  return(true);
}



bool CControlsDialog::CreateLabel(
  int x,
  int y,
  string label
) {

  int x1 = x;
  int y1 = y + CONTROLS_GAP_Y;
  int x2 = x1 + 80;
  int y2 = y1 + 20;
  
  if(!m_label.Create(
    m_chart_id,
    m_name + label,
    m_subwin,
    x1,
    y1,
    x2,
    y2
  )) return(false);
  
  if(!m_label.Text(label)) return(false);
  
  if(!Add(m_label)) return(false);
  
  return(true);
}
  


//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButton(void) {
  
  Print("Clicou!");
}



void CControlsDialog::OnEditInputText(void) {
  
  Print("Editou o texto...");
}


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;


