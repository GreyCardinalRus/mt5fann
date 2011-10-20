//+------------------------------------------------------------------+
//|                                                       Socket.mqh |
//|                                                     GreyCardinal |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "GreyCardinal"
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define SOCKET_CONNECT_STATUS_OK				0
#define SOCKET_CONNECT_STATUS__ERROR		1000

#define SOCKET_CLIENT_STATUS_CONNECTED		1
#define SOCKET_CLIENT_STATUS_DISCONNECTED	2

struct SOCKET_CLIENT
  {
   uchar             status;   // ��� ��������� ����������� 
   ushort            sequence; // ������� ������������������ 
   uint              sock;     // ����� ������
  };

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#import "icq_mql5_x64.dll"
//#import "socket_mql5_x64.dll"
//#import "SocketMQL5DLL_x64"
//+------------------------------------------------------------------+   
uint SocketOpen(
                SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � �����������
                string host,      // ��� �������
                ushort port       // ���� �������
                );

void SocketClose(
                 SOCKET_CLIENT &cl // ���������� ��� �������� ������ � �����������
                 );


uint SocketWriteString(
                       SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � ����������� 
                       string str        // ������
                       );
uint SocketReadString(
                       SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � ����������� 
                       string &str        // ������
                       );
uint SocketSendReceive(
                       SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � ����������� 
                       string send_str,        // ������
                       string &recv_str);        // ������

#import
