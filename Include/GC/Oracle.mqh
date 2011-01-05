//+------------------------------------------------------------------+
//|                                                       Oracle.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <GC\GetVectors.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleEasy
  {
private:
public:
                     COracleEasy(){Init();};
                    ~COracleEasy(){DeInit();};
   virtual void              Init(){};
   virtual void              DeInit(){};
   virtual double    forecast(string smbl="",int shift=0,bool train=false){return(0.0);};
   virtual string    Name(){return("Prpototype");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiMA:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iMA");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiMA::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   int   h_ind1=iMA(smbl,PERIOD_M1,8,0,MODE_SMA,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
   int   h_ind2=iMA(smbl,PERIOD_M1,16,0,MODE_SMA,PRICE_CLOSE);
   if(CopyBuffer(h_ind2,0,0,2,ind2_buffer)<2) return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))return(0);

//--- �������� �������� ������� � ������������� �������� ��� sig
   if(ind1_buffer[2]<ind2_buffer[1] && ind1_buffer[1]>ind2_buffer[1])
      sig=1;
   else if(ind1_buffer[2]>ind2_buffer[1] && ind1_buffer[1]<ind2_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);   IndicatorRelease(h_ind2);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
class CiMACD:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iMACD");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiMACD::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];double ind2_buffer[];
   int   h_ind1=iMACD(smbl,PERIOD_M1,12,26,9,PRICE_CLOSE);

   if(CopyBuffer(h_ind1,0,shift,2,ind1_buffer)<2) return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);

//--- �������� �������� ������� � ������������� �������� ��� sig
   if(ind2_buffer[2]>ind1_buffer[1] && ind2_buffer[1]<ind1_buffer[1])
      sig=1;
   else if(ind2_buffer[2]<ind1_buffer[1] && ind2_buffer[1]>ind1_buffer[1])
      sig=-1;
   else sig=0;

   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
class CPriceChanel:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("Price Chanel");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPriceChanel::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iCustom(smbl,PERIOD_M1,"Price Channel",22);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(CopyClose(Symbol(),Period(),0,2,Close)<2) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);

//--- �������� �������� ������� � ������������� �������� ��� sig
   if(Close[1]>ind1_buffer[2])
      sig=1;
   else if(Close[1]<ind2_buffer[2])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
