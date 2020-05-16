//+------------------------------------------------------------------+
//| Classe para realizar requisições http                            |
//+------------------------------------------------------------------+

enum Methods {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE
};

class HttpRequest {

  private:
  
    string baseUrl;
    
    string headers;
  
    char body[];
    
    char result[];
    
    string result_headers;
    
    int timeout;

  public:
    
    void HttpRequest(
      string host
    );
    
    string getMethodName(int pMethod);
    
    bool post(
      string pResource,
      string query
    );
    
    bool get(
      string pResource,
      string query
    );
    
    bool send(
      int pMethod,
      string pResource,
      string query
    );
};


HttpRequest::HttpRequest(
  string host
) {

  baseUrl = host;
  
  headers = "Content-Type: application/json";
  
  timeout = 6000;
}


bool HttpRequest::post(
  string pResource,
  string query
) {

  return send(POST, pResource, query);
}


bool HttpRequest::get(
  string pResource,
  string query
) {

  return send(GET, pResource, query);
}


bool HttpRequest::send(
  int pMethod,
  string pResource,
  string query
) {

  ResetLastError();
  
  string methodName = getMethodName(pMethod);
  
  string uri;
  
  StringConcatenate(uri, baseUrl, "/", pResource, "?", query);
  
  // Print(uri);
  
  int res = WebRequest(
    methodName, // método HTTP
    uri, // URL
    headers, // cabeçalho
    timeout, // tempo esgotado
    body, // A matriz do corpo da mensagem HTTP
    result, // Uma matriz contendo dados de resposta do servidor
    result_headers // cabeçalhos de resposta do servidor
  );
  
  
  if (res == -1) {
  
    Print("Erro: ", GetLastError());
    
    //--- é possível que a URL não esteja na lista, exibimos uma mensagem sobre a necessidade de adicioná-la
    MessageBox("É necessário adicionar um endereço '"+uri+"' à lista de URL permitidas na guia 'Experts'","Erro", MB_ICONINFORMATION);
  } else {
  
    if (res == 200) {
    
      //--- download bem-sucedido
      PrintFormat("Registro efetuado: ", query, " - ", ArraySize(result));
      
      /*
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
      }*/
    } else {
    
      PrintFormat("Erro de download '%s', código %d", baseUrl, res);
    }
  }
  
  return true;
}


string HttpRequest::getMethodName(int pMethod) {
  
  string methods[] = { "GET", "POST", "PUT", "PATCH", "GET", "DELETE" };
  
  return methods[pMethod];
}