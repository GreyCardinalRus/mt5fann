//+------------------------------------------------------------------+
//|                                                   GetVectors.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <GC\CommonFunctions.mqh>

///string VectorFunctions[21]={"DayOfWeek","Hour","Minute","Fractals","RSI","IMA","StochasticK","StochasticD","HL","High","Low","MACD","CCI","WPR","AMA","AO","Ichimoku","Envelopes","Chaikin","ROC"};
//string VectorFunctions[]={"DayOfWeek","Hour","Minute","OpenClose","OHLCClose","HighLow","ADX","ADXWilder","RSI","IMA","StochasticK","StochasticD","MACD","CCI","WPR","AMA","AO","Ichimoku","Envelopes","Chaikin","ROC","BearsPower","BullsPower"};
string BadVectorFunctions[]={"IMA","CCI","AO","Envelopes","BearsPower","BullsPower","Force"};

string VectorFunctions[]={"DayOfWeek","Hour","Minute","OpenClose","TriX","RVI","ATR","DeMarker","OsMA","Momentum","OHLCClose","HighLow","ADX","ADXWilder","RSI","StochasticK","StochasticD","MACD","WPR","AMA","Ichimoku","Chaikin","ROC"};
//string VectorFunctions[]={"DayOfWeek","Hour","Minute","OpenClose","OHLCClose","HighLow","StochasticK","StochasticD","WPR","IMA","MACD","AMA"};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ind_handles
  {
   string            hname;
   int               hid;
   double            ind_buffer0[];
   double            ind_buffer1[];
   double            ind_buffer2[];
   double            ind_buffer3[];
  }
