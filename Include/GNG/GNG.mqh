//+------------------------------------------------------------------+
//|                                                          GNG.mqh |
//|                                             Copyright 2010, alsu |
//|                                                 alsufx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alsu"
#property link      "alsufx@gmail.com"

#include "Neurons.mqh"
//+------------------------------------------------------------------+
//| �������� �����, �������������� ���������� �������� ���           |
//+------------------------------------------------------------------+
class CGNGAlgorithm
  {
public:
   //--- ������� ������ ��������-�������� � ������ ����� ����
   CGNGNeuronList   *Neurons;
   CGNGConnectionList *Connections;
   //--- ��������� ���������
   int               input_dimension;
   int               iteration_number;
   int               lambda;
   int               age_max;
   double            alpha;
   double            beta;
   double            eps_w;
   double            eps_n;
   int               max_nodes;

                     CGNGAlgorithm();
                    ~CGNGAlgorithm();
   virtual void      Init(int __input_dimension,
                          double &v1[],
                          double &v2[],
                          int __lambda,
                          int __age_max,
                          double __alpha,
                          double __beta,
                          double __eps_w,
                          double __eps_n,
                          int __max_nodes);
   virtual bool      ProcessVector(double &in[],bool train=true);
   virtual bool      StoppingCriterion();
  };
//+------------------------------------------------------------------+
//| �����������                                                      |
//+------------------------------------------------------------------+
CGNGAlgorithm::CGNGAlgorithm(void)
  {
   Neurons=new CGNGNeuronList();
   Connections=new CGNGConnectionList();
   
   Neurons.FreeMode(true);
   Connections.FreeMode(true);
  }
//+------------------------------------------------------------------+
//| ����������                                                       |
//+------------------------------------------------------------------+
CGNGAlgorithm::~CGNGAlgorithm(void)
  {
   delete Neurons;
   delete Connections;
  }
//+------------------------------------------------------------------+
//| �������������� �������� � ������� ���� �������� ������� ������   |
//| INPUT: v1,v2 - ������� �������                                   |
//|        __lambda - ���������� ��������, ����� �������� ���������� |
//|        ������� ������ �������                                    |
//|        __age_max - ������������ ������� ����������               |
//|        __alpha, __beta - ������������ ��� ��������� ������       |
//|        __eps_w, __eps_n - ������������ ��� ��������� �����       |
//|        __max_nodes - ����������� ������� ����                    |
//| OUTPUT: ���                                                     |
//+------------------------------------------------------------------+
void CGNGAlgorithm::Init(int __input_dimension,
                         double &v1[],
                         double &v2[],
                         int __lambda,
                         int __age_max,
                         double __alpha,
                         double __beta,
                         double __eps_w,
                         double __eps_n,
                         int __max_nodes)
  {
   iteration_number=0;
   input_dimension=__input_dimension;
   lambda=__lambda;
   age_max=__age_max;
   alpha= __alpha;
   beta = __beta;
   eps_w = __eps_w;
   eps_n = __eps_n;
   max_nodes=__max_nodes;
   Neurons.Init(v1,v2);

   CGNGNeuron *tmp;
   tmp=Neurons.GetFirstNode();
   int uid1=tmp.uid;
   tmp=Neurons.GetLastNode();
   int uid2=tmp.uid;

   Connections.Init(uid1,uid2);
  }
//+------------------------------------------------------------------+
//| �������� ������� ���������                                       |
//| INPUT: in - ������ ������� ������                                |
//|        train - ���� true, ��������� ��������, � ��������� ������ |
//|        ������ ���������� �������� �������� ��������              |
//| OUTPUT: true, ���� ���������� ������� ��������, ����� false      |
//+------------------------------------------------------------------+
bool CGNGAlgorithm::ProcessVector(double &in[],bool train=true)
  {
   if(ArraySize(in)!=input_dimension) return(StoppingCriterion());

   int i;

   CGNGNeuron *tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp))
     {
      tmp.ProcessVector(in);
      tmp=Neurons.GetNextNode();
     }

   if(!train) return(false);

   iteration_number++;
