//+------------------------------------------------------------------+
//|                                            LearnCAppDialog_2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Controls\Dialog.mqh>

CAppDialog AppWindow;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog
   if(!AppWindow.Create(0,"AppWindow",0,20,20,360,324))
      return(INIT_FAILED);
//---
   int total=AppWindow.ControlsTotal();
   CWndClient*myclient;
   for(int i=0;i<total;i++)
     {
      CWnd*obj=AppWindow.Control(i);
      string name=obj.Name();
      PrintFormat("%d is %s",i,name);
      //--- color 
      if(StringFind(name,"Client")>0)
        {
         CWndClient *client=(CWndClient*)obj;
         client.ColorBackground(clrRed);
         myclient=client;
         Print("client.ColorBackground(clrRed);");
         ChartRedraw();
        }
      //---
      if(StringFind(name,"Back")>0)
        {
         CPanel *panel=(CPanel*) obj;
         panel.ColorBackground(clrGreen);
         Print("panel.ColorBackground(clrGreen);");
         ChartRedraw();
        }
     }
   Sleep(5000);
   myclient.Destroy();
//--- run application
   AppWindow.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy dialog
   AppWindow.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   AppWindow.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
