//+------------------------------------------------------------------+
//|                                                  SignalFrAMA.mqh |
//|                      Copyright � 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                              Revision 2011.03.30 |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator 'Fractal Adaptive Moving Average'     |
//| Type=SignalAdvanced                                              |
//| Name=Fractal Adaptive Moving Average                             |
//| ShortName=FraMA                                                  |
//| Class=CSignalFrAMA                                               |
//| Page=signal_frama                                                |
//| Parameter=PeriodMA,int,12,Period of averaging                    |
//| Parameter=Shift,int,0,Time shift                                 |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalFrAMA.                                              |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Fractal Adaptive Moving Average' indicator.        |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalFrAMA : public CExpertSignal
  {
protected:
   CiFrAMA           m_ma;             // object-indicator
   //--- adjusted parameters
   int               m_ma_period;      // the "period of averaging" parameter of the indicator
   int               m_ma_shift;       // the "time shift" parameter of the indicator
   ENUM_APPLIED_PRICE m_ma_applied;    // the "object of averaging" parameter" of the indicator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "price is on the necessary side from the indicator"
   int               m_pattern_1;      // model 1 "price crossed the indicator with opposite direction"
   int               m_pattern_2;      // model 2 "price crossed the indicator with the same direction"

public:
                     CSignalFrAMA();
   //--- methods of setting adjustable parameters
   void              PeriodMA(int value)                 { m_ma_period=value;          }
   void              Shift(int value)                    { m_ma_shift=value;           }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_ma_applied=value;         }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   void              Pattern_1(int value)                { m_pattern_1=value;          }
   void              Pattern_2(int value)                { m_pattern_2=value;          }
   //--- method of verification of settings
   virtual bool      ValidationSettings();
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators* indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition();
   virtual int       ShortCondition();

protected:
   //--- method of initialization of the indicator
   bool              InitMA(CIndicators* indicators);
   //--- methods of getting data
   double            MA(int ind)                         { return(m_ma.Main(ind));     }
   double            DiffMA(int ind)                     { return(MA(ind)-MA(ind+1));  }
   double            DiffOpenMA(int ind)                 { return(Open(ind)-MA(ind));  }
   double            DiffHighMA(int ind)                 { return(High(ind)-MA(ind));  }
   double            DiffLowMA(int ind)                  { return(Low(ind)-MA(ind));   }
   double            DiffCloseMA(int ind)                { return(Close(ind)-MA(ind)); }
  };
//+------------------------------------------------------------------+
//| Constructor CSignalFrAMA.                                        |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CSignalFrAMA::CSignalFrAMA()
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
//--- setting default values for the indicator parameters
   m_ma_period =12;
   m_ma_shift  =0;
   m_ma_applied=PRICE_CLOSE;
//--- setting default "weights" of the market models
   m_pattern_0 =90;          // model 0 "price is on the necessary side from the indicator"
   m_pattern_1 =100;         // model 1 "price crossed the indicator with opposite direction"
   m_pattern_2 =80;          // model 2 "price crossed the indicator with the same direction"
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalFrAMA::ValidationSettings()
  {
//--- call of the method of the parent class
   if(!CExpertSignal::ValidationSettings()) return(false);
//--- initial data checks
   if(m_ma_period<=0)
     {
      printf(__FUNCTION__+": period MA must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalFrAMA::InitIndicators(CIndicators* indicators)
  {
//--- check pointer
   if(indicators==NULL)                           return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- create and initialize FrAMA indicator
   if(!InitMA(indicators))                        return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create MA indicators.                                            |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CSignalFrAMA::InitMA(CIndicators* indicators)
  {
//--- check pointer
   if(indicators==NULL) return(false);
//--- add indicator to collection
   if(!indicators.Add(GetPointer(m_ma)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize indicator
   if(!m_ma.Create(m_symbol.Name(),m_period,m_ma_period,m_ma_shift,m_ma_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: number of "votes" that price will grow.                  |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CSignalFrAMA::LongCondition()
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA(idx)<0.0)
     {
      //--- the close price is below the indicator
      if(DiffOpenMA(idx)>0.0 && DiffMA(idx)>0.0)
        {
         //--- the open price is above the indicator (i.e. there was an intersection), but the indicator is directed upwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
        }
     }
   else
     {
      //--- the close price is above the indicator (the indicator has no objections to buying)
      result=m_pattern_0;
      if(DiffMA(idx)>0.0)
        {
         //--- the indicator is directed upwards
         if(DiffOpenMA(idx)<0.0)
           {
            //--- the open price is below the indicator (i.e. there was an intersection)
            result=m_pattern_2;
            //--- suggest to enter the market at the "roll back"
            m_base_price=m_symbol.NormalizePrice(MA(idx));
           }
         else
           {
            //--- the open price is above the indicator
            if(DiffLowMA(idx)<0.0)
              {
               //--- the low price is below the indicator
               result=m_pattern_2;
               //--- consider that this is a formed "piercing" and suggest to enter the market at the current price
               m_base_price=0.0;
              }
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//| INPUT:  no.                                                      |
//| OUTPUT: number of "votes" that price will fall.                  |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CSignalFrAMA::ShortCondition()
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(DiffCloseMA(idx)>0.0)
     {
      //--- the close price is above the indicator
      if(DiffOpenMA(idx)>0.0 && DiffMA(idx)<0.0)
        {
         //--- the open price is below the indicator (i.e. there was an intersection), but the indicator is directed downwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
        }
     }
   else
     {
      //--- the close price is below the indicator (the indicator has no objections to buying)
      result=m_pattern_0;
      if(DiffMA(idx)<0.0)
        {
         //--- the indicator is directed downwards
         if(DiffOpenMA(idx)<0.0)
           {
            //--- the open price is above the indicator (i.e. there was an intersection)
            result=m_pattern_2;
            //--- suggest to enter the market at the "roll back"
            m_base_price=m_symbol.NormalizePrice(MA(idx));
           }
         else
           {
            //--- the open price is below the indicator
            if(DiffHighMA(idx)>0.0)
              {
               //--- the high price is above the indicator
               result=m_pattern_2;
               //--- consider that this is a formed "piercing" and suggest to enter the market at the current price
               m_base_price=0.0;
              }
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+