class CiStochastic:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iStochastic");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiStochastic::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iStochastic(smbl,PERIOD_M1,5,3,3,MODE_SMA,STO_LOWHIGH);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<20 && ind1_buffer[1]>20)
      sig=1;
   else if(ind1_buffer[2]>80 && ind1_buffer[1]<80)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiRSI:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iRSI");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiRSI::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iRSI(smbl,PERIOD_M1,14,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<30 && ind1_buffer[1]>30)
      sig=1;
   else if(ind1_buffer[2]>70 && ind1_buffer[1]<70)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiCGI:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iCGI");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiCGI::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iCCI(smbl,PERIOD_M1,14,PRICE_TYPICAL);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<-100 && ind1_buffer[1]>-100)
      sig=1;
   else if(ind1_buffer[2]>100 && ind1_buffer[1]<100)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiWPR:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iWPR");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiWPR::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iWPR(smbl,PERIOD_M1,14);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<-80 && ind1_buffer[1]>-80)
      sig=1;
   else if(ind1_buffer[2]>-20 && ind1_buffer[1]<-20)
      sig=-1;

   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiBands:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iBands");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiBands::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iBands(smbl,PERIOD_M1,20,0,2,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);
   if(Close[2]<=ind2_buffer[1] && Close[1]>ind2_buffer[1])
      sig=1;
   else if(Close[2]>=ind1_buffer[1] && Close[1]<ind1_buffer[1])
                     sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNRTR:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("NRTR");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CNRTR::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];

   int   h_ind1=iCustom(smbl,PERIOD_M1,"NRTR",40,2.0);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);

   if(ind1_buffer[1]>0) sig=1;
   else if(ind2_buffer[1]>0) sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiAlligator:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iAlligator");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAlligator::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double ind3_buffer[];
   int   h_ind1=iAlligator(smbl,PERIOD_M1,13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,2,shift,3,ind3_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind3_buffer,true))         return(0);

   if(ind3_buffer[1]>ind2_buffer[1] && ind2_buffer[1]>ind1_buffer[1])
      sig=1;
   else if(ind3_buffer[1]<ind2_buffer[1] && ind2_buffer[1]<ind1_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiAMA:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iAMA");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAMA::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iAMA(smbl,PERIOD_M1,9,2,30,0,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<ind1_buffer[1])
      sig=1;
   else if(ind1_buffer[2]>ind1_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiAO:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iAO");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAO::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iAO(smbl,PERIOD_M1);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[1]==0)
      sig=1;
   else if(ind1_buffer[1]==1)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiIchimoku:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iIchimoku");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiIchimoku::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   int   h_ind1=iIchimoku(smbl,PERIOD_M1,9,26,52);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind2_buffer,true)) return(0);

   if(ind1_buffer[1]>ind2_buffer[1])
      sig=1;
   else if(ind1_buffer[1]<ind2_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiEnvelopes:public COracleEasy
  {
   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   virtual string    Name(){return("iEnvelopes");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiEnvelopes::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iEnvelopes(smbl,PERIOD_M1,28,0,MODE_SMA,PRICE_CLOSE,0.1);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);

   if(Close[2]<=ind2_buffer[1] && Close[1]>ind2_buffer[1])
      sig=1;
   else if(Close[2]>=ind1_buffer[1] && Close[1]<ind1_buffer[1])
                     sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- ���������� �������� ������
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleANN:public COracleEasy
  {
private:
   string            Symbol;
   string            Functions_Array[10];
   int               Functions_Count[10];
   //int               Max_Functions;
   ENUM_TIMEFRAMES   TimeFrame;
   string            File_Name;
   bool              WithNews;
   bool              WithHours;
   bool              WithDayOfWeek;

public:
   bool              ClearTraning;
   double            InputVector[];
   double            OutputVector[];
                     COracleANN(){Init();}
                    ~COracleANN(){DeInit();}
   bool              GetVector(string smbl="",int shift=0,bool train=false);
   bool              debug;
   virtual void      Init();
   //   virtual void              DeInit();
   //   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   bool              Load(string file_name);
   bool              Save(string file_name="");
   virtual bool      CustomLoad(int file_handle){return(false);};
   virtual bool      CustomSave(int file_handle){return(false);};
   virtual bool      Draw(int window,datetime &time[],int w,int h){return(true);};
   int               num_input();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool COracleANN::GetVector(string smbl="",int shift=0,bool train=false)
  {// ����, ������, �������� ����� (��� ���������� �������)
   double IB[],OB[];
   ArrayResize(IB,num_input()+2);
   ArrayResize(OB,1+2);
   ArrayResize(InputVector,num_input());
   ArrayResize(OutputVector,3);
   int FunctionsIdx;
   int n_vectors=num_input();
   int n_o_vectors=1;
   int pos_in=0,pos_out=0,i;
   if(""==smbl) smbl=_Symbol;
   if(WithHours || WithDayOfWeek)
     {
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      MqlDateTime tm;
      CopyRates(smbl,PERIOD_M1,shift,3,rates);
      TimeToStruct(rates[1].time,tm);
      if(WithDayOfWeek) InputVector[pos_in++]=((double)tm.day_of_week/7);
      if(WithDayOfWeek) InputVector[pos_in++]=((double)tm.hour/24);
     }
   if(!train)n_o_vectors=0;

   n_vectors=(n_vectors-pos_in);
   for(FunctionsIdx=0; FunctionsIdx<10;FunctionsIdx++)
     {
      if(GetVectors(IB,OB,Functions_Count[FunctionsIdx],n_o_vectors,Functions_Array[FunctionsIdx],smbl,PERIOD_M1,shift))
        {
         // �������� � ������ �����������
         double si=1;
         //            for(i=0;i<n_vectors;i++) si+=IB[i]*IB[i]; si=MathSqrt(si);
         for(i=0;i<Functions_Count[FunctionsIdx];i++) InputVector[pos_in++]=IB[i]/si;

         // for(i=0;i<n_o_vectors;i++)
         //   {
         //    OutputVector[i]=OB[i];
         //    if(OB[i]<-3) OutputVector[i]=-0.5;
         //    if(OB[i]>3) OutputVector[i]=0.5;
         //    //OutputVector[i]=1*(1/(1+MathExp(-1*OB[i]/5))-0.5);
         //   }
        }
     }
   if(GetVectors(IB,OB,0,n_o_vectors,"",smbl,PERIOD_M1,shift))
     {
      for(i=0;i<n_o_vectors;i++)
        {
         OutputVector[i]=OB[i];
         //if(OB[i]<-3) OutputVector[i]=-0.5;
         //if(OB[i]>3) OutputVector[i]=0.5;
         //OutputVector[i]=1*(1/(1+MathExp(-1*OB[i]/5))-0.5);
        }

     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COracleANN::num_input(void)
  {
   int ret=0;
   for(int i=0;i<10;i++) ret+=Functions_Count[i];
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleANN::Save(string file_name)
  {
   if(""==file_name) file_name=File_Name;
   int file_handle;  string outstr="";

   file_handle=FileOpen(file_name+".gc_oracle",FILE_WRITE|FILE_ANSI|FILE_TXT,"= ");
// ������� ���������
   if(file_handle!=INVALID_HANDLE)
     {
      FileWriteString(file_handle,"[Common]\n");
      FileWriteString(file_handle,"LastStart="+(string)TimeCurrent()+"\n");

      FileWriteString(file_handle,"[FunctionsArray]\n");
      int i;
      i=0;
      while(Functions_Array[i]!="")
        {
         FileWriteString(file_handle,Functions_Array[i]+"="+(string)Functions_Count[i]+"\n");
         i++;
        }
      FileWriteString(file_handle,"[Custom]\n");
      CustomSave(file_handle);
      FileClose(file_handle);
      return(true);
     }
   else return(false);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleANN::Load(string file_name)
  {
   int file_handle;  string outstr="";   int i=0,sp;
   File_Name=file_name;
   file_handle=FileOpen(file_name+".gc_oracle",FILE_READ|FILE_ANSI|FILE_TXT,"= ");
   if(file_handle!=INVALID_HANDLE)
     {
      outstr=FileReadString(file_handle);//   [Common]
      outstr=FileReadString(file_handle);//   LastStart
      while(outstr!="[FunctionsArray]"){outstr=FileReadString(file_handle);}
      outstr=FileReadString(file_handle);
      while(outstr!="[Custom]")
        {
         sp=1+StringFind(outstr,"=");
         for(i=0;i<10;i++)
           {
            if(Functions_Array[i]==StringSubstr(outstr,0,sp-1)) Functions_Count[i]=(int)StringToInteger(StringSubstr(outstr,sp));;
           }
         outstr=FileReadString(file_handle);
        }
      CustomLoad(file_handle);
      FileClose(file_handle);
      return(true);
     }
   else return(false);
  };
//+------------------------------------------------------------------+
void COracleANN::Init()
  {
   ClearTraning=false;
   debug=false;
   WithNews = false;
   WithHours= false;
   WithDayOfWeek=false;
   int i;
   for(i=0;i<10;i++)
     {
      Functions_Array[i]=VectorFunctions[i];
      Functions_Count[i]=0;
     }
   TimeFrame=_Period;
  }
//+------------------------------------------------------------------+
