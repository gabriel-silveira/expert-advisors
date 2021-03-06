//+------------------------------------------------------------------+
//|                                                      s_r_ind.mq5 |
//|                                                         Shion.bd |
//|                                            https://investmany.ru |
//+------------------------------------------------------------------+
#property copyright "Shion.bd"
#property link      "https://investmany.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plotar suporte
#property indicator_label1  "support"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plotar resistência
#property indicator_label2  "resistance"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- buffers do indicator
double         supportBuffer[];
double         resistanceBuffer[];
double K,B;
int Dig;
//---
input uchar Period_RSI=8;     // Período RSI
input int Analyze_Bars= 300;  // Quantas barras no histórico para análise  
input double Low_RSI = 35.0;  // Nível mínimo do RSI para encontrar extremo 
input double High_RSI= 65.0;  // Nível máximo do RSI para encontrar extremo  
input float Distans=13.0;     // Desvio do nível  
ENUM_TIMEFRAMES Period_Trade; // Período do gráfico
string Trade_Symbol;          // Símbolo
bool First_Ext;               // Tipo do primeiro extremo 
int h_RSI; // Handle do indicador RSI
int Bars_H; // Número de barras para análise
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct st_Bars // inicialização de estrutura 
  {
   int               Bar_1;
   int               Bar_2;
   int               Bar_3;
   int               Bar_4;
  };
