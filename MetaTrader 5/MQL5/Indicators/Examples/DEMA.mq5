//+------------------------------------------------------------------+
//|                                                         DEMA.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Double Exponential Moving Average"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DarkBlue
#property indicator_width1  1
#property indicator_label1  "DEMA"
#property indicator_applied_price PRICE_CLOSE
//--- input parameters
input int InpPeriodEMA=14;   // EMA period
input int InpShift=0;        // Indicator's shift
//--- indicator buffers
double    DemaBuffer[];
double    Ema[];
double    EmaOfEma[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DemaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Ema,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,EmaOfEma,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2*InpPeriodEMA-2);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,InpShift);
//--- name of label
   string short_name=StringFormat("DEMA(%d)",InpPeriodEMA);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
  }
//+------------------------------------------------------------------+
//| Double Exponential Moving Average                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(rates_total<2*InpPeriodEMA-2)
      return(0);
//---
   int start;
   if(prev_calculated==0)
      start=0;
   else
      start=prev_calculated-1;
//--- calculate EMA
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpPeriodEMA,price,Ema);
//--- calculate EMA on EMA array
   ExponentialMAOnBuffer(rates_total,prev_calculated,InpPeriodEMA-1,InpPeriodEMA,Ema,EmaOfEma);
//--- calculate DEMA
   for(int i=start; i<rates_total && !IsStopped(); i++)
      DemaBuffer[i]=2.0*Ema[i]-EmaOfEma[i];
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