;
ind_handles IndHandles[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVectorByName(string fn_name,string smbl,ENUM_TIMEFRAMES tf,int shift)
  {
//Print("Process=",fn_name);
   int param1=0,param2=0,param3=0,param4=0;
   int start_pos=0,sp_pos=0;
   int idx_ind=0;
   sp_pos=StringFind(fn_name,"_",start_pos);
   if(sp_pos>0)
     {
      start_pos=sp_pos+1;
      sp_pos=StringFind(fn_name,"_",start_pos);
      param1=(int)StringToInteger(StringSubstr(fn_name,start_pos,sp_pos-start_pos));
      if(sp_pos>0)
        {
         start_pos=sp_pos+1;
         sp_pos=StringFind(fn_name,"_",start_pos);
         param2=(int)StringToInteger(StringSubstr(fn_name,start_pos,sp_pos-start_pos));
         if(sp_pos>0)
           {
            start_pos=sp_pos+1;
            sp_pos=StringFind(fn_name,"_",start_pos);
            param3=(int)StringToInteger(StringSubstr(fn_name,start_pos,sp_pos-start_pos));
            if(sp_pos>0)
              {
               start_pos=sp_pos+1;
               sp_pos=StringFind(fn_name,"_",start_pos);
               param4=(int)StringToInteger(StringSubstr(fn_name,start_pos,sp_pos-start_pos));
              }
           }
        }
      sp_pos=StringFind(fn_name,"_");
      fn_name=StringSubstr(fn_name,0,sp_pos);
     }
   string sfn_name=fn_name+"_"+smbl+"_"+(string)tf+"_"+(string)param1+"_"+(string)param2+"_"+(string)param3+"_"+(string)param4;

   if("DayOfWeek"==fn_name || "Hour"==fn_name || "Minute"==fn_name)
     {
     }
   else
     {
      for(idx_ind=0;idx_ind<ArraySize(IndHandles);idx_ind++)
         if(IndHandles[idx_ind].hname==sfn_name) break;
      if(idx_ind==ArraySize(IndHandles))
        {
         ArrayResize(IndHandles,idx_ind+1);
         IndHandles[idx_ind].hname=sfn_name;
         IndHandles[idx_ind].hid=0;
         if(!ArraySetAsSeries(IndHandles[idx_ind].ind_buffer0,true)) return(-400);
         if(!ArraySetAsSeries(IndHandles[idx_ind].ind_buffer1,true)) return(-400);
         if(!ArraySetAsSeries(IndHandles[idx_ind].ind_buffer2,true)) return(-400);
         if(!ArraySetAsSeries(IndHandles[idx_ind].ind_buffer3,true)) return(-400);
        }
      else if(-1==shift)
        {
         return 0;
        }
     }
//if(ArrayBsearch(VectorFunctions,fn_name)  
//  return GetVectorByFname(fn_name,smbl,tf,shift,param1,param2,param3,param4);

   if("DayOfWeek"==fn_name) return GetVector_DayOfWeek(smbl,tf,shift);
   if("Hour"==fn_name) return GetVector_Hour(smbl,tf,shift);
   if("Minute"==fn_name) return GetVector_Minute(smbl,tf,shift);

   if("OpenClose"==fn_name) return GetVector_OpenClose(smbl,tf,shift,param1,param2,param3,param4);
   if("OHLCClose"==fn_name) return GetVector_OHLCClose(smbl,tf,shift,param1,param2,param3,param4);
   if("HighLow"==fn_name) return GetVector_HighLow(smbl,tf,shift,param1,param2,param3,param4);

   if("StochasticK"==fn_name) return GetVector_StochasticK(IndHandles[idx_ind],smbl,tf,shift,param1,param2,param3);
   if("StochasticD"==fn_name) return GetVector_StochasticD(IndHandles[idx_ind],smbl,tf,shift,param1,param2,param3);
   if("WPR"==fn_name) return GetVector_WPR(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("Momentum"==fn_name) return GetVector_Momentum(IndHandles[idx_ind],smbl,tf,shift,param1);

   if("OsMA"==fn_name) return GetVector_OsMA(IndHandles[idx_ind],smbl,tf,shift,param1,param2,param3);
   if("RSI"==fn_name) return GetVector_RSI(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("ATR"==fn_name) return GetVector_ATR(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("DeMarker"==fn_name) return GetVector_DeMarker(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("Force"==fn_name) return GetVector_Force(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("RVI"==fn_name) return GetVector_RVI(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("TriX"==fn_name) return GetVector_TriX(IndHandles[idx_ind],smbl,tf,shift,param1);
//
   if("ADXWilder"==fn_name) return GetVector_ADXWilder(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("ADX"==fn_name) return GetVector_ADX(IndHandles[idx_ind],smbl,tf,shift,param1);
   if("MACD"==fn_name) return GetVector_MACD(IndHandles[idx_ind],smbl,tf,shift,param1,param2,param3);
   if("AMA"==fn_name) return GetVector_AMA(IndHandles[idx_ind],smbl,tf,shift,param1,param2,param3,param4);
   if("Ichimoku"==fn_name) return GetVector_Ichimoku(IndHandles[idx_ind],smbl,tf,shift,param1,param2,param3);
   if("Envelopes"==fn_name) return GetVector_Envelopes(IndHandles[idx_ind],smbl,tf,shift,param1,param2);
   if("Chaikin"==fn_name) return GetVector_Chaikin(IndHandles[idx_ind],smbl,tf,shift,param1,param2);
   if("ROC"==fn_name) return GetVector_ROC(IndHandles[idx_ind],smbl,tf,shift);

//   if("IMA"==fn_name) return GetVector_IMA(IndHandles[idx_ind],smbl,tf,shift,param1);
//   if("CCI"==fn_name) return GetVector_CCI(IndHandles[idx_ind],smbl,tf,shift,param1);
//   if("BearsPower"==fn_name) return GetVector_BearsPower(IndHandles[idx_ind],smbl,tf,shift,param1);
//   if("BullsPower"==fn_name) return GetVector_BullsPower(IndHandles[idx_ind],smbl,tf,shift,param1);
//   if("AO"==fn_name) return GetVector_AO(IndHandles[idx_ind],smbl,tf,shift);

   Print("Not found fn='",fn_name,"'");
   return( -100);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_OpenClose(string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3,int param4)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==param1) param1=8;
   if(0==param2) param2=2;
   if(0==param3) param3=30;
   if(0==param4) param4=0;
   double Close[]; ArraySetAsSeries(Close,true);
//     double High[]; ArraySetAsSeries(High,true);
//     double Low[]; ArraySetAsSeries(Low,true);
   int Spreads[]; ArraySetAsSeries(Spreads,true);
//     datetime Time[]; ArraySetAsSeries(Time,true);
   int shift_history=param1;
   if(false
      //   ||((shift_history+3)>CopyHigh(smb,tf,shift+0,shift_history+3,High))
      || ((shift_history+3)>CopyClose(smb,tf,shift+0,shift_history+3,Close))
      //      || ((shift_history+3)>CopyLow(smb,tf,shift+0,shift_history+3,Low))
      //      || ((shift_history+3)>CopyTime(smb,tf,shift+0,shift_history+3,Time))
      || ((shift_history+3)>CopySpread(smb,tf,shift+0,shift_history+3,Spreads))
      || Spreads[shift_history]==0
      )
     {
      Print(smb," ",shift);
      return(-500);
     }
   double  SymbolSpread=SymbolInfoDouble(smb,SYMBOL_POINT)*Spreads[shift_history];//(SymbolInfoInteger(smb,SYMBOL_SPREAD));
   double  TS=SymbolSpread*_NumTS_;
   double  TP=SymbolSpread*_NumTP_;
//IndicatorRelease(h_ind);
   return tanh((Close[1]-Close[shift_history+2])/TS/5);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_HighLow(string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3,int param4)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==param1) param1=8;
   if(0==param2) param2=2;
   if(0==param3) param3=30;
   if(0==param4) param4=0;
//     double Close[]; ArraySetAsSeries(Close,true);
   double High[]; ArraySetAsSeries(High,true);
   double Low[]; ArraySetAsSeries(Low,true);
   int Spreads[]; ArraySetAsSeries(Spreads,true);
//     datetime Time[]; ArraySetAsSeries(Time,true);
   int shift_history=param1;
   if(false
      || ((shift_history+3)>CopyHigh(smb,tf,shift+0,shift_history+3,High))
      //    || ((shift_history+3)>CopyClose(smb,tf,shift+0,shift_history+3,Close))
      || ((shift_history+3)>CopyLow(smb,tf,shift+0,shift_history+3,Low))
      //      || ((shift_history+3)>CopyTime(smb,tf,shift+0,shift_history+3,Time))
      || ((shift_history+3)>CopySpread(smb,tf,shift+0,shift_history+3,Spreads))
      || Spreads[shift_history]==0
      )
     {
      Print(smb," ",shift);
      return(-500);
     }
   double  SymbolSpread=SymbolInfoDouble(smb,SYMBOL_POINT)*Spreads[shift_history];//(SymbolInfoInteger(smb,SYMBOL_SPREAD));
   double  TS=SymbolSpread*_NumTS_;
   double  TP=SymbolSpread*_NumTP_;
//IndicatorRelease(h_ind);
   return tanh(1-(High[1]-Low[1])/TS/5);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_OHLCClose(string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3,int param4)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==param1) param1=8;
   if(0==param2) param2=2;
   if(0==param3) param3=30;
   if(0==param4) param4=0;
   double Close[]; ArraySetAsSeries(Close,true);
   double High[]; ArraySetAsSeries(High,true);
   double Low[]; ArraySetAsSeries(Low,true);
   int Spreads[]; ArraySetAsSeries(Spreads,true);
//     datetime Time[]; ArraySetAsSeries(Time,true);
   int shift_history=param1;
   if(false
      || ((shift_history+3)>CopyHigh(smb,tf,shift+0,shift_history+3,High))
      || ((shift_history+3)>CopyClose(smb,tf,shift+0,shift_history+3,Close))
      || ((shift_history+3)>CopyLow(smb,tf,shift+0,shift_history+3,Low))
      //      || ((shift_history+3)>CopyTime(smb,tf,shift+0,shift_history+3,Time))
      || ((shift_history+3)>CopySpread(smb,tf,shift+0,shift_history+3,Spreads))
      || Spreads[shift_history]==0
      )
     {
      Print(smb," ",shift);
      return(-500);
     }
   double  SymbolSpread=SymbolInfoDouble(smb,SYMBOL_POINT)*Spreads[shift_history];//(SymbolInfoInteger(smb,SYMBOL_SPREAD));
   double  TS=SymbolSpread*_NumTS_;
   double  TP=SymbolSpread*_NumTP_;
//IndicatorRelease(h_ind);
   return tanh(((High[1]+Low[1]+Close[1])/3-Close[shift_history+2])/TS/30);

  }
//+------------------------------------------------------------------+
//| ��������������� �������                                          |
//+------------------------------------------------------------------+
double tanh(double x)
  {
   double x_=MathExp(x);
   double _x=MathExp(-x);
   if(0==(x_+_x)) return(0);
   if((x_-_x)/(x_+_x)>1) return(1);
   if((x_-_x)/(x_+_x)<-1) return(-1);
   return((x_-_x)/(x_+_x));
  }
//+------------------------------------------------------------------+
//| ������������� ������������� �������                                          |
//+------------------------------------------------------------------+


double Sigmoid(double x)// ���������� ������������� ������� ���������
  {
   return(1/(1+exp(-x)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVectors(double &InputVector[],string fn_names,string smbl,ENUM_TIMEFRAMES tf,int shift)
  {// ����, ������, �������� ����� (��� ���������� �������)
   double output_vector=0;
//if(__Debug__) Print("GV: "+fn_names);
// ������ ������� ���������...
   double Close[]; ArraySetAsSeries(Close,true);
   double High[]; ArraySetAsSeries(High,true);
   double Low[]; ArraySetAsSeries(Low,true);
   datetime Time[]; ArraySetAsSeries(Time,true);
   int RatioTP_SL=5;
   if(shift<0)
     {
      Print(shift);
      return -100;
     }
//�������� �������
   if(((1+3)>CopyHigh(smbl,tf,shift+1,1+3,High))
      || ((1+3)>CopyClose(smbl,tf,shift+1,1+3,Close))
      || ((1+3)>CopyLow(smbl,tf,shift+1,1+3,Low))
      || ((1+3)>CopyTime(smbl,tf,shift+1,1+3,Time))
      )
     {return(-2000);}
//  if((High[0+1]>High[0+0] && High[0+1]>High[0+2])
//     || (Low[0+1]<Low[0+0] && Low[0+1]<Low[0+2]))
//    {}
//  else return(-1000);
   int ni=0;
//if(shift<shift_history) shift_history=0;
   ArrayInitialize(InputVector,0);
// ������ ����� -���� �������      res=tanh(GetTrend(_TREND_,_Symbol,0,i,true)/15);
   if(shift>_TREND_>0) output_vector=GetTrend(smbl,tf,shift-_TREND_,false);
   if(StringLen(fn_names)<5) return output_vector;
// �������� ������...
   StringTrimRight(fn_names);StringTrimLeft(fn_names);
   int start_pos=0,end_pos=0,shift_pos=0,add_shift,sp_pos;
   end_pos=StringFind(fn_names," ",start_pos);
   do //while(end_pos>0)
     {
      add_shift=0;
      shift_pos= StringFind(fn_names,"-",start_pos);
      sp_pos=StringFind(fn_names," ",start_pos);
      if(-1<sp_pos&&sp_pos<shift_pos) shift_pos=-1;
      if(shift_pos>0 &&(shift_pos<end_pos || -1==end_pos))
        {
         add_shift=(int)StringToInteger(StringSubstr(fn_names,start_pos,shift_pos-start_pos));
         start_pos=shift_pos+1;
        }
      //      Print("-"+StringSubstr(fn_names,start_pos,end_pos-start_pos)+"-");
      string fn_name=StringSubstr(fn_names,start_pos,end_pos-start_pos);
      //if(0<=(shift+add_shift)) 
      double PRate=MathPow(10,(double)_Precision_);
      InputVector[ni++]=MathRound(PRate*GetVectorByName(fn_name,smbl,tf,shift+add_shift))/PRate;
      string ss=DoubleToString(InputVector[ni-1],5);
      if(InputVector[ni-1]>1.0 || InputVector[ni-1]<-1.0 || StringLen(ss)>10)
        {
         Print(fn_name,"(",shift,"+",add_shift,") return value : ",InputVector[ni-1]," ",Fun_Error(GetLastError()));

         return(-100);
        }
      start_pos=end_pos+1;    end_pos=StringFind(fn_names," ",start_pos);
     }
   while(start_pos>0);
   return output_vector;
  }
//+------------------------------------------------------------------+
//| QCP                                                                |
//+------------------------------------------------------------------+
double GetVector_ROC(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      ind_h.hid=iCustom(smb,tf,"GC\ROC");
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(5)) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]));

  }
//+------------------------------------------------------------------+
//|           ��� ������! ��������������!                                                      |
//+------------------------------------------------------------------+
double GetVector_ADX(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iADX(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;//BarsCalculated(ind_h.hid);

               //Sleep(5000);
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(3)) return(-200);
   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer1)<(3)) return(-200);
   if(CopyBuffer(ind_h.hid,2,shift,5,ind_h.ind_buffer2)<(3)) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer1[1])*0.005);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_TriX(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iTriX(smb,tf,param1,PRICE_WEIGHTED);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;//BarsCalculated(ind_h.hid);

               //Sleep(5000);
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(3)) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer0[2])*10000);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_RVI(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iRVI(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;//BarsCalculated(ind_h.hid);

               //Sleep(5000);
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(3)) return(-200);
   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer1)<(3)) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1])*0.005);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_Momentum(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iMomentum(smb,tf,param1,PRICE_WEIGHTED);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;//BarsCalculated(ind_h.hid);

               //Sleep(5000);
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(3)) return(-200);
//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer0[2])*0.01);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_Force(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iForce(smb,tf,param1,MODE_SMA,VOLUME_TICK);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;//BarsCalculated(ind_h.hid);

               //Sleep(5000);
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(3)) return(-200);
//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1])*100);

  }
