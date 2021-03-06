#property copyright "Painel de Controle - Beethoven Scalper"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>

CAppDialog  AppWindow;

CButton     m_button1;

int OnInit() {
  
  if(!AppWindow.Create(0,"AppWindow",0,20,20,360,324)) return(INIT_FAILED);
  
  if (!CreateButton("Stop")) {
    return false;
  }
  
  AppWindow.Run();
  
  return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason) {
  
  Comment("");
  AppWindow.Destroy(reason);
}



void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) { // event parameter of the string type
  
  AppWindow.ChartEvent(id,lparam,dparam,sparam);
}



bool CreateButton(string label) {

  int x1 = 10;
  int y1 = 10;
  int x2 = x1 + 100;
  int y2 = y1 + 20;
  
  if (!m_button1.Create(
    0,
    label,
    0,
    x1,
    y1,
    x2,
    y2
  )) return false;
  
  if (!m_button1.Text(label)) return false;
  
  if(m_button1.Pressed())
      Print(" Estado dos controles: On");
   else
      Comment(__FUNCTION__+" Estado dos controles: Off");
  
  if (!AppWindow.Add(m_button1)) return false;
  
  return true;
}

