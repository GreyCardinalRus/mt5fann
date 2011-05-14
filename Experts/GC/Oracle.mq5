//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2010, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>
#include <GC\CommonFunctions.mqh>
//COracleTemplate *Oracles[];
int nOracles;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(AllOracles,20);
   nOracles=0;//AllOracles();
   AllOracles[nOracles++]=new COracleTemplate;
   AllOracles[0].Init();
   AllOracles[0].ExportHistoryENCOG("","",100,0,0);
   //for(int i=0;i<nOracles;i++) Print(AllOracles[i].Name()," Ready!");
   double            InputVector[];ArrayResize(InputVector,20);
   GetVectors(InputVector,AllOracles[0].inputSignals,_Symbol,0,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0;i<nOracles;i++) delete AllOracles[i];
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   return;
   if(_TrailingPosition_) Trailing();
   int io;
   double   res=0;
   for(io=0;io<nOracles;io++)
     {
      res+=AllOracles[io].forecast(_Symbol,0,false);
     }
   NewOrder(_Symbol,res,"");
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // ������������� �������  
                  const long& lparam,   // �������� ������� ���� long
                  const double& dparam, // �������� ������� ���� double
                  const string& sparam  // �������� ������� ���� string
                  )
  {
//if(id==(int)CHARTEVENT_CLICK)
//  {
//   Print("���������� ������ ����� �� �������: x=",lparam,"  y=",dparam);
//  };
   if(id==(int)CHARTEVENT_OBJECT_CLICK)
     {
      datetime dt=(datetime)ObjectGetInteger(0,sparam,OBJPROP_TIME);
      //Print("���������� ������ ����� �� �������: x=",lparam,"  y=",dparam," ",sparam," ",dt);
      int io;
      double   res=0,tres=0;
      Print("For ",dt);
      for(io=0;io<nOracles;io++)
        {
         res=AllOracles[io].forecast(Symbol(),dt,false);
         tres+=res;
         if(0!=res) Print(AllOracles[io].Name()," ",res);
        }

     };

  }
//+------------------------------------------------------------------+