//+------------------------------------------------------------------+
//|           ��� ������! ��������������!                                                      |
//+------------------------------------------------------------------+
double GetVector_ADXWilder(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iADXWilder(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(3)) return(-200);
   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer1)<(3)) return(-200);
   if(CopyBuffer(ind_h.hid,2,shift,5,ind_h.ind_buffer2)<(3)) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer1[1])*0.005);

  }
//+------------------------------------------------------------------+
//|  QCP                                                        |
//+------------------------------------------------------------------+
double GetVector_WPR(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=21;
      ind_h.hid=iWPR(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(5)) return(-200);

//IndicatorRelease(h_ind);
   return  tanh(2*(ind_h.ind_buffer0[1]/100+0.5));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_DeMarker(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=21;
      ind_h.hid=iDeMarker(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(5)) return(-200);

//IndicatorRelease(h_ind);
   return  tanh(2*(ind_h.ind_buffer0[1]/100+0.5));

  }
//+------------------------------------------------------------------+
//|  QCP                                                                |
//+------------------------------------------------------------------+
double GetVector_Chaikin(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=3;
      if(0==param2) param2=10;
      ind_h.hid=iChaikin(smb,tf,param1,param2,MODE_EMA,VOLUME_TICK);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(5)) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]/1000));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  QCP   ���� ��������������                                                          |
