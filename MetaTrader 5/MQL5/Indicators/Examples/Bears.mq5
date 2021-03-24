//+------------------------------------------------------------------+
//|                                                        Bears.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Bears Power"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Silver
#property indicator_width1  2
//--- input parameters
input int InpBearsPeriod=13; // Period
//--- indicator buffers
double    ExtBearsBuffer[];
double    ExtTempBuffer[];
//--- handle of EMA
int       ExtEmaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBearsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTempBuffer,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpBearsPeriod-1);
//--- name for DataWindow and indicator subwindow label
   string short_name=StringFormat("Bears(%d)",InpBearsPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- get MA handle
   ExtEmaHandle=iMA(_Symbol,_Period,InpBearsPeriod,0,MODE_EMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
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
   if(rates_total<InpBearsPeriod)
      return(0);
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtEmaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtEmaHandle is calculated (",calculated," bars). Error ",GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }
//--- get ma buffers
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(ExtEmaHandle,0,0,to_copy,ExtTempBuffer)<=0)
     {
      Print("getting ExtEmaHandle is failed! Error ",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   int start;
   if(prev_calculated<InpBearsPeriod)
      start=InpBearsPeriod;
   else
      start=prev_calculated-1;
//--- the main loop of calculations
   for(int i=start; i<rates_total && !IsStopped(); i++)
      ExtBearsBuffer[i]=low[i]-ExtTempBuffer[i];
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
