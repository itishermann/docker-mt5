//+------------------------------------------------------------------+
//|                                                     Momentum.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2020, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
//--- input parameters
input int InpMomentumPeriod=14; // Period
//--- indicator buffer
double    ExtMomentumBuffer[];

int       ExtMomentumPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpMomentumPeriod<0)
     {
      ExtMomentumPeriod=14;
      Print("Input parameter InpMomentumPeriod has wrong value. Indicator will use value ",ExtMomentumPeriod);
     }
   else
      ExtMomentumPeriod=InpMomentumPeriod;
//--- buffers
   SetIndexBuffer(0,ExtMomentumBuffer,INDICATOR_DATA);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum("+string(ExtMomentumPeriod)+")");
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtMomentumPeriod-1);
//--- sets drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- digits
   IndicatorSetInteger(INDICATOR_DIGITS,2);
  }
//+------------------------------------------------------------------+
//|  Momentum                                                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int start_position=(ExtMomentumPeriod-1)+begin;
   if(rates_total<start_position)
      return(0);
//--- correct draw begin
   if(prev_calculated==0 && begin>0)
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start_position+(ExtMomentumPeriod-1));
//--- start working, detect position
   int pos=prev_calculated-1;
   if(pos<start_position)
      pos=begin+ExtMomentumPeriod;
//--- main cycle
   for(int i=pos; i<rates_total && !IsStopped(); i++)
      ExtMomentumBuffer[i]=price[i]*100/price[i-ExtMomentumPeriod];
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
