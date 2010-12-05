//+------------------------------------------------------------------+
//|                                                  InternetLib.mqh |
//|                                 Copyright � 2010 www.fxmaster.de |
//|                                         Coding by Sergeev Alexey |
//+------------------------------------------------------------------+
#property copyright   "www.fxmaster.de  � 2010"
#property link        "www.fxmaster.de"
#property version     "1.00"
#property description "Liblary for work with wininet.dll"
#property library

#import "wininet.dll"
int InternetAttemptConnect(int x);
int InternetOpenW(string &sAgent,int lAccessType,string &sProxyName,string &sProxyBypass,int lFlags);
int InternetConnectW(int hInternet,string &lpszServerName,int nServerPort,string &lpszUsername,string &lpszPassword,int dwService,int dwFlags,int dwContext);
int HttpOpenRequestW(int hConnect,string &lpszVerb,string &lpszObjectName,string &lpszVersion,string &lpszReferer,string &lplpszAcceptTypes,uint dwFlags,int dwContext);
int HttpSendRequestW(int hRequest,string &lpszHeaders,int dwHeadersLength,uchar &lpOptional[],int dwOptionalLength);
int HttpQueryInfoW(int hRequest,int dwInfoLevel,uchar &lpvBuffer[],int &lpdwBufferLength,int &lpdwIndex);
int InternetOpenUrlW(int hInternet,string &lpszUrl,string &lpszHeaders,int dwHeadersLength,int dwFlags,int dwContext);
int InternetReadFile(int hFile,uchar &sBuffer[],int lNumBytesToRead,int &lNumberOfBytesRead);
int InternetCloseHandle(int hInet);
#import

#define OPEN_TYPE_PRECONFIG           0  // ������������ ������������ �� ���������
#define FLAG_KEEP_CONNECTION 0x00400000  // �� ��������� ����������
#define FLAG_PRAGMA_NOCACHE  0x00000100  // �� ���������� ��������
#define FLAG_RELOAD          0x80000000  // �������� �������� � ������� ��� ��������� � ���
#define SERVICE_HTTP                  3  // ������ Http 
#define HTTP_QUERY_CONTENT_LENGTH     5
//+------------------------------------------------------------------+
class MqlNet
  {

   string            Host;       // ��� �����
   int               Port;       // ����
   int               Session;    // ���������� ������
   int               Connect;    // ���������� ����������
public:
                     MqlNet();   // ����������� ������
                    ~MqlNet();   // ����������
   bool              Open(string aHost,int aPort); // ������� ������ � ��������� ����������
   void              Close();    // ��������� ������ � ����������
   bool              Request(string Verb,string Request,string &Out,bool toFile=false,string addData="",bool fromFile=false); // ���������� ������
   bool              OpenURL(string URL,string &Out,bool toFile); // ������ ������ �������� � ���� ��� � ����������
   void              ReadPage(int hRequest,string &Out,bool toFile); // ������ ��������
   long              GetContentSize(int hURL); //��������� ���������� � ������� �����������  ��������
   int               FileToArray(string FileName,uchar &data[]); // �������� ���� � ������ ��� ��������
  };
//------------------------------------------------------------------ MqlNet
void MqlNet::MqlNet()
  {
   // �������� ���������
   Session=-1;
   Connect=-1;
   Host="";
  }
//------------------------------------------------------------------ ~MqlNet
void MqlNet::~MqlNet()
  {
   // ��������� ��� �����������
   Close();
  }
//------------------------------------------------------------------ Open
bool MqlNet::Open(string aHost,int aPort)
  {
   if(aHost=="")
     {
      Print("-Host is not specified");
      return(false);
     }
   // �������� ���������� DLL � ���������  
   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Print("-DLL is not allowed");
      return(false);
     }
   // ���� ������ ���� �����������, �� ���������
   if(Session>0 || Connect>0) Close();
   // ��������� ��� ������� �������� � ������
   Print("+Open Inet...");
   // ���� �� ������� ��������� ��������� ���������� � ����������, �� �������
   if(InternetAttemptConnect(0)!=0)
     {
      Print("-Err AttemptConnect");
      return(false);
     }
   string UserAgent="Mozilla"; string nill="";
   // ��������� ������
   Session=InternetOpenW(UserAgent,OPEN_TYPE_PRECONFIG,nill,nill,0);
   // ���� �� ������ ������� ������, �� �������
   if(Session<=0)
     {
      Print("-Err create Session");
      Close();
      return(false);
     }
   Connect=InternetConnectW(Session,aHost,aPort,nill,nill,SERVICE_HTTP,0,0);
   if(Connect<=0)
     {
      Print("-Err create Connect");
      Close();
      return(false);
     }
   Host=aHost; Port=aPort;
   // ����� ��� �������� ����������� �������
   return(true);
  }
