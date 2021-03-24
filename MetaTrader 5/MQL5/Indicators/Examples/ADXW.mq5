//+------------------------------------------------------------------+
//|                                                         ADXW.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Average Directional Movement Index"
#property description "by Welles Wilder"
#include <MovingAverages.mqh>
//---
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_color1  LightSeaGreen
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
#property indicator_color2  YellowGreen
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
#property indicator_color3  Wheat
#property indicator_label1  "ADX Wilder"
#property indicator_label2  "+DI"
#property indicator_label3  "-DI"
//--- input parameters
input int InpPeriodADXW=14; // Period ADX
//--- indicator buffers
double    ExtADXWBuffer[];
double    ExtPDIBuffer[];
double    ExtNDIBuffer[];
double    ExtPDSBuffer[];
double    ExtNDSBuffer[];
double    ExtPDBuffer[];
double    ExtNDBuffer[];
double    ExtTRBuffer[];
double    ExtATRBuffer[];
double    ExtDXBuffer[];

int       ExtADXWPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input parameters
   if(InpPeriodADXW>=100 || InpPeriodADXW<=0)
     {
      ExtADXWPeriod=14;
      PrintFormat("Incorrect value for input variable InpPeriodADXW=%d. Indicator will use value=%d for calculations.",InpPeriodADXW,ExtADXWPeriod);
     }
   else
      ExtADXWPeriod=InpPeriodADXW;
//--- indicator buffers
   SetIndexBuffer(0,ExtADXWBuffer);
   SetIndexBuffer(1,ExtPDIBuffer);
   SetIndexBuffer(2,ExtNDIBuffer);
//--- calculation buffers
   SetIndexBuffer(3,ExtPDBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtNDBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtDXBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtTRBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,ExtATRBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,ExtPDSBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,ExtNDSBuffer,INDICATOR_CALCULATIONS);
//--- set draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtADXWPeriod<<1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,ExtADXWPeriod+1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,ExtADXWPeriod+1);
//--- indicator short name
   string short_name="ADX Wilder("+string(ExtADXWPeriod)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,2);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- checking for bars count
   if(rates_total<ExtADXWPeriod)
      return(0);
//--- detect start position
   int start;
   if(prev_calculated>1)
      start=prev_calculated-1;
   else
     {
      start=1;
      for(int i=0; i<ExtADXWPeriod; i++)
        {
         ExtADXWBuffer[i]=0;
         ExtPDIBuffer[i]=0;
         ExtNDIBuffer[i]=0;
         ExtPDSBuffer[i]=0;
         ExtNDSBuffer[i]=0;
         ExtPDBuffer[i]=0;
         ExtNDBuffer[i]=0;
         ExtTRBuffer[i]=0;
         ExtATRBuffer[i]=0;
         ExtDXBuffer[i]=0;
        }
     }
//--- main cycle
   for(int i=start; i<rates_total && !IsStopped(); i++)
     {
      //--- get some data
      double high_price=high[i];
      double prev_high =high[i-1];
      double low_price =low[i];
      double prev_low  =low[i-1];
      double prev_close=close[i-1];
      //--- fill main positive and main negative buffers
      double tmp_pos=high_price-prev_high;
      double tmp_neg=prev_low-low_price;
      if(tmp_pos<0.0)
         tmp_pos=0.0;
      if(tmp_neg<0.0)
         tmp_neg=0.0;
      if(tmp_neg==tmp_pos)
        {
         tmp_neg=0.0;
         tmp_pos=0.0;
        }
      else
        {
         if(tmp_pos<tmp_neg)
            tmp_pos=0.0;
         else
            tmp_neg=0.0;
        }
      ExtPDBuffer[i]=tmp_pos;
      ExtNDBuffer[i]=tmp_neg;
      //--- define TR
      double tr=MathMax(MathMax(MathAbs(high_price-low_price),MathAbs(high_price-prev_close)),MathAbs(low_price-prev_close));
      ExtTRBuffer[i]=tr; // write down TR to TR buffer
      //--- fill smoothed positive and negative buffers and TR buffer
      if(i<ExtADXWPeriod)
        {
         ExtATRBuffer[i]=0.0;
         ExtPDIBuffer[i]=0.0;
         ExtNDIBuffer[i]=0.0;
        }
      else
        {
         ExtATRBuffer[i]=SmoothedMA(i,ExtADXWPeriod,ExtATRBuffer[i-1],ExtTRBuffer);
         ExtPDSBuffer[i]=SmoothedMA(i,ExtADXWPeriod,ExtPDSBuffer[i-1],ExtPDBuffer);
         ExtNDSBuffer[i]=SmoothedMA(i,ExtADXWPeriod,ExtNDSBuffer[i-1],ExtNDBuffer);
        }
      //--- calculate PDI and NDI buffers
      if(ExtATRBuffer[i]!=0.0)
        {
         ExtPDIBuffer[i]=100.0*ExtPDSBuffer[i]/ExtATRBuffer[i];
         ExtNDIBuffer[i]=100.0*ExtNDSBuffer[i]/ExtATRBuffer[i];
        }
      else
        {
         ExtPDIBuffer[i]=0.0;
         ExtNDIBuffer[i]=0.0;
        }
      //--- Calculate DX buffer
      double dTmp=ExtPDIBuffer[i]+ExtNDIBuffer[i];
      if(dTmp!=0.0)
         dTmp=100.0*MathAbs((ExtPDIBuffer[i]-ExtNDIBuffer[i])/dTmp);
      else
         dTmp=0.0;
      ExtDXBuffer[i]=dTmp;
      //--- fill ADXW buffer as smoothed DX buffer
      ExtADXWBuffer[i]=SmoothedMA(i,ExtADXWPeriod,ExtADXWBuffer[i-1],ExtDXBuffer);
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
