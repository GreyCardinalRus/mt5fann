//+------------------------------------------------------------------+
//|                                                     icq_mql5.mqh |
//|              Copyright Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

// ������������ �������� ��� ������� ICQConnect 
#define ICQ_CONNECT_STATUS_OK					   0xFFFFFFFF
#define ICQ_CONNECT_STATUS_RECV_ERROR			0xFFFFFFFE
#define ICQ_CONNECT_STATUS_SEND_ERROR			0xFFFFFFFD
#define ICQ_CONNECT_STATUS_CONNECT_ERROR		0xFFFFFFFC
#define ICQ_CONNECT_STATUS_AUTH_ERROR			0xFFFFFFFB

// �������� ��� ICQ_CLIENT.status
#define ICQ_CLIENT_STATUS_CONNECTED		      1
#define ICQ_CLIENT_STATUS_DISCONNECTED	      2

struct ICQ_CLIENT
    {
        uchar  status;   // ��� ��������� ����������� 
        ushort sequence; // ������� ������������������ 
        uint   sock;     // ����� ������
    };
//+------------------------------------------------------------------+
#import "icq_mql5.dll"
//+------------------------------------------------------------------+   
   uint ICQConnect (
      ICQ_CLIENT &cl,   // ���������� ��� �������� ������ � �����������
          string host,  // ��� �������, �������� login.icq.com
          ushort port,  // ���� �������, �������� 5190
          string login, // ����� ������� ������ (UIN)
          string pass   // ������ ��� ������� ������
                    );
                    
   void ICQClose (
      ICQ_CLIENT &cl    // ���������� ��� �������� ������ � �����������
                 );
                 
   
                
   uint ICQSendMsg (
    ICQ_CLIENT &cl,     // ���������� ��� �������� ������ � �����������.
         string uin,    // ����� ������� ������ ����������
         string msg     // ����� ���������
                );
                
   uint ICQReadMsg (
      ICQ_CLIENT &cl,   // ���������� ��� �������� ������ � ����������� 
          string &uin,  // ����� ������� ������ ����������� 
          string &msg,  // ����� ��������� 
            uint &len   // ���������� �������� �������� � ���������
                );
   
#import

//+------------------------------------------------------------------+
class COscarClient
//+------------------------------------------------------------------+
{
private:
  ICQ_CLIENT  client;        // �������� ������ � �����������
          uint connect;      // ���� ��������� �����������
      datetime timesave;     // �������� ���������� ������� ����������� � �������
      datetime time_in;      // �������� ���������� ������� ������ ���������

public:
      string uin;            // ������ ��� �������� uin ���������� ��� ��������� ���������
      string msg;            // ������ ��� �������� ������ ��������� ���������
        uint len;            // ���������� �������� � �������� ���������
     
      string login;          // ����� ������� ������ ����������� (UIN)
      string password;       // ������ ��� UIN 
      string server;         // ��� �������    
        uint port;           // ������� ����  
        uint timeout;        // ������� ��������(� ��������) ����� ��������� ����������� � ������
        bool autocon;        // �������������� �������������� ����������
        
           COscarClient();   // ����������� ��� ������������� ���������� ������
      bool Connect(void);    // ��������� ���������� � ��������
      void Disconnect(void); // ������ ���������� � ��������
      bool SendMessage(string  UIN, string  msg); // ������� ���������  
      bool ReadMessage(string &UIN, string &msg, uint &len); // ����� ���������
};

//+------------------------------------------------------------------+
bool COscarClient::ReadMessage(string &uin, string &msg, uint &len)
//+------------------------------------------------------------------+
{
   bool res = false; 

   if (ICQReadMsg(client, uin, msg, len)) res = true;
   else if (client.status != ICQ_CLIENT_STATUS_CONNECTED)
            if (autocon) Connect();

   Sleep(100);
   return(res);
};

//+------------------------------------------------------------------+
bool COscarClient::SendMessage(string UIN, string message)
//+------------------------------------------------------------------+
{
   bool ret = true;
   if (!ICQSendMsg(client,UIN,message))
   {
      ret = false;
      if (autocon) Connect();
   }
   return(ret);
};

//+------------------------------------------------------------------+
bool COscarClient::Connect()
//+------------------------------------------------------------------+
{
  
   if  ((TimeLocal() - timesave) >= timeout)
   { 
      timesave = TimeLocal();
      connect = ICQConnect(client, server, port, login, password);
      
      PrintError(connect);
   }
   
   if (connect == ICQ_CONNECT_STATUS_OK) return(true);
   else return(false); 
                 
};

//+------------------------------------------------------------------+
COscarClient::Disconnect()
//+------------------------------------------------------------------+
{
   connect = ICQ_CLIENT_STATUS_DISCONNECTED;
   ICQClose(client);
}

//+------------------------------------------------------------------+
COscarClient::COscarClient(void)// �����������
//+------------------------------------------------------------------+
{
   StringInit(uin,10,0);
   StringInit(msg,4096,0);  
   timeout = 20;
   autocon = true;
}

//+------------------------------------------------------------------+
void PrintError(uint status)
//+------------------------------------------------------------------+
{
   string errstr;
   
   switch(status)
   {
      case ICQ_CONNECT_STATUS_OK:            errstr = "Status_OK";            break;
      case ICQ_CONNECT_STATUS_AUTH_ERROR:    errstr = "Status_AUTH_ERROR";    break;
      case ICQ_CONNECT_STATUS_CONNECT_ERROR: errstr = "Status_CONNECT_ERROR"; break; 
      case ICQ_CONNECT_STATUS_RECV_ERROR:    errstr = "Status_RECV_ERROR";    break;                                    
      case ICQ_CONNECT_STATUS_SEND_ERROR:    errstr = "Status_SEND_ERROR";    break;
      case 0:                                errstr = "PARAMETER_INCORRECT";  break; 
      default:                        errstr = IntegerToString(status,8,' '); break;
   }
   printf("%s",errstr);
}