st_Bars Bars_Ext; // declaração da variável tipo estrutura  
//+------------------------------------------------------------------+
//| Função de inicialização do indicador personalizado               |
//+------------------------------------------------------------------+
int OnInit()
  {
   Trade_Symbol=Symbol();
   Period_Trade=Period();
   Dig=(int)SymbolInfoInteger(Trade_Symbol,SYMBOL_DIGITS);//número de casas decimais do símbolo atual
//--- mapeamento dos buffers do indicador
   SetIndexBuffer(0,supportBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,resistanceBuffer,INDICATOR_DATA);
   h_RSI=iRSI(Trade_Symbol,Period_Trade,Period_RSI,PRICE_CLOSE); //handle de retorno do indicador RSI 
   if(h_RSI<0) Print("Handle incorreto do RSI ");
   if(Analyze_Bars>Bars(Trade_Symbol,Period_Trade)) //se menos barras no histórico para a análise,
     {
      Print("O histórico menor",Analyze_Bars,"barra"); // do que especificado no parâmetro barras,então você precisa chamar esta
      Bars_H=Bars(Trade_Symbol,Period_Trade);
      Print("Número de barras no histórico = ",Bars_H);
     }
   else
     {
      Bars_H=Analyze_Bars;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(h_RSI); // remove o handle de desinicialização  
  }
//+------------------------------------------------------------------+
//| Indicador personalizado da função de iteração                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(supportBuffer,true);
   ArraySetAsSeries(resistanceBuffer,true);
   Bars_Ext.Bar_1=Ext_1(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Distans,Period_Trade); // encontrar índice da barra do primeira extremo 
   if(Bars_Ext.Bar_1<0)
     {
      Print("Barras insuficientes para análise no histórico");
      return(0);
     }
   if(Bars_Ext.Bar_1>0) First_Ext=One_ext(Bars_Ext,Trade_Symbol,h_RSI,Low_RSI,Period_Trade);
   Bars_Ext.Bar_2=Ext_2(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Bars_Ext,2,Distans,First_Ext,Period_Trade); // encontrar índice da barra do segundo extremo 
   if(Bars_Ext.Bar_2<0)
     {
      Print("Barras insuficientes para análise no histórico");
      return(0);
     }
   Bars_Ext.Bar_3=Ext_2(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Bars_Ext,3,Distans,First_Ext,Period_Trade); // encontrar índice da barra do terceiro extremo 
   if(Bars_Ext.Bar_3<0)
     {
      Print("Barras insuficientes para análise no histórico");
      return(0);
     }
   Bars_Ext.Bar_4=Ext_2(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Bars_Ext,4,Distans,First_Ext,Period_Trade); // encontrar índice da barra do último extremo 
   if(Bars_Ext.Bar_4<0)
     {
      Print("Barras insuficientes para análise no histórico");
      return(0);
     }
   Level(true,First_Ext,Bars_Ext,Trade_Symbol,Period_Trade); // obter coeficientes K e b para linha resistência 
   for(int i=0;i<Bars_H;i++)
     {
      resistanceBuffer[i]=NormalizeDouble(K*i+B,Dig);
     }
   Level(false,First_Ext,Bars_Ext,Trade_Symbol,Period_Trade); // obter coeficientes K e b para linha suporte 
   for(int i=0;i<Bars_H;i++)
     {
      supportBuffer[i]=NormalizeDouble(K*i+B,Dig);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Level(bool _line,              // parâmetro que define linha de resistência/suporte, que têm coeficientes a serem encontrados
           bool _first_ext,         // tipo do primeiro extremo (já familiar para você)
           st_Bars  &bars_ext,      // estrutura que contém índice das barras
           string _symbol,          // símbolo
           ENUM_TIMEFRAMES _period) // período do gráfico
  {
   int bars=Bars_H; // número de barras analisadas 
   double m_high[],m_low[]; // inicialização de arrays
   ArraySetAsSeries(m_high,true); //arrays são indexados a partir de primeiro elemento
   ArraySetAsSeries(m_low,true);
   int h_high = CopyHigh (_symbol,_period, 0, bars, m_high); //array de preenchimento das Máximas dos preços das velas
   int h_low = CopyLow(_symbol, _period, 0, bars, m_low);    //array de preenchimento das Mínimas dos preços das velas
   double price_1,price_2;
   int _bar1,_bar2;
   int digits=(int)SymbolInfoInteger(_symbol,SYMBOL_DIGITS);//número de casas decimais no símbolo atual
   if(_line==true) //Se linha resistência é requerida
     {
      if(_first_ext==true) // se o primeiro extremo é o máximo
        {
         price_1 = NormalizeDouble(m_high[bars_ext.Bar_1], digits);
         price_2 = NormalizeDouble(m_high[bars_ext.Bar_3], digits);
         _bar1 = bars_ext.Bar_1;
         _bar2 = bars_ext.Bar_3;
        }
      else                                                  //se mínimo
        {
         price_1 = NormalizeDouble(m_high[bars_ext.Bar_2], digits);
         price_2 = NormalizeDouble(m_high[bars_ext.Bar_4], digits);
         _bar1 = bars_ext.Bar_2;
         _bar2 = bars_ext.Bar_4;
        }
     }
   else                                                     //Se linha suporte é requerida
     {
      if(_first_ext==true) // se o primeiro extremo é o máximo
        {
         price_1 = NormalizeDouble(m_low[bars_ext.Bar_2], digits);
         price_2 = NormalizeDouble(m_low[bars_ext.Bar_4], digits);
         _bar1 = bars_ext.Bar_2;
         _bar2 = bars_ext.Bar_4;
        }
      else                                                  //se mínimo
        {
         price_1 = NormalizeDouble(m_low[bars_ext.Bar_1], digits);
         price_2 = NormalizeDouble(m_low[bars_ext.Bar_3], digits);
         _bar1 = bars_ext.Bar_1;
         _bar2 = bars_ext.Bar_3;
        }
     }
   K=(price_2-price_1)/(_bar2-_bar1);  //encontra coeficiente K
   B=price_1-K*_bar1;                  //encontrar coeficiente B
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ext_1 (double low,        //mínima do nível RSI, nível sobrevendido
           double high,       //máxima do nível RSI, nível sobrecomprado
           int bars,          //número de barras analisados, para evitar a cópia de dados desnecessários em arrays 
                              //possibilidade de configurar bars = 300
           int h_rsi,         //handle do indicador do RSI
           string symbol,     //símbolo do gráfico
           float distans,     //distância para o desvio de um nível do indicador
                              //permite a definição dos limites de busca da primeira barra extrema
           ENUM_TIMEFRAMES period_trade) //peeríodo do gráfico
  {
   double m_rsi[],m_high[],m_low[]; // incialização dos arrays
   ArraySetAsSeries(m_rsi,true); // arrays são indexados a partir do primeiro elemento
   ArraySetAsSeries(m_high,true);
   ArraySetAsSeries(m_low,true);
   int h_high = CopyHigh (symbol,period_trade, 0, bars, m_high); //encontra o array da Máxima dos preços das velas
   int h_low = CopyLow(symbol, period_trade, 0, bars, m_low);    //encontra o array da Mínima dos preços das velas
   if(CopyBuffer (h_rsi,0,0, bars, m_rsi) <bars)                 //preenche o array com dados do indicador RSI 
     {
      Print("Falha na cópia do buffer do indicador!");
     }
   int index_bar= -1; // inicialização da variável que conterá o índice das barras desejadas
   bool flag = false; // é necessário esta variável para evitar a análise das velas na tendência atual inacabada
   bool ext_max=true; // variáveis do tipo bool são usadas a fim de parar a análise da barra no momento certo
   bool ext_min= true;
   double min=100000.0; // Identificar as variáveis para as máximas e mínimas dos preços
   double max= 0.0;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);//número de casas decimais no símbolo atual
   for(int i=0; i<bars;i++) //loop de barra
     {
      double rsi=m_rsi[i]; // get RSI indicator value 
      double price_max = NormalizeDouble(m_high[i], digits);   //Máximas dos preços
      double price_min = NormalizeDouble(m_low[i], digits);    //Mínimas dos preços da barra selecionada
      if(flag==false) // condição para evitar pesquisa de extremo na tendência incompleta
        {
         if(rsi<=low || rsi>=high) //se as primeiras estão dentro das zonas sobrecompradas ou sobrevendidas,
            continue; // então move para a próxima barra
         else flag=true;       //se não, processa com a análise
        }
      if(rsi<low) //se for encontrado cruzamento do RSI com o nível mínimo
        {
         if(ext_min==true) // Se RSI não cruzou o nível máximo
           {
            if(ext_max==true) // se a procura do extremo máximo ainda não foi desabilitado,
              {
               ext_max=false; // então desabilita a pesquisa para o extremo máximo 
               if(distans>=0) high=high-distans; //muda nível máximo,  em seguida, 
              }                                  //uma segunda barra de busca será executada
            if(price_min<min) //procura e memoriza o primeiro índice de barra
              {// comparando as Mínimas dos preços das velas
               min=price_min;
               index_bar=i;
              }
           }
         else break; /*Loop de saída, a busca do extremo mínimo já está proibida,
          isso significa que o máximo foi encontrado*/
        }
      if(rsi>high) // é o mesmo algoritmo, apenas na busca do extremo máximo
        {
         if(ext_max==true)
           {
            if(ext_min==true)
              {
               ext_min=false; //se necessário desabilita a busca do extremo mínimo 
               if(distans>=0) low=low+distans;
              }
            if(price_max>max) //busca e memoriza extremo
              {
               max=price_max;
               index_bar=i;
              }
           }
         else break; /*Loop de saída desde que que a busca do máximo extremo esteja desativada,
        então um mínimo é encontrado*/
        }
     }
   return(index_bar);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ext_2(double low,    //mínima do nível RSI, nível sobrevendido
          double high,   //máxima do nível RSI, nível sobrecomprado
          int bars,      //número de barras analisados, para evitar a cópia de dados desnecessários em arrays 
                         //possibilidade de configurar bars = 300
          int h_rsi,     //handle do indicador RSI
          string symbol, //símbolo do gráfico
          st_Bars  &bars_ext,// estrutura contendo códigos das barras encontradas 
          char n_bar,     // número ordinário de barra necessário para encontrar (2, 3 ou 4)
          float distans,  // distância para o desvio de um dos níveis do indicador
          bool first_ext, // tipo da primeira barra
          ENUM_TIMEFRAMES period_trade)//período do gráfico
  {
   double m_rsi[],m_high[],m_low[]; // inicialização dos arrays
   ArraySetAsSeries(m_rsi,true); // arrays são indexadas a partir do primeiro elemento
   ArraySetAsSeries(m_high,true);
   ArraySetAsSeries(m_low,true);
   int h_high= CopyHigh(symbol,period_trade,0,bars,m_high);    //preenche array da Máxima dos preços das velas
   int h_low = CopyLow(symbol, period_trade, 0, bars, m_low);  //preenche array da Máxima dos preços das velas
   if(CopyBuffer(h_rsi,0,0,bars,m_rsi)<bars)                   //preenche arrays com dados do indicador
     {
      Print("Falha ao copiar buffer do indicador!");
      //return(0);
     }
   int index_bar=-1;
   int bar_1=-1; // índice desejado do código de barras, o índice da barra anterior
   bool high_level=false; // variáveis para determinar o tipo de barras desejadas
   bool low_level = false;
   bool _start=false; // variáveis do tipo bool são usadas a fim de parar a análise da barra na momento certo
   double rsi,min,max,price_max,price_min;
   min=10000.0; max=0.0;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
// --- Neste bloco determinamos em qual (suporte ou resistência) linha deve ser posicionado o extremo desejado
   if(n_bar!=3)
     {
      if(first_ext==true) // se primeiro ponto foi máximo
        {
         low_level=true;//então esta deve ser um mínimo
         if(distans>=0) low=low+distans;
        }
      else //if minimum
        {
         high_level = true;
         if(distans>=0) high = high-distans;
        }
     }
   else
     {
      if(first_ext==false)//if first point was minimum
        {
         low_level=true;//then this should be minimum
         if(distans>=0) high=high-distans;
        }
      else //se máximo
        {
         high_level = true;
         if(distans>=0) low = low+distans;
        }
     }
//---
   switch(n_bar) // encontra o índice da barra anterior
     {
      case 2: bar_1 = bars_ext.Bar_1; break;
      case 3: bar_1 = bars_ext.Bar_2; break;
      case 4: bar_1 = bars_ext.Bar_3; break;
     }
   for(int i=bar_1; i<bars;i++) //analisa barras restantes
     {
      rsi=m_rsi[i];
      price_max = NormalizeDouble(m_high[i], digits);
      price_min = NormalizeDouble(m_low[i], digits);
      if(_start==true && ((low_level==true && rsi>=high) || (high_level==true && rsi<=low)))
        {
         break; // loop de saída se segundo extremo for encontrado e o RSI cruza o nível oposto
        }
      if(low_level==true) // se procurando por extremo mínimo
        {
         if(rsi<=low)
           {
            if(_start==false) _start=true;
            if(price_min<min)
              {
               min=price_min;
               index_bar=i;
              }
           }
        }
      else //se procurando por extremo máximo
        {
         if(rsi>=high)
           {
            if(_start==false) _start=true;
            if(price_max>=max)
              {
               max=price_max;
               index_bar=i;
              }
           }
        }
     }
   return(index_bar);
  }
//+------------------------------------------------------------------+
//|Determina se a primeira barra foi max ou min                      |
//+------------------------------------------------------------------+
bool One_ext(st_Bars &bars_ext, // variável do tipo estrutura para obter o índice da primeira barra
             string symbol,     //símbolo do gráfico
             int h_rsi,         //handle do indicador
             double low,        //define nível sobrevendido do RSI (nível máximo pode ser usado)
             ENUM_TIMEFRAMES period_trade) //período do gráfico
  {
   double m_rsi[]; // inicialização do array de dados do indicador
   ArraySetAsSeries(m_rsi,true); // indexando
   CopyBuffer(h_rsi,0,0,bars_ext.Bar_1+1,m_rsi); // preenche array com dados do RSI 
   double rsi=m_rsi[bars_ext.Bar_1]; //define valor do RSIna barra com o primeiro extremo
   if(rsi<=low)                      //se valor está abaixo do nível mínimo,
      return(false);                 //então o primeiro extremo é mínimo
   else                              //se não,
   return(true);                     //então é máximo
  }
//+------------------------------------------------------------------+
