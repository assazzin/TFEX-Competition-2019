//+------------------------------------------------------------------+
//|                                                          555.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int lot = 1;
float prevHigh;
float prevLow;
float buySignal;
float sellSignal;
int indexBar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   indexBar = 0;
   do {
      indexBar++;
      prevHigh = High[indexBar];
      prevLow = Low[indexBar];

     buySignal = ((prevHigh - prevLow) * 0.66) + prevLow;
     sellSignal = ((prevHigh - prevLow) * 0.33) + prevLow;
   } while(buySignal - sellSignal < 2);
   
   if(Close[0] >= buySignal && hasLong() == false) {
      closeAll();
      OrderSend(Symbol(), OP_BUY, lot, Ask, 999, 0, 0);
   }
   
   else if(Close[0] <= sellSignal && hasShort() == false) {
      closeAll();
      OrderSend(Symbol(), OP_SELL, lot, Ask, 999, 0, 0);
   }
  }
//+------------------------------------------------------------------+

bool hasShort() {
   for(int i=0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == OP_SELL) {
         return true;
      }
   }
   return false;
}

bool hasLong() {
   for(int i=0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == OP_BUY) {
         return true;
      }
   }
   return false;
}

int closeAll()
{
   double total;
   int cnt;
   while(OrdersTotal()>0)
   {
      // close opened orders first
      total = OrdersTotal();
      for (cnt = total-1; cnt >=0 ; cnt--)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            switch(OrderType())
            {
               case OP_BUY       :
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Violet);break;
                   
               case OP_SELL      :
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,Violet); break;
            }             
         }
      }
      // and close pending
      total = OrdersTotal();      
      for (cnt = total-1; cnt >=0 ; cnt--)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            switch(OrderType())
            {
               case OP_BUYLIMIT  :OrderDelete(OrderTicket()); break;
               case OP_SELLLIMIT :OrderDelete(OrderTicket()); break;
               case OP_BUYSTOP   :OrderDelete(OrderTicket()); break;
               case OP_SELLSTOP  :OrderDelete(OrderTicket()); break;
            }
         }
      }
   }
   return(0);
}
