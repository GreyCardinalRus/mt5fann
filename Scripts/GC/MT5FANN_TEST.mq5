//+------------------------------------------------------------------+
//|                                                 MT5FANN_TEST.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\MT5FANN.mqh>
#include <GC\GetVectors.mqh>
#include <GC\CurrPairs.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   CMT5FANN mt5fann;
   mt5fann.debug=true;

   if(!mt5fann.Init("fx_eliot")) Print("Init error");
   mt5fann.ExportFANNDataWithTest(0,100,_Symbol);
   for (int i=0;i<100;i++)
   if(mt5fann.GetVector(i))
     {
      mt5fann.run();
      mt5fann.get_output();
      Print(_Symbol," ",mt5fann.OutputVector[0]);
      return;
     }
  }
//+------------------------------------------------------------------+
