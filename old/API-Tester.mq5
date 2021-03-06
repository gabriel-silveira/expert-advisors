#include "include/Candle.mqh"
#include "include/Trade.mqh"

//+------------------------------------------------------------------+

input double num_lots = 7; // Contratos
input int deviation = 10; // Desvio

int OnInit() {

  return(INIT_SUCCEEDED);
}
  
  
void OnDeinit(const int reason) {
   
}
  
  
void OnTick() {

  if (PositionSelect(_Symbol) == false && Candle::newBar()) {

      // BuyAtMarket(stopLoss, takeProfit);
      SendRequest();
  }
}



bool SendRequest() {

  string baseUrl = "http://127.0.0.1:7000/trades";

  string cookie = NULL, headers;
  
  char   post[], result[];
  
  //--- para trabalhar com o servidor é necessário adicionar a URL "https://finance.yahoo.com"
  //--- na lista de URLs permitidas (menu Principal->Ferramentas->Opções, guia "Experts"):
  //--- redefinimos o código do último erro
  ResetLastError();
  
  //--- download da página html do Yahoo Finance
  int res = WebRequest(
    "GET", // método HTTP
    baseUrl, // URL
    headers, // cabeçalho 
    60000, // tempo esgotado
    post, // A matriz do corpo da mensagem HTTP
    result, // Uma matriz contendo dados de resposta do servidor
    headers // cabeçalhos de resposta do servidor
  );
  
  
  
  if (res == -1) {
  
    Print("Erro: ", GetLastError());
    
    //--- é possível que a URL não esteja na lista, exibimos uma mensagem sobre a necessidade de adicioná-la
    MessageBox("É necessário adicionar um endereço '"+baseUrl+"' à lista de URL permitidas na guia 'Experts'","Erro",MB_ICONINFORMATION);
  } else {
  
    if (res == 200) {
    
      //--- download bem-sucedido
      PrintFormat("O arquivo foi baixado com sucesso, tamanho %d bytes.", ArraySize(result));
      
      //PrintFormat("Cabeçalhos do servidor: %s",headers);
      //--- salvamos os dados em um arquivo
      int filehandle = FileOpen("url.htm", FILE_WRITE|FILE_BIN);
      
      if(filehandle != INVALID_HANDLE) {
      
        //--- armazenamos o conteúdo do array result[] no arquivo
        FileWriteArray(filehandle, result, 0, ArraySize(result));
        
        //--- fechamos o arquivo
        FileClose(filehandle);
      } else {
      
        Print("Erro em FileOpen. Código de erro =",GetLastError());
      }
    } else {
    
      PrintFormat("Erro de download '%s', código %d", baseUrl, res);
    }
  }
  
  return true;
}
