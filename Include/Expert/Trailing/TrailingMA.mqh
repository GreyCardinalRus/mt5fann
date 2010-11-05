//+------------------------------------------------------------------+
//|                                                   TrailingMA.mqh |
//|                      Copyright � 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2010.10.12 |
//+------------------------------------------------------------------+
#include <Expert\ExpertTrailing.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trailing along MA                                          |
//| Type=Trailing                                                    |
//| Name=MA                                                          |
//| Class=CTrailingMA                                                |
//| Page=                                                            |
//| Parameter=Period,int,12                                          |
//| Parameter=Shift,int,0                                            |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA                         |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE                 |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingMA.                                               |
//| Appointment: Class traling stops with MA.                        |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+
class CTrailingMA : public CExpertTrailing
  {
protected:
   CiMA             *m_MA;
   //--- input parameters
   int               m_ma_period;
   int               m_ma_shift;
   ENUM_MA_METHOD    m_ma_method;
   ENUM_APPLIED_PRICE m_ma_applied;

public:
                     CTrailingMA();
                    ~CTrailingMA();
   //--- methods initialize protected data
   void              Period(int period)                  { m_ma_period=period;   }
   void              Shift(int shift)                    { m_ma_shift=shift;     }
   void              Method(ENUM_MA_METHOD method)       { m_ma_method=method;   }
   void              Applied(ENUM_APPLIED_PRICE applied) { m_ma_applied=applied; }
   virtual bool      InitIndicators(CIndicators *indicators);
   virtual bool      ValidationSettings();
   //---
   virtual bool      CheckTrailingStopLong(CPositionInfo *position,double& sl,double& tp);
   virtual bool      CheckTrailingStopShort(CPositionInfo *position,double& sl,double& tp);
  };
//+------------------------------------------------------------------+
//| Constructor CTrailingMA.                                         |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTrailingMA::CTrailingMA()
  {
//--- initialize protected data
   m_MA        =NULL;
//--- set default inputs
   m_ma_period =12;
   m_ma_shift  =0;
   m_ma_method =MODE_SMA;
   m_ma_applied=PRICE_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor CTrailingMA.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CTrailingMA::~CTrailingMA()
  {
//---
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingMA::ValidationSettings()
  {
//--- initial data checks
   if(m_ma_period<=0)
     {
      printf(__FUNCTION__+": Period MA must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking for input parameters and setting protected data.        |
//| INPUT:  symbol         -pointer to the CSymbolInfo,              |
//|         period         -working period,                          |
//|         adjusted_point -adjusted point value.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingMA::InitIndicators(CIndicators *indicators)
  {
//--- check
   if(indicators==NULL)       return(false);
//--- create MA indicator
   if(m_MA==NULL)
      if((m_MA=new CiMA)==NULL)
        {
         printf(__FUNCTION__+": Error creating object");
         return(false);
        }
//--- add MA indicator to collection
   if(!indicators.Add(m_MA))
     {
      printf(__FUNCTION__+": Error adding object");
      delete m_MA;
      return(false);
     }
//--- initialize MA indicator
   if(!m_MA.Create(m_symbol.Name(),m_period,m_ma_period,m_ma_shift,m_ma_method,m_ma_applied))
     {
      printf(__FUNCTION__+": Error initializing object");
      return(false);
     }
   m_MA.BufferResize(3+m_ma_shift);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for long position.          |
//| INPUT:  symbol -symbol.                                          |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingMA::CheckTrailingStopLong(CPositionInfo *position,double& sl,double& tp)
  {
//--- check
   if(position==NULL) return(false);
//---
   double level =NormalizeDouble(m_symbol.Bid()-m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.Main(1),m_symbol.Digits());
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   if(new_sl>position.PriceOpen() && new_sl>position.StopLoss() && new_sl<level)
      sl=new_sl;
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for short position.         |
//| INPUT:  symbol -symbol.                                          |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CTrailingMA::CheckTrailingStopShort(CPositionInfo *position,double& sl,double& tp)
  {
//--- check
   if(position==NULL) return(false);
//---
   double level =NormalizeDouble(m_symbol.Ask()+m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.Main(1)+m_symbol.Spread()*m_symbol.Point(),m_symbol.Digits());
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   if(new_sl<position.PriceOpen() && (new_sl<position.StopLoss() || position.StopLoss()==0.0) && new_sl>level)
      sl=new_sl;
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+