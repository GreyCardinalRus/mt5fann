//+------------------------------------------------------------------+
//|                                                          GNG.mq5 |
//|                                             Copyright 2010, alsu |
//|                                                 alsufx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alsu"
#property link      "alsufx@gmail.com"
#property version   "1.00"
#property script_show_inputs

#include <GNG/GNG.mqh>
#include <GC\GetVectors.mqh>

//--- ���������� ������� ��������, ������������ ��� ��������
input int      samples=1000;
input string AlgoStr="Easy";
//--- ��������� ���������
input int lambda=20;
input int age_max=30;
input int ages=5;
input double alpha=0.5;
input double beta=0.0005;
input double eps_w=0.05;
input double eps_n=0.0006;
input int max_nodes=1000;
input double max_E=0.1;
//double OV[];
//---���������� ����������
CGNGUAlgorithm *GNGAlgorithm;
//CGNGAlgorithm *GNGAlgorithm;
int window;
//int rsi_handle;
int input_dimension;
int _samples;
//double RSI_buffer[];
datetime time[];
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int i,j;
   window=ChartWindowFind(0,"GNG_dummy");
   input_dimension=2;

//--- ����� ������� CopyBuffer() �������� ���������, ���������� �������� 
//--- ������ ������������ � ���������� ����� � ������� �� ����� ������� 
   _samples=samples+input_dimension*10;
   if(_samples>Bars(_Symbol,_Period)) _samples=Bars(_Symbol,_Period);

////--- ���������� �������� ������������� ��������
   _samples=_samples-input_dimension*10;

//--- ���������� ������� �������� ������ 100 �����
   CopyTime(_Symbol,_Period,0,1000,time);

//--- ������� ��������� ��������� � ���������� ����������� ������� ������
   GNGAlgorithm=new CGNGUAlgorithm;
//   GNGAlgorithm=new CGNGAlgorithm;

//--- ������� ������
   double v[],v1[],v2[],ov[];
    ArrayResize(ov,1);
 ArrayResize(v,input_dimension);
   ArrayResize(v1,input_dimension);
   ArrayResize(v2,input_dimension);i=2;
   while(!GetVectors(v1,ov,input_dimension,1,AlgoStr,_Symbol,PERIOD_M1,i++));
   while(!GetVectors(v2,ov,input_dimension,1,AlgoStr,_Symbol,PERIOD_M1,++i));