//--- ����� ��� �������, ��������� � in[], �.�. ���� � ��������� ����� 
//--- Ws � Wt, ������, ��� ||Ws-in||^2 �����������, � ||Wt-in||^2 -    
//--- ������ ����������� �������� ���������� ����� ���� ����� .        
//--- ��� ������������ ||*|| ���������� ��������� �����                
   CGNGNeuron *Winner,*SecondWinner;
   Neurons.FindWinners(Winner,SecondWinner);

//--- �������� ��������� ������ �������-����������                     
   Winner.E+=Winner.error;

//--- �������� ������-���������� � ���� ��� �������������� �������(�.�.
//--- ��� �������, ������� ���������� � �����������) � ������� ��������
//--- ������� �� ����������, ������ ����� eps_w � eps_n �� �������.    
   double delta[],weights[];

   Winner.Weights(weights);
   ArrayResize(delta,input_dimension);

   for(i=0;i<input_dimension;i++) delta[i]=eps_w*(in[i]-weights[i]);
   Winner.AdaptWeights(delta);

//--- ��������� �� 1 ������� ���� ����������, ��������� �� ����������. 
   CGNGConnection *tmpc=Connections.FindFirstConnection(Winner.uid);
   while(CheckPointer(tmpc))
     {
      if(tmpc.uid1==Winner.uid) tmp = Neurons.Find(tmpc.uid2);
      if(tmpc.uid2==Winner.uid) tmp = Neurons.Find(tmpc.uid1);

      tmp.Weights(weights);
      for(i=0;i<input_dimension;i++) delta[i]=eps_n*(in[i]-weights[i]);
      tmp.AdaptWeights(delta);

      tmpc.age++;

      tmpc=Connections.FindNextConnection(Winner.uid);
     }

//--- ���� ��� ������ ������� ���������, �������� ������� �� �����.    
//--- � ��������� ������ ������� ����� ����� ����.                     
   tmpc=Connections.Find(Winner.uid,SecondWinner.uid);
   if(tmpc) tmpc.age=0;
   else
     {
      Connections.Append();
      tmpc=Connections.GetLastNode();
      tmpc.uid1 = Winner.uid;
      tmpc.uid2 = SecondWinner.uid;
      tmpc.age=0;
     }

//--- ������� ��� ����������, ������� ������� ��������� age_max.       
//--- ���� ����� ����� ������� �������, �� ������� ������ � �������    
//--- ������, ������� ��� �������.                                     
   tmpc=Connections.GetFirstNode();
   while(CheckPointer(tmpc))
     {
      if(tmpc.age>age_max)
        {
         Connections.DeleteCurrent();
         tmpc=Connections.GetCurrentNode();
        }
      else tmpc=Connections.GetNextNode();
     }

   tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp))
     {
      if(!Connections.FindFirstConnection(tmp.uid))
        {
         Neurons.DeleteCurrent();
         tmp=Neurons.GetCurrentNode();
        }
      else tmp=Neurons.GetNextNode();
     }