//+------------------------------------------------------------------+
double GetVector_AMA(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3,int param4)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=9;
      if(0==param2) param2=2;
      if(0==param3) param3=30;
      if(0==param4) param4=0;
      ind_h.hid=iAMA(smb,tf,param1,param2,param3,param4,PRICE_CLOSE);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<5) return(-200);

//IndicatorRelease(h_ind);
//double  SymbolSpread=SymbolInfoDouble(smb,SYMBOL_POINT)*Spreads[shift_history];//(SymbolInfoInteger(smb,SYMBOL_SPREAD));
   double  TS=0.001;//SymbolSpread*_NumTS_;

   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer0[2])/TS*1);

  }
//+------------------------------------------------------------------+
//| QCP - ���� ��������������                                                                 |
//+------------------------------------------------------------------+
double GetVector_AO(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      ind_h.hid=iAO(smb,tf);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<5) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer0[2])*100);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_OsMA(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=12;
      if(0==param2) param2=26;
      if(0==param3) param3=9;
      ind_h.hid=iOsMA(smb,tf,param1,param2,param3,PRICE_WEIGHTED);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<3) return(-200);
//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1])*1000);
  }
//+------------------------------------------------------------------+
//|  QCP -                                                            |
//+------------------------------------------------------------------+
double GetVector_Ichimoku(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=9;
      if(0==param2) param2=26;
      if(0==param3) param3=52;
      ind_h.hid=iIchimoku(smb,tf,param1,param2,param3);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<3) return(-200);
   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer1)<3) return(-200);