//--- ������������� ���������
   GNGAlgorithm.Init(input_dimension,v1,v2,lambda,age_max,alpha,beta,eps_w,eps_n,max_nodes,max_E);
   if(window>0)
     {
      //-- ������ ������������� ���� � �������������� �����
      ObjectCreate(0,"GNG_rect",OBJ_RECTANGLE,window,time[0],0,time[999],100);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_BACK,true);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_COLOR,DarkGray);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_BGCOLOR,DarkGray);

      ObjectCreate(0,"Label_samples",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_samples",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_samples",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_samples",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_samples",OBJPROP_YDISTANCE,10);
      ObjectSetInteger(0,"Label_samples",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_samples",OBJPROP_TEXT,"Total samples: 2");

      ObjectCreate(0,"Label_neurons",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_YDISTANCE,25);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_neurons",OBJPROP_TEXT,"Total neurons: 2");

      ObjectCreate(0,"Label_age",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_age",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_age",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_age",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_age",OBJPROP_YDISTANCE,40);
      ObjectSetInteger(0,"Label_age",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_age",OBJPROP_TEXT,"Age: 0");
     }
//--- ������� ���� �������� �������� � i=2 �.�. 2 ������ ��� ������������
   for(int ma=0;ma<ages;ma++)
     {
      //if(window>0)ObjectSetString(0,"Label_age",OBJPROP_TEXT,"Age: "+(string)ma+"  ME="+(string)GNGAlgorithm.maximun_E);
      for(i=1;i<samples;i++)
        {
        if(window>0)ObjectSetString(0,"Label_age",OBJPROP_TEXT,"Age: "+(string)ma+"  ME="+(string)GNGAlgorithm.maximun_E);
        //--- ��������� ������ ������ (��� ����������� ����� �������, ���������
         //--- �� 3 ���� - ��� ������ ��������������)
         if(!GetVectors(v,ov,input_dimension,1,AlgoStr,_Symbol,PERIOD_M1,i)) continue;
         //              {
         //     for(j=0;j<input_dimension;j++)
         //       v[j]=RSI_buffer[i+j*3];

         if(window>0)
           {
            //--- ���������� ������ �� �������
            ObjectCreate(0,"Sample_"+(string)i,OBJ_ARROW,window,time[v[0]*400+500],v[1]*45+50);
            ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_ARROWCODE,158);
            ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Blue);
            if(ov[0]>0.1) ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Green);
            if(ov[0]<-0.1) ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Red);
            ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_BACK,true);

            //--- ������ �������������� �����
            ObjectSetString(0,"Label_samples",OBJPROP_TEXT,"Total samples: "+string(i+1));
           }
         else Comment("Total samples: "+string(i+1),"  Total neurons: "+string(GNGAlgorithm.Neurons.Total())," ME=",GNGAlgorithm.maximun_E);
         //--- �������� ������� ������ ��������� ��� �������
         GNGAlgorithm.ProcessVector(v);

         if(window>0)
           {
            //--- �� ������� ���������� ������� ������ ������� � �����, ����� ����� ���������� �����
            for(j=ObjectsTotal(0)-1;j>=0;j--)
              {
               string name=ObjectName(0,j);
               if(StringFind(name,"Neuron_")>=0)
                 {
                  ObjectDelete(0,name);
                 }
               else if(StringFind(name,"Connection_")>=0)
                 {
                  ObjectDelete(0,name);
                 }
              }
           }
         double weights[];
         CGNGNeuron *tmp,*W1,*W2;
         CGNGConnection *tmpc;

         GNGAlgorithm.Neurons.FindWinners(W1,W2);

         //--- ��������� ��������
         tmp=GNGAlgorithm.Neurons.GetFirstNode();
         while(CheckPointer(tmp)!=POINTER_INVALID)
           {
            tmp.Weights(weights);

            if(window>0)
              {
               ObjectCreate(0,"Neuron_"+(string)tmp.uid,OBJ_ARROW,window,time[weights[0]*400+500],weights[1]*45+50);
               ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_ARROWCODE,159);

               //--- ���������� ������ Lime, ������ ������ Green, ��������� Red
               if(tmp==W1) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Lime);
               else if(tmp==W2) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Green);
               else ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Red);

               ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_BACK,false);
              }
            tmp=GNGAlgorithm.Neurons.GetNextNode();
           }
         if(window>0)
           {
            ObjectSetString(0,"Label_neurons",OBJPROP_TEXT,"Total neurons: "+string(GNGAlgorithm.Neurons.Total()));
           }
         else Comment("Total samples: "+string(i+1),"  Total neurons: "+string(GNGAlgorithm.Neurons.Total())," ME=",GNGAlgorithm.maximun_E);
         //--- ��������� ������
         tmpc=GNGAlgorithm.Connections.GetFirstNode();
         while(CheckPointer(tmpc))
           {
            int x1=0,x2;
            double y1=0,y2;

            tmp=GNGAlgorithm.Neurons.Find(tmpc.uid1);
            if(tmp!=NULL)
              {
               tmp.Weights(weights);
               x1=(int)(weights[0]*400+500);y1=weights[1];
              }
            tmp=GNGAlgorithm.Neurons.Find(tmpc.uid2);
            tmp.Weights(weights);
            x2=(int)(weights[0]*400+500);y2=weights[1];

            if(window>0)
              {
               ObjectCreate(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJ_TREND,window,time[x1],y1*45+50,time[x2],y2*45+50);
               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_WIDTH,1);
               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_STYLE,STYLE_DOT);
               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_COLOR,Yellow);
               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_BACK,false);
              }
            tmpc=GNGAlgorithm.Connections.GetNextNode();
           }

         ChartRedraw();
        }
     }
//--- ������� �� ������ ��������� ���������
   Print("Completed! Total neurons: "+string(GNGAlgorithm.Neurons.Total()));
   delete GNGAlgorithm;

//--- ����� ����� �������� �������
   while(!IsStopped())Sleep(100);

//--- ������� � ������ ��� �������
   ObjectsDeleteAll(0,window);
  }
//+------------------------------------------------------------------+