//--- ���� ����� ������� �������� ������ lambda, � ���������� ������   
//--- ���� �� ���������, ������� ����� ������ r �� ��������� ��������  
   CGNGNeuron *u,*v;
   if(iteration_number%lambda==0 && Neurons.Total()<max_nodes)
     {
      //--- 1.����� ������ u � ���������� ��������� �������.               
      tmp=Neurons.GetFirstNode();
      u=tmp;
      while(CheckPointer(tmp=Neurons.GetNextNode()))
        {
         if(tmp.E>u.E)
            u=tmp;
        }

      //--- 2.����� ������� u ����� ���� u � ���������� ��������� �������. 
      tmpc=Connections.FindFirstConnection(u.uid);
      if(tmpc.uid1==u.uid) v=Neurons.Find(tmpc.uid2);
      else v=Neurons.Find(tmpc.uid1);
      while(CheckPointer(tmpc=Connections.FindNextConnection(u.uid)))
        {
         if(tmpc.uid1==u.uid) tmp=Neurons.Find(tmpc.uid2);
         else tmp=Neurons.Find(tmpc.uid1);
         if(tmp.E>v.E)
            v=tmp;
        }

      //--- 3.������� ���� r "���������" ����� u � v.                      
      double wr[],wu[],wv[];

      u.Weights(wu);
      v.Weights(wv);
      ArrayResize(wr,input_dimension);
      for(i=0;i<input_dimension;i++) wr[i]=(wu[i]+wv[i])/2;

      CGNGNeuron *r=Neurons.Append();
      r.Init(wr);
      //--- 4.�������� ����� ����� u � v �� ����� ����� u � r, v � r       
      tmpc=Connections.Append();
      tmpc.uid1=u.uid;
      tmpc.uid2=r.uid;

      tmpc=Connections.Append();
      tmpc.uid1=v.uid;
      tmpc.uid2=r.uid;

      Connections.Find(u.uid,v.uid);
      Connections.DeleteCurrent();

      //--- 5.��������� ������ �������� u � v, ���������� �������� ������  
      //---   ������� r ����� ��, ��� � u.                                 

      u.E*=alpha;
      v.E*=alpha;
      r.E = u.E;
     }

//--- ��������� ������ ���� �������� �� ���� beta                     
   tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp))
     {
      tmp.E*=(1-beta);
      tmp=Neurons.GetNextNode();
     }

//--- ��������� �������� ��������                                      
   return(StoppingCriterion());
  }
//+------------------------------------------------------------------+
//| �������� ��������. � ������ ������ ����� �� ��������� �������    |
//| ��������, ������ ��������� false.                                |
//| INPUT: ���                                                       |
//| OUTPUT: true, ���� �������� �����������, false � ��������� ������|
//+------------------------------------------------------------------+
bool CGNGAlgorithm::StoppingCriterion()
  {
   return(false);
  }
//+------------------------------------------------------------------+
//| ����� ��������� GNG with Utility factor                          |
//+------------------------------------------------------------------+
class CGNGUAlgorithm:public CGNGAlgorithm
  {
public:
   double            k;
   virtual void      Init(int __input_dimension,
                          double &v1[],
                          double &v2[],
                          int __lambda,
                          int __age_max,
                          double __alpha,
                          double __beta,
                          double __eps_w,
                          double __eps_n,
                          int __max_nodes,
                          double __k);
   virtual bool      ProcessVector(double &in[],bool train=true);
   virtual bool      StoppingCriterion();
  };
//+------------------------------------------------------------------+
//| �������������� �������� � ������� ���� �������� ������� ������   |
//| INPUT: v1,v2 - ������� �������                                   |
//|        __lambda - ���������� ��������, ����� �������� ���������� |
//|        ������� ������ �������                                    |
//|        __age_max - ������������ ������� ����������               |
//|        __alpha, __beta - ������������ ��� ��������� ������       |
//|        __eps_w, __eps_n - ������������ ��� ��������� �����       |
//|        __max_nodes - ����������� ������� ����                    |
//|        __k - �������������� ������ ��� �������������� ������     |
//| OUTPUT: ���                                                      |
//+------------------------------------------------------------------+
void CGNGUAlgorithm::Init(int __input_dimension,
                          double &v1[],
                          double &v2[],
                          int __lambda,
                          int __age_max,
                          double __alpha,
                          double __beta,
                          double __eps_w,
                          double __eps_n,
                          int __max_nodes,
                          double __k)
  {
   iteration_number=0;
   input_dimension=__input_dimension;
   lambda=__lambda;
   age_max=__age_max;
   alpha= __alpha;
   beta = __beta;
   eps_w = __eps_w;
   eps_n = __eps_n;
   max_nodes=__max_nodes;
   k=__k;
   Neurons.Init(v1,v2);

   CGNGNeuron *tmp;
   tmp=Neurons.GetFirstNode();
   int uid1=tmp.uid;
   tmp=Neurons.GetLastNode();
   int uid2=tmp.uid;

   Connections.Init(uid1,uid2);
  }