//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer1[1])*100);
  }
//+------------------------------------------------------------------+
//|  QCP -���� ��������������                                                                |
//+------------------------------------------------------------------+
double GetVector_Envelopes(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=28;
      if(0==param2) param2=0;
      ind_h.hid=iEnvelopes(smb,tf,param1,param2,MODE_SMA,PRICE_MEDIAN,0.1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<3) return(-200);
   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer1)<3) return(-200);

//IndicatorRelease(h_ind);

   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer1[1])*1000-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_IMA(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=6;
      ind_h.hid=iMA(smb,tf,param1,0,MODE_LWMA,PRICE_WEIGHTED);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<3) return(-200);
//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer0[2])*1000);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_MACD(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=12;
      if(0==param2) param2=26;
      if(0==param3) param3=9;
      ind_h.hid=iMACD(smb,tf,param1,param2,param3,PRICE_CLOSE);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<5) return(-200);
   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer1)<5) return(-200);

//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer1[1])*1000);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_BearsPower(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=13;
      ind_h.hid=iBearsPower(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }
   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<5) return(-200);

//IndicatorRelease(h_ind);
   return tanh(ind_h.ind_buffer0[0]*100);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_BullsPower(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=13;
      ind_h.hid=iBullsPower(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<5) return(-200);

//IndicatorRelease(h_ind);
   return tanh(ind_h.ind_buffer0[0]*100);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double GetVector_CCI(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iCCI(smb,tf,param1,PRICE_TYPICAL);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<5) return(-200);
//
//IndicatorRelease(h_ind);
   return (tanh((ind_h.ind_buffer0[1]-ind_h.ind_buffer0[2])*0.001));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double GetVector_DayOfWeek(string smb,ENUM_TIMEFRAMES tf,int shift)
  {
   datetime Time[]; ArraySetAsSeries(Time,true);
   CopyTime(smb,tf,shift,3,Time);
   MqlDateTime tm;

   TimeToStruct(Time[0],tm);
   return(((double)tm.day_of_week-3)/2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_Hour(string smb,ENUM_TIMEFRAMES tf,int shift)
  {
   datetime Time[]; ArraySetAsSeries(Time,true);
   CopyTime(smb,tf,shift,3,Time);
   MqlDateTime tm;

   TimeToStruct(Time[0],tm);
//if(__Debug__) return((double)tm.hour);
//else  
   return((double)(tm.hour-12)/12);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_Minute(string smb,ENUM_TIMEFRAMES tf,int shift)
  {
   datetime Time[]; ArraySetAsSeries(Time,true);
   CopyTime(smb,tf,shift,3,Time);
   MqlDateTime tm;

   TimeToStruct(Time[0],tm);
//if(__Debug__)return((double)tm.min);
//else  
   return((double)(tm.min-30)/30);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_StochasticK(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=5;
      if(0==param2) param2=3;
      if(0==param3) param3=3;
      ind_h.hid=iStochastic(smb,tf,param1,param2,param3,MODE_SMA,STO_LOWHIGH);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<(5)) return(-200);

//IndicatorRelease(h_ind);
   return tanh(2*(ind_h.ind_buffer0[1]/100-0.5));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_StochasticD(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1,int param2,int param3)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=5;
      if(0==param2) param2=3;
      if(0==param3) param3=3;

      ind_h.hid=iStochastic(smb,tf,param1,param2,param3,MODE_SMA,STO_LOWHIGH);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,1,shift,5,ind_h.ind_buffer0)<(5)) return(-200);

//IndicatorRelease(h_ind);
   return tanh(2*(ind_h.ind_buffer0[1]/100-0.5));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_RSI(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iRSI(smb,tf,param1,PRICE_CLOSE);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<3)return(-200);
//IndicatorRelease(h_ind);
   return tanh(2*(ind_h.ind_buffer0[1]/100-0.5));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetVector_ATR(ind_handles &ind_h,string smb,ENUM_TIMEFRAMES tf,int shift,int param1)
  {// ����, ������, �������� ����� (��� ���������� �������)
   if(0==ind_h.hid)
     {
      if(0==param1) param1=14;
      ind_h.hid=iATR(smb,tf,param1);
      if(ind_h.hid==INVALID_HANDLE) return(-500);//--- ���� ����� ����������
      return 0;
     }

   if(CopyBuffer(ind_h.hid,0,shift,5,ind_h.ind_buffer0)<3)return(-200);
//IndicatorRelease(h_ind);
   return tanh((ind_h.ind_buffer0[1]*800)-0.5);

  }
//+------------------------------------------------------------------+
//| ������� �������� ������� �� ��������                             |
//+------------------------------------------------------------------+
void DelTrash()
  {
   for(int i=ObjectsTotal(0);i>=0;i--)
      if(StringSubstr(ObjectName(0,i),0,3)=="GV_") ObjectDelete(0,ObjectName(0,i));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrend(string smb,ENUM_TIMEFRAMES tf,int shift,bool draw=false)
  {
   int shift_history=_TREND_;
   double mS=0,mB=0,S=0,B=0;
   double Close[]; ArraySetAsSeries(Close,true);
   double High[]; ArraySetAsSeries(High,true);
   double Low[]; ArraySetAsSeries(Low,true);
   int Spreads[]; ArraySetAsSeries(Spreads,true);
   datetime Time[]; ArraySetAsSeries(Time,true);
//  int RatioTP_SL=5;
// �������� �������

   if(((shift_history+3)>CopyHigh(smb,tf,shift+0,shift_history+3,High))
      || ((shift_history+3)>CopyClose(smb,tf,shift+0,shift_history+3,Close))
      || ((shift_history+3)>CopyLow(smb,tf,shift+0,shift_history+3,Low))
      || ((shift_history+3)>CopyTime(smb,tf,shift+0,shift_history+3,Time))
      || ((shift_history+3)>CopySpread(smb,tf,shift+0,shift_history+3,Spreads))
      )
     {
      Print(smb," ",shift);
      return(0);
     }
// ������ ������� ���������...
// ������ ���� 
//if((High[shift_history+1]>High[shift_history+0] && High[shift_history+1]>High[shift_history+2])
//   || (Low[shift_history+1]<Low[shift_history+0] && Low[shift_history+1]<Low[shift_history+2]))
//  {}
//else
//  {
//   //    return(0);
//  }
   double res=0;//,res1=0;
   int is,ib;
   double  SymbolSpread=SymbolInfoDouble(smb,SYMBOL_POINT)*Spreads[shift_history];//(SymbolInfoInteger(smb,SYMBOL_SPREAD));
   double  TS=SymbolSpread*_NumTS_;
   double  TP=SymbolSpread*_NumTP_;

   if(0==SymbolSpread) return(0);
   bool mayBeSell=true,mayBeBuy=true,closeSell=false,closeBuy=false;
// ���� ������ 
//   if((High[shift_history+1]>High[shift_history] && High[shift_history+1]>High[shift_history+2]) 
//|| (Low[shift_history+1]<Low[shift_history] && Low[shift_history+1]<Low[shift_history+2]))
     {
      shift_history++;
      S=Close[shift_history]-SymbolSpread; B=Close[shift_history]+SymbolSpread;
      is=ib=shift_history;
      if(TS>0.00001)
        {
         //if(Close[shift_history]<Close[shift_history-1]) mS=Close[shift_history]-S;
         //if(Close[shift_history]>Close[shift_history-1]) mB=Close[shift_history]-B;
         for(int i=shift_history-1;i>1;i--)
           {
            if(!closeBuy && !closeSell)
              {
               if((Close[shift_history]<(High[i]-1*TS))) closeSell=true;
               if((Close[shift_history]>(Low[i]+1*TS))) closeBuy=true;
              }

            if(mayBeSell)//&& !closeSell)
              {
               if(S>(Low[i]+TS))// || S<(High[i]-TS))
                 {
                  S=Low[i]+TS; is=i;
                 }
               if((S+TP<=High[i])//((Close[shift_history]-SymbolSpread)<=(Close[i]-SymbolSpread))
                  || (Close[shift_history]<Close[i])
                  || (High[shift_history]<High[i])
                  )//&& (shift_history-1)<_Expiration_)
                 {
                  //if(((Close[shift_history]-SymbolSpread))-S>TS) break;
                  mayBeSell=false;

                 }
              }
            if(mayBeBuy)//&& !closeBuy)
              {
               if(B<(High[i]-TS))// || B>(Low[i]+TS))
                 {
                  ib=i; B=(High[i]-TS);//mB=B-Close[shift_history];                               //B=0;
                 }
               if((B-TP>=Low[i])
                  || (Close[shift_history]>Close[i])
                  || (Low[shift_history]>Low[i])
                  )//&& (shift_history-i)<_Expiration_))
                 {
                  //if(B-((Close[shift_history]+SymbolSpread))>_NumTP_*SymbolSpread) break;
                  mayBeBuy=false;
                 }
              }
           }
         //if(mayBeBuy) 
         mB=B-((Close[shift_history])); if(mB<TP || shift_history-ib<4) mB=0;
         //if(mayBeSell) 
         mS=((Close[shift_history]))-S; if(mS<TP || shift_history-is<4) mS=0;
         if(mS>mB)
           {
            //if(Close[shift_history]<Close[shift_history-1]) return(0);
            res=-mS;if(draw)ObjectCreate(0,"GV_S_"+(string)shift+"_"+(string)(int)(mS/(SymbolInfoInteger(smb,SYMBOL_TRADE_STOPS_LEVEL)*SymbolInfoDouble(smb,SYMBOL_POINT))/_NumTS_),OBJ_ARROWED_LINE,0,Time[shift_history-1],Close[shift_history]-SymbolSpread,Time[is],S);
           }
         else if(mS<mB)
           {
            //if(Close[shift_history]>Close[shift_history-1]) return(0);
            res=mB;if(draw)ObjectCreate(0,"GV_B_"+(string)shift+"_"+(string)(int)(mB/(SymbolInfoInteger(smb,SYMBOL_TRADE_STOPS_LEVEL)*SymbolInfoDouble(smb,SYMBOL_POINT))/_NumTS_),OBJ_ARROWED_LINE,0,Time[shift_history-1],Close[shift_history]+SymbolSpread,Time[ib],B);
           }
         //Print(res+"/"+(TS));
         //         res=_NumTS_*res/TS;
         res=tanh(res/(_NumTP_*SymbolSpread));
         // ������ ����
         if(res>0.5)
           {

           }
         else if(res<-0.5)
           {
           }
         else
           {
            if(closeSell&&!closeBuy) res=0.5;
            if(closeBuy&&!closeSell) res=-0.5;
           }

        }
      else
        {
         Print(smb+" SYMBOL_TRADE_STOPS_LEVEL="+(string)SymbolInfoInteger(smb,SYMBOL_TRADE_STOPS_LEVEL)+" SYMBOL_POINT="+(string)SymbolInfoDouble(smb,SYMBOL_POINT));
         res=0;
        }
     }

   return(res);

  }
//+------------------------------------------------------------------+
//| ������������� �������                                            |
//+------------------------------------------------------------------+
void InNormalize(double &aa[],int typ=1)
  {
   double sum_sqrt,rmax,rmin;
   int i,n=ArraySize(aa);
//---
   switch(typ)
     {
      case 1:
         rmax=aa[ArrayMaximum(aa)];
         rmin=aa[ArrayMinimum(aa)];
         for(i=0;i<=n-1;i++)
           {
            aa[i]=2*(aa[i]-rmin)/(rmax-rmin)-1;
           }
         break;
      case 2:
         sum_sqrt=0;
         for(i=0; i<=n-1; i++)
           {
            sum_sqrt+=MathPow(aa[i],2);
           }
         sum_sqrt=MathSqrt(sum_sqrt);
         //---
         if(sum_sqrt!=0)
           {
            for(i=0; i<=n-1; i++)
              {
               aa[i]=aa[i]/sum_sqrt;
              }
           }
         break;
      case 3:
         for(i=0; i<=n-1; i++)
           {
            aa[i]=tanh(aa[i]);
           }
         break;
      case 4:
         for(i=0; i<=n-1; i++)
           {
            aa[i]=Sigmoid(aa[i]);
           }
         break;

      default: break;
     }

//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//| ��������������� �������� ��������                                              |
//| aa[]  - �������� ������ ���������� ������������        |
//| scale - ��������� ������������                                                                      |
//|              +1 -1 ->>  scale=11;   +1  0  ->> scale==10              |
//| Return - 0 � ���������������� ������, � ������ ������|
//|                     ��� ��� ���������  ������                                                          |
//+------------------------------------------------------------------+
int GetScale(int scale,double &aa[])
  {
   int sign=0;
   int I,i=0,Err=0;
//double range;
   double sum[],nn[];

   double rmax=aa[ArrayMaximum(aa)];
   double rmin=aa[ArrayMinimum(aa)];


   if(rmax>0 && rmin>=0) sign= 1;
   if(rmin<0 && rmax<=0) sign=-1;

   I=ArraySize(aa);
   ArrayResize(sum,I);
   ArrayResize(nn,I);
   if(scale==11) // �������� � +1 -1 
     {
      if(sign==0) // ��� �������� � �������������� � �������������� ����������
        {
         for(i=0;i<=I-1;i++)
           {
            if(aa[i]>=0) {sum[i]=aa[i]; nn[i]=1;}  else {sum[i]=-aa[i]; nn[i]=-1;}
           }
         Scale01(sum);

         for(i=0;i<=I-1;i++)
           {
            if(nn[i]== 1) aa[i]= sum[i];
            if(nn[i]==-1) aa[i]=-sum[i];
           }
        }
      else                   // ��� �������� ������ � �������������� ��� �������������� ����������
        {
         if(sign==-1) for(i=0;i<=I-1;i++) aa[i]=-aa[i];// invert sign
         Scale11(aa);
         if(sign==-1) aa[i]=-aa[i];// recover sign
        }
      Err=err();
      return(Err);
     }
   if(scale==10) // �������� � 0 +1 
     {
      if(sign==0) // ��� �������� � �������������� � �������������� ����������
        {
         for(i=0;i<=I-1;i++)
           {
            if(aa[i]>=0) {sum[i]=aa[i]; nn[i]=1;}  else {sum[i]=-aa[i]; nn[i]=-1;}
           }
         Scale01(sum);

         for(i=0;i<=I-1;i++)
           {
            if(nn[i]== 1) aa[i]= (sum[i]+1)/2;
            if(nn[i]==-1) aa[i]=(-sum[i]+1)/2;
           }
        }
      else                   // ��� �������� ������ � �������������� ��� �������������� ����������
        {
         if(sign==1) Scale01(aa);
         else
           {
            for(i=0;i<=I-1;i++) aa[i]=-aa[i];// invert sign
            Scale01(aa);
            aa[i]=-aa[i];// recover sign
           }
        }
      Err=err();
      return(Err);

     }
   return(Err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------+
//| ��������������� �������� �������� > 0 �������� � ��������� +1 -1 |
//+-------------------------------------------------------------------------------------+
void Scale11(double &aa[])
  {
   int I=ArraySize(aa);
   double rmax=aa[ArrayMaximum(aa)];
   double rmin=aa[ArrayMinimum(aa)];
   double range=(rmax-rmin);
   if( range==0 ) range=0.5;
   for(int i=0;i<=I-1;i++)
     {
      aa[i]=2*(aa[i]-rmin)/range-1;
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------+
//| ��������������� �������� �������� > 0 �������� � ��������� +1  0 |
//+-------------------------------------------------------------------------------------+
void Scale01(double &aa[])
  {
   int I=ArraySize(aa);
   double rmax=aa[ArrayMaximum(aa)];
   double rmin=aa[ArrayMinimum(aa)];
   double range=rmax-rmin;
   for(int i=0;i<=I-1;i++)
     {
      if( range!=0 ) aa[i]=(aa[i]-rmin)/range;
      else aa[i]=0;
     }
   return;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|       ��������� ������                                                                                                |
//+------------------------------------------------------------------+
int err()
  {
   int err=GetLastError();
   if(err!=0)
     {
      Print("error(",err,"): ");///,ErrorDescription(err));
     }
   return(err);
  }
//+------------------------------------------------------------------+
