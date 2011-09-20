//+------------------------------------------------------------------+
//|                                              CommonFunctions.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//#include <icq_mql5.mqh>
input bool _TrailingPosition_=true;//��������� ������� �� ��������
input bool _OpenNewPosition_=true;//��������� ������� � �����
input int _NumTS_=3;//������� ������� �� ��������
input string spamfilename   = "notify.txt";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar(string smbl="",ENUM_TIMEFRAMES tf=0)
  {
   static datetime lastTime=0;
   if(""==smbl)smbl=_Symbol;
   datetime lastbarTime=(datetime)SeriesInfoInteger(smbl,tf,SERIES_LASTBAR_DATE);
   if(lastTime==0 || lastTime!=lastbarTime)
     {
      lastTime=lastbarTime;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum NewOrder_Type
  {
   NewOrderBuy=1,// 
   NewOrderWaitBuy=2,// 
   NewOrderWait=3,// 
   NewOrderWaitSell=4,
   NewOrderSell=5
  };
//COscarClient client;
// ask
// bid
//+------------------------------------------------------------------+
//|   ����� �� ����� - �������� �� ������� -�� ����������� ��������� ��� ��� ���� ����������  |
//+------------------------------------------------------------------+
bool NewOrder(string smb,double way,string comment,double price=0,int magic=777,datetime expiration=0)
  {
   if(""==comment) comment=(string)way;
   if(0.66<way) return(NewOrder(smb,NewOrderBuy,comment,price,magic,expiration));
// ���� �������� -������� ��� ������ if(0.33<way) return(NewOrder(smb,NewOrderWaitBuy,comment,price,magic,expiration));
   if(-0.66>way) return(NewOrder(smb,NewOrderSell,comment,price,magic,expiration));
// ���� �������� -������� ��� ������ if(-0.33>way) return(NewOrder(smb,NewOrderWaitSell,comment,price,magic,expiration));
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewOrder(string smb,NewOrder_Type type,string comment,double price=0,int magic=777,datetime expiration=0)
  {
   if(""==smb)
     {
      Print("empty symbol");
      return(false);
     }
   StringToUpper(smb);
   if(NewOrderWait==type || !_OpenNewPosition_) return(false);
   if(""==comment) comment=smb;
   ulong    ticket;
   ticket=0;
   int i;
// ���� �����-�� ���������� �����
   for(i=0;i<OrdersTotal();i++)
     {
      OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL)==smb)
        {
         if(type==NewOrderBuy && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_LIMIT) return(false);
         if(type==NewOrderWaitBuy && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_LIMIT) return(false);
         if(type==NewOrderSell  &&  OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_LIMIT) return(false);
         if(type==NewOrderWaitSell && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_LIMIT) return(false);
        }
     }
// ���� �������� �������
   for(i=0;i<PositionsTotal();i++)
     {
      if(smb==PositionGetSymbol(i))
        {
         // ��������? ���������������� �����!
         if(type==NewOrderBuy && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) return(false);
         if(type==NewOrderWaitBuy && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) return(false);
         // ���������? ���������������� �����!
         if(type==NewOrderSell && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) return(false);
         if(type==NewOrderWaitSell && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) return(false);
         // ���� ������� ������� - � ������ ������ -����� ������� ������ ������!!
         ticket=PositionGetInteger(POSITION_IDENTIFIER);
         break;
        }
     }
// ���� ��� ������, � ���� ������ ������� -�� ������...
   if((0==ticket) && (type==NewOrderWaitBuy || type==NewOrderWaitSell))return(false);
   MqlTick lasttick;
   if(!SymbolInfoTick(smb,lasttick)) return(false);;
   if(0==expiration) expiration=TimeCurrent()+3*PeriodSeconds(_Period);
   if(price==0)
     {
      if(ticket!=0)
        {// ���� �������� � ��� ������� �� ������ - ������ �� ���� � ��� �������� -���� �� �������
         magic=666;
         if(type==NewOrderWaitBuy || type==NewOrderBuy)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               // ���� ������� ��� ���� -�� ���������� � ������
               //if(PositionGetDouble(POSITION_PROFIT)>1)
               //   price=PositionGetDouble(POSITION_PRICE_CURRENT)-SymbolInfoInteger(smb,SYMBOL_SPREAD)*SymbolInfoDouble(smb,SYMBOL_POINT)*1.1;
               //else// ����� ������ �� ��� �������
               price=PositionGetDouble(POSITION_PRICE_OPEN)-1.5*SymbolInfoInteger(smb,SYMBOL_SPREAD)*SymbolInfoDouble(smb,SYMBOL_POINT);//BufferC[1];
              }
            else return(false);
           }
         if(type==NewOrderWaitSell || type==NewOrderSell)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               //// ���� ������� ��� ���� -�� ���������� � ������
               //if(PositionGetDouble(POSITION_PROFIT)>1)
               //   price=PositionGetDouble(POSITION_PRICE_CURRENT)+SymbolInfoInteger(smb,SYMBOL_SPREAD)*SymbolInfoDouble(smb,SYMBOL_POINT)*1.1;
               //else// ����� ������ �� ��� �������
               price=PositionGetDouble(POSITION_PRICE_OPEN)+1.5*SymbolInfoInteger(smb,SYMBOL_SPREAD)*SymbolInfoDouble(smb,SYMBOL_POINT);
              }
            else return(false);
           }
         expiration=0;         // ������� �� �������� - ���� ����� ����� ���� �� �������� �������� 
        }
      else
        {
         if(type==NewOrderBuy) price=lasttick.ask+5*SymbolInfoDouble(smb,SYMBOL_POINT);
         if(type==NewOrderWaitBuy) price=lasttick.ask+5*SymbolInfoDouble(smb,SYMBOL_POINT);
         if(type==NewOrderWaitSell) price=lasttick.bid-5*SymbolInfoDouble(smb,SYMBOL_POINT);
         if(type==NewOrderSell) price=lasttick.bid-5*SymbolInfoDouble(smb,SYMBOL_POINT);
        }
     }

   MqlTradeRequest trReq;
   MqlTradeResult trRez;
   trReq.action=TRADE_ACTION_PENDING;
   trReq.magic=magic;
   trReq.symbol=smb;                 // Trade symbol
   trReq.volume=0.1;      // Requested volume for a deal in lots
   trReq.deviation=3;                                    // Maximal possible deviation from the requested price
   trReq.sl=0;//lasttick.bid + 1.5*TrailingStop*SymbolInfoDouble(smb,SYMBOL_POINT);
   trReq.tp=price;
   trReq.comment=comment;
   trReq.expiration=expiration;
   if(expiration==0)
      trReq.type_time=ORDER_TIME_GTC;
   else
      trReq.type_time=ORDER_TIME_SPECIFIED;

   if(type==NewOrderBuy || type==NewOrderWaitBuy)
     {
      trReq.price=0.001;                             // SymbolInfoDouble(NULL,SYMBOL_ASK);
      trReq.type=ORDER_TYPE_BUY_LIMIT;
     }

   else//  if(type==NewOrderSell||type==NewOrderWaitSell)
     {
      trReq.price=10000.00001;                             // SymbolInfoDouble(NULL,SYMBOL_ASK);
      trReq.type=ORDER_TYPE_SELL_LIMIT;
     }
   OrderSend(trReq,trRez);
   if(10009!=trRez.retcode)
     {
      Print(__FUNCTION__," : ",trRez.comment," ��� ������ ",trRez.retcode," trReq.price=",trReq.price," trReq.tp=",trReq.tp," trReq.sl=",trReq.sl," trReq.type=",trReq.type);
      if(ORDER_TYPE_BUY_LIMIT==trReq.type) Print("ORDER_TYPE_BUY_LIMIT");
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DeleteOrder(ulong ticket)
  {
   MqlTradeRequest   trReq;
   MqlTradeResult    trRez;
   trReq.action    =TRADE_ACTION_REMOVE;
   trReq.order     =ticket;
   if(!OrderSend(trReq,trRez)){};
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExportHistory(string fname,int from=0,int to=0)
  {
   HistorySelect(0,TimeCurrent());
   int deals=HistoryDealsTotal();
   ulong ticket;
   int FileHandle=FileOpen(fname,FILE_WRITE|FILE_ANSI|FILE_CSV,';');
   if(FileHandle!=INVALID_HANDLE)
     {
      for(int idt=0;idt<deals;idt++)
        {
         if((bool)(ticket=HistoryDealGetTicket(idt)))
           {
            FileWrite(FileHandle,HistoryDealGetString(ticket,DEAL_SYMBOL),HistoryDealGetDouble(ticket,DEAL_PROFIT));
           }
        }
      FileClose(FileHandle);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| ������� ��������� ������                                         |
//+------------------------------------------------------------------+
int Fun_Error(int Error)
  {
   switch(Error)
     {
      case 10004: Alert("�������");return(1);
      case 10006: Alert("������ ���������");Sleep(3000);return(1);
      case 10007: Alert("������ ������� ���������");return(0);
      case 10008: Alert("����� ��������");return(2);
      case 10009: Alert("������ ���������");return(2);
      case 10010: Alert("������ ��������� ��������");return(2);
      case 10011: Alert("������ ��������� �������");return(1);
      case 10012: Alert("������ ������� �� ��������� �������");return(1);
      case 10013: Alert("������������ ������");return(0);
      case 10014: Alert("������������ ����� � �������");return(0);
      case 10015: Alert("������������ ���� � �������");return(0);
      case 10016: Alert("������������ ����� � �������");return(0);
      case 10017: Alert("�������� ���������");return(0);
      case 10018: Alert("����� ������");return(0);
      case 10019: Alert("��� ����������� �������� ������� ��� ���������� �������");return(0);
      case 10020: Alert("���� ����������");return(1);
      case 10021: Alert("����������� ��������� ��� ��������� �������");Sleep(3000);return(1);
      case 10022: Alert("�������� ���� ��������� ������ � �������");return(0);
      case 10023: Alert("��������� ������ ����������");return(2);
      case 10024: Alert("������� ������ �������");return(0);
      case 10025: Alert("� ������� ��� ���������");Sleep(3000);return(1);
      case 10026: Alert("������������ �������� ��������");return(0);
      case 10027: Alert("������������ �������� ���������� ����������");return(0);
      case 10028: Alert("������ ������������ ��� ���������");return(2);
      case 10029: Alert("����� ��� ������� ����������");return(2);
      case 10030: Alert("������ ���������������� ��� ���������� ������ �� �������");return(0);
      case 10031: Alert("��� ���������� � �������� ��������");Sleep(3000);return(1);
      case 10032: Alert("�������� ��������� ������ ��� �������� ������");return(0);
      case 10033: Alert("��������� ����� �� ���������� ���������� �������");return(2);
      case 10034: Alert("��������� ����� �� ����� ������� � ������� ��� ������� �������");return(2);
      default:    Alert("������ � - ",Error);return(0);
     }
  }
//+------------------------------------------------------------------+