//+------------------------------------------------------------------+
//| �������� ������� ���������                                       |
//| INPUT: in - ������ ������� ������                                |
//|        train - ���� true, ��������� ��������, � ��������� ������ |
//|        ������ ���������� �������� �������� ��������              |
//| OUTPUT: true, ���� ���������� ������� ��������, ����� false      |
//+------------------------------------------------------------------+
bool CGNGUAlgorithm::ProcessVector(double &in[],bool train=true)
  {
   if(ArraySize(in)!=input_dimension) return(StoppingCriterion());

   int i;

   CGNGNeuron *tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp))
     {
      tmp.ProcessVector(in);
      tmp=Neurons.GetNextNode();
     }

   if(!train) return(false);

   iteration_number++;

//--- ����� ��� �������, ��������� � in[], �.�. ���� � ��������� ����� 
//--- Ws � Wt, ������, ��� ||Ws-in||^2 �����������, � ||Wt-in||^2 -    
//--- ������ ����������� �������� ���������� ����� ���� ����� .        
//--- ��� ������������ ||*|| ���������� ��������� �����                

   CGNGNeuron *Winner,*SecondWinner;
   Neurons.FindWinners(Winner,SecondWinner);

//--- �������� ��������� ������ � ���������� �������-����������        

   Winner.E+=Winner.error;
   Winner.U+=SecondWinner.error-Winner.error;

//--- �������� ������-���������� � ���� ��� �������������� �������(�.�.
//--- ��� �������, ������� ���������� � �����������) � ������� ��������
//--- ������� �� ����������, ������ ����� eps_w � eps_n �� �������.    

   double delta[],weights[];

   Winner.Weights(weights);
   ArrayResize(delta,input_dimension);

   for(i=0;i<input_dimension;i++) delta[i]=eps_w*(in[i]-weights[i]);
   Winner.AdaptWeights(delta);

//--- ��������� �� 1 ������� ���� ����������, ��������� �� ����������. 

   CGNGConnection *tmpc=Connections.FindFirstConnection(Winner.uid);
   while(CheckPointer(tmpc))
     {
      if(tmpc.uid1==Winner.uid) tmp = Neurons.Find(tmpc.uid2);
      if(tmpc.uid2==Winner.uid) tmp = Neurons.Find(tmpc.uid1);

      tmp.Weights(weights);
      for(i=0;i<input_dimension;i++) delta[i]=eps_n*(in[i]-weights[i]);
      tmp.AdaptWeights(delta);

      tmpc.age++;

      tmpc=Connections.FindNextConnection(Winner.uid);
     }

//--- ���� ��� ������ ������� ���������, �������� ������� �� �����.    
//--- � ��������� ������ ������� ����� ����� ����.                     

   tmpc=Connections.Find(Winner.uid,SecondWinner.uid);
   if(tmpc) tmpc.age=0;
   else
     {
      Connections.Append();
      tmpc=Connections.GetLastNode();
      tmpc.uid1 = Winner.uid;
      tmpc.uid2 = SecondWinner.uid;
      tmpc.age=0;
     }