//------------------------------------------------------------------ Close
void MqlNet::Close()
  {
   Print("-Close Inet...");
   if(Session>0) InternetCloseHandle(Session);
   Session=-1;
   if(Connect>0) InternetCloseHandle(Connect);
   Connect=-1;
  }
//------------------------------------------------------------------ Request
bool MqlNet::Request(string Verb,string Object,string &Out,bool toFile=false,string addData="",bool fromFile=false)
  {
   if(toFile && Out=="")
     {
      Print("-File is not specified ");
      return(false);
     }
   uchar data[];
   int hRequest,hSend,h;
   string Vers="HTTP/1.1";
   string nill="";
   if(fromFile)
     {
      if(FileToArray(addData,data)<0)
        {
         Print("-Err reading file "+addData);
         return(false);
        }
     } // ��������� ���� � ������
   else StringToCharArray(addData,data);

   if(Session<=0 || Connect<=0)
     {
      Close();
      if(!Open(Host,Port))
        {
         Print("-Err Connect");
         Close();
         return(false);
        }
     }
   // ������� ���������� �������
   hRequest=HttpOpenRequestW(Connect,Verb,Object,Vers,nill,nill,FLAG_KEEP_CONNECTION|FLAG_RELOAD|FLAG_PRAGMA_NOCACHE,0);
   if(hRequest<=0)
     {
      Print("-Err OpenRequest");
      InternetCloseHandle(Connect);
      return(false);
     }
   // ���������� ������
   // ��������� �� ��������
   string head="Content-Type: application/x-www-form-urlencoded";
   // ��������� ����
   hSend=HttpSendRequestW(hRequest,head,StringLen(head),data,ArraySize(data)-1);
   if(hSend<=0)
     {
      Print("-Err SendRequest");
      InternetCloseHandle(hRequest);
      Close();
     }
   // ������ �������� 
   ReadPage(hRequest,Out,toFile);
   // ������� ��� ������
   InternetCloseHandle(hRequest);
   InternetCloseHandle(hSend);
   return(true);
  }
//------------------------------------------------------------------ OpenURL
bool MqlNet::OpenURL(string URL,string &Out,bool toFile)
  {
   string nill="";
   if(Session<=0 || Connect<=0)
     {
      Close();
      if(!Open(Host,Port))
        {
         Print("-Err Connect");
         Close();
         return(false);
        }
     }
   int hURL=InternetOpenUrlW(Session, URL, nill, 0, FLAG_RELOAD|FLAG_PRAGMA_NOCACHE, 0);
   if(hURL<=0)
     {
      Print("-Err OpenUrl");
      return(false);
     }
   // ������ � Out  
   ReadPage(hURL,Out,toFile);
   // ������� 
   InternetCloseHandle(hURL);
   return(true);
  }
//------------------------------------------------------------------ ReadPage
void MqlNet::ReadPage(int hRequest,string &Out,bool toFile)
  {
   // ������ �������� 
   uchar ch[100];
   string toStr="";
   int dwBytes,h;
   while(InternetReadFile(hRequest,ch,100,dwBytes))
     {
      if(dwBytes<=0) break;
      toStr=toStr+CharArrayToString(ch,0,dwBytes);
     }
   if(toFile)
     {
      h=FileOpen(Out,FILE_BIN|FILE_WRITE);
      FileWriteString(h,toStr);
      FileClose(h);
     }
   else Out=toStr;
  }
//------------------------------------------------------------------ GetContentSize
long MqlNet::GetContentSize(int hRequest)
  {
   int len=2048,ind=0;
   uchar buf[2048];
   int Res=HttpQueryInfoW(hRequest, HTTP_QUERY_CONTENT_LENGTH, buf, len, ind);
   if(Res<=0)
     {
      Print("-Err QueryInfo");
      return(-1);
     }
   string s=CharArrayToString(buf,0,len);
   if(StringLen(s)<=0) return(0);
   return(StringToInteger(s));
  }
//----------------------------------------------------- FileToArray
int MqlNet::FileToArray(string FileName,uchar &data[])
  {
   int h,i,size;
   h=FileOpen(FileName,FILE_BIN|FILE_READ);
   if(h<0) return(-1);
   FileSeek(h,0,SEEK_SET);
   size=(int)FileSize(h);
   ArrayResize(data,(int)size);
   for(i=0; i<size; i++)
     {
      data[i]=(uchar)FileReadInteger(h,CHAR_VALUE);
     }
   FileClose(h); return(size);
  }
//+------------------------------------------------------------------+
