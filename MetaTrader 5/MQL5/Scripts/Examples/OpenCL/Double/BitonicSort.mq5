//+------------------------------------------------------------------+
//|                                                  BitonicSort.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- COpenCL class
#include <OpenCL/OpenCL.mqh>
#resource "Kernels/bitonicsort.cl" as string cl_program
//+------------------------------------------------------------------+
//| QuickSortAscending                                               |
//+------------------------------------------------------------------+
//| The function sorts array[] QuickSort algorithm.                  |
//|                                                                  |
//| Arguments:                                                       |
//| array       : Array with values to sort                          |
//| first       : First element index                                |
//| last        : Last element index                                 |
//|                                                                  |
//| Return value: None                                               |
//+------------------------------------------------------------------+
void QuickSortAscending(double &array[],int first,int last)
  {
   int    i,j;
   double p_double,t_double;
   if(first<0 || last<0)
      return;
   i=first;
   j=last;
   while(i<last)
     {
      p_double=array[(first+last)>>1];
      while(i<j)
        {
         while(array[i]<p_double)
           {
            if(i==ArraySize(array)-1)
               break;
            i++;
           }
         while(array[j]>p_double)
           {
            if(j==0)
               break;
            j--;
           }
         if(i<=j)
           {
            //-- swap elements i and j
            t_double=array[i];
            array[i]=array[j];
            array[j]=t_double;
            i++;
            if(j==0)
               break;
            j--;
           }
        }
      if(first<j)
         QuickSortAscending(array,first,j);
      first=i;
      j=last;
     }
  }
//+------------------------------------------------------------------+
//| QuickSort_CPU                                                    |
//+------------------------------------------------------------------+
bool QuickSort_CPU(double &data_array[],ulong &time_cpu)
  {
   int data_count=ArraySize(data_array);
   if(data_count<=1)
      return(false);
//--- sort values on CPU
   time_cpu=GetMicrosecondCount();
   QuickSortAscending(data_array,0,data_count-1);
   time_cpu=ulong((GetMicrosecondCount()-time_cpu)/1000);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| BitonicSort_GPU                                                  |
//+------------------------------------------------------------------+
bool BitonicSort_GPU(COpenCL &OpenCL,double &data_array[],ulong &time_gpu)
  {
   int data_count=ArraySize(data_array);
   if(data_count<=1)
      return(false);
//--- check support working with double
   if(!OpenCL.SupportDouble())
     {
      PrintFormat("Working with double (cl_khr_fp64) is not supported on the device.");
      return(false);
     }
   OpenCL.SetKernelsCount(1);
   OpenCL.KernelCreate(0,"BitonicSort_GPU");
//--- create buffers
   OpenCL.SetBuffersCount(1);
   if(!OpenCL.BufferFromArray(0,data_array,0,data_count,CL_MEM_READ_WRITE))
     {
      PrintFormat("Error in BufferFromArray for data array. Error code=%d",GetLastError());
      return(false);
     }
   OpenCL.SetArgumentBuffer(0,0,0);
//---
   uint work_offset[1]={0};
   uint global_size[1];
   global_size[0]=data_count>>1;
//---
   uint passes_total=0;
   uint stages_total=0;
//---
   for(uint temp=data_count; temp>1; temp>>=1)
      stages_total++;
//--- GPU calculation start
   time_gpu=GetMicrosecondCount();
   for(uint stage=0; stage<stages_total; stage++)
     {
      //--- set stage of the algorithm
      OpenCL.SetArgument(0,1,stage);
      for(uint pass=0; pass<stage+1; pass++)
        {
         //--- set pass of the current stage
         OpenCL.SetArgument(0,2,pass);
         //--- execute kernel
         if(!OpenCL.Execute(0,1,work_offset,global_size))
           {
            PrintFormat("Error in Execute. Error code=%d",GetLastError());
            return(false);
           }
         else
            passes_total++;
        }
     }
//---
   if(!OpenCL.BufferRead(0,data_array,0,0,data_count))
     {
      PrintFormat("Error in BufferRead for data array C. Error code=%d",GetLastError());
      return(false);
     }
//--- GPU calculation finish
   time_gpu=ulong((GetMicrosecondCount()-time_gpu)/1000);
   PrintFormat("Bitonic sort finished. Total stages=%d, total passes=%d",stages_total,passes_total);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| PrepareDataArray                                                 |
//+------------------------------------------------------------------+
bool PrepareDataArray(long global_memory_size,double &data[],int &data_count)
  {
   int pwr_max=(int)(MathLog(global_memory_size/sizeof(float))/MathLog(2));
   int pwr=(int)MathMax(15,pwr_max-4);
   data_count=(int)MathPow(2,pwr);
//--- prepare array and generate random data
   if(ArrayResize(data,data_count)<data_count)
     {
      Print("Error in ArrayResize. Error code=",GetLastError());
      return(false);
     }
   for(int i=0; i<data_count; i++)
      data[i]=(double)(100000000*MathRand()/32767.0);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- OpenCL
   COpenCL OpenCL;
   if(!OpenCL.Initialize(cl_program,true))
     {
      PrintFormat("Error in OpenCL initialization. Error code=%d",GetLastError());
      return;
     }
   long global_memory_size=0;
   if(!OpenCL.GetGlobalMemorySize(global_memory_size))
     {
      Print("Error in request of global memory size. Error code=",GetLastError());
      return;
     }
   double data_cpu[];
   int data_count;
//--- prepare array with random values
   if(PrepareDataArray(global_memory_size,data_cpu,data_count)==false)
      return;
//--- copy array values for sorting on GPU
   double data_gpu[];
   if(ArrayCopy(data_gpu,data_cpu,0,0,data_count)!=data_count)
      return;
//--- Quick sort values using CPU
   ulong time_cpu=0;
   if(!QuickSort_CPU(data_cpu,time_cpu))
      return;
//--- Bitonic sort values using GPU
   ulong time_gpu=0;
   if(!BitonicSort_GPU(OpenCL,data_gpu,time_gpu))
      return;
//--- remove OpenCL objects
   OpenCL.Shutdown();
//--- calculate CPU/GPU ratio
   double CPU_GPU_ratio=0;
   if(time_gpu!=0)
      CPU_GPU_ratio=1.0*time_cpu/time_gpu;
   PrintFormat("time CPU=%d ms, time GPU =%d ms, CPU/GPU ratio: %f",time_cpu,time_gpu,CPU_GPU_ratio);
//--- check calculations
   double total_error=0;
   for(int i=0; i<data_count; i++)
     {
      total_error+=MathAbs(data_gpu[i]-data_cpu[i]);
     }
   PrintFormat("Total error = %f",total_error);
  }
//+------------------------------------------------------------------+