//--- ������� ��� ����������, ������� ������� ��������� age_max.       
//--- ���� ����� ����� � ������� � ����������� ����������� ����        
//--- ���������� �����, ��� � k ��� ������ ������������ ������, 
//--- ������� ���� ������.      

   tmpc=Connections.GetFirstNode();
   while(CheckPointer(tmpc))
     {
      if(tmpc.age>age_max)
        {
         Connections.DeleteCurrent();
         tmpc=Connections.GetCurrentNode();
        }
      else tmpc=Connections.GetNextNode();
     }

   tmp=Neurons.GetFirstNode();
   double max_error=0;
   double min_U=0;
   CGNGNeuron *useless;

   if(CheckPointer(tmp))
     {
      max_error=tmp.error;
      min_U=tmp.U;
      useless=tmp;
     }
   while(CheckPointer(tmp=Neurons.GetNextNode()))
     {
      if(tmp.error>max_error)
        {
         max_error=tmp.error;
        }
      if(tmp.U<min_U)
        {
         min_U=tmp.U;
         useless=tmp;
        }
     }
   if(min_U!=0 && max_error/min_U>k) Neurons.Delete(Neurons.IndexOf(tmp));

//--- ���� ����� ������� �������� ������ lambda, � ���������� ������   
//--- ���� �� ���������, ������� ����� ������ r �� ��������� ��������  

   CGNGNeuron *u,*v;
   if(iteration_number%lambda==0 && Neurons.Total()<max_nodes)
     {

      //--- 1.����� ������ u � ���������� ��������� �������.               

      tmp=Neurons.GetFirstNode();
      u=tmp;
      while(CheckPointer(tmp=Neurons.GetNextNode()))
        {
         if(tmp.E>u.E)
            u=tmp;
        }

      //--- 2.����� ������� u ����� ���� u � ���������� ��������� �������. 

      tmpc=Connections.FindFirstConnection(u.uid);
      if(tmpc.uid1==u.uid) v=Neurons.Find(tmpc.uid2);
      else v=Neurons.Find(tmpc.uid1);
      while(CheckPointer(tmpc=Connections.FindNextConnection(u.uid)))
        {
         if(tmpc.uid1==u.uid) tmp=Neurons.Find(tmpc.uid2);
         else tmp=Neurons.Find(tmpc.uid1);
         if(tmp.E>v.E)
            v=tmp;
        }

      //--- 3.������� ���� r "���������" ����� u � v.                      
      //---   ��������� ��� ������ ����������                              

      double wr[],wu[],wv[];

      u.Weights(wu);
      v.Weights(wv);
      ArrayResize(wr,input_dimension);
      for(i=0;i<input_dimension;i++) wr[i]=(wu[i]+wv[i])/2;

      CGNGNeuron *r=Neurons.Append();
      r.Init(wr);

      r.U=(u.U+v.U)/2;

      //--- 4.�������� ����� ����� u � v �� ����� ����� u � r, v � r       

      tmpc=Connections.Append();
      tmpc.uid1=u.uid;
      tmpc.uid2=r.uid;

      tmpc=Connections.Append();
      tmpc.uid1=v.uid;
      tmpc.uid2=r.uid;

      Connections.Find(u.uid,v.uid);
      Connections.DeleteCurrent();

      //--- 5.��������� ������ �������� u � v, ���������� �������� ������  
      //---   ������� r ����� ��, ��� � u.                                 

      u.E*=alpha;
      v.E*=alpha;
      r.E = u.E;
     }

//--- ��������� ������ � ���������� ���� �������� �� ���� beta 	     

   tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp))
     {
      tmp.E*=(1-beta);
      tmp.U*=(1-beta);
      tmp=Neurons.GetNextNode();
     }

//--- ��������� �������� ��������                                      

   return(StoppingCriterion());
  }
//+------------------------------------------------------------------+
//| �������� ��������. � ������ ������ ����� �� ��������� �������    |
//| ��������, ������ ��������� false.                                |
//| INPUT: ���                                                       |
//| OUTPUT: true, ���� �������� �����������, false � ��������� ������|
//+------------------------------------------------------------------+
bool CGNGUAlgorithm::StoppingCriterion()
  {
   return(false);
  }
//+------------------------------------------------------------------+
