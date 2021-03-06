#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plotar iVolumes
#property indicator_label1  "iVolumes"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen, clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1



//--- parâmetros de entrada
ENUM_APPLIED_VOLUME  applied_volume = VOLUME_TICK;   // tipo de volume
ENUM_TIMEFRAMES      period = PERIOD_CURRENT;        // timeframe

//--- buffers do indicador
double         iVolumesBuffer[];
double         iVolumesColors[];

//--- variável para armazenar o manipulador do indicator iVolumes
int    handleVolume;

//--- nome do indicador num gráfico
string short_name_volume;



void InitVolume() {
  
  //--- atribuição de array para buffer do indicador
  SetIndexBuffer(0, iVolumesBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, iVolumesColors, INDICATOR_COLOR_INDEX);
  
  handleVolume = iVolumes(_Symbol, period, applied_volume);
  
  //--- se o manipulador não é criado
  if(handleVolume == INVALID_HANDLE) {
  
    //--- mensagem sobre a falha e a saída do código de erro
    PrintFormat(
      "Falha ao criar o manipulador do indicador iVolumes para o símbolo %s/%s, código de erro %d",
      _Symbol,
      EnumToString(period),
      GetLastError()
    );
  }
  
  //--- mostra que o símbolo/prazo do indicador Volumes é calculado para
  short_name_volume = StringFormat(
    "iVolumes(%s/%s, %s)",
    _Symbol,
    EnumToString(period),
    EnumToString(applied_volume)
  );
  
  IndicatorSetString(INDICATOR_SHORTNAME, short_name_volume);
}


bool CopyVolumeBuffer(
  int volumePeriods = 5
) {

  //--- redefinir o código de erro
  ResetLastError();
  
  CopyBuffer(handleVolume, 0, 0, volumePeriods, iVolumesBuffer);
  ArraySetAsSeries(iVolumesBuffer, true);
  
  CopyBuffer(handleVolume, 1, 0, volumePeriods, iVolumesColors);
  ArraySetAsSeries(iVolumesColors, true);
  
  return true;
}