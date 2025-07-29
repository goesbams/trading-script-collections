//+------------------------------------------------------------------+
//| Risk-based Sell Limit Script for MT4                            |
//| Inputs: SL, Entry, TP, Risk %                                   |
//| Output: Auto-calculated lot size & Sell Limit order             |
//+------------------------------------------------------------------+
#property strict

// === USER INPUTS ===
input double RiskPercent       = 1.0;        // Risk per trade in %
input double EntryPrice        = 0.65610;    // Entry price (Sell Limit)
input double StopLossPrice     = 0.65790;    // Stop Loss price
input double TakeProfitPrice   = 0.65249;    // Take Profit price
input string OrderComment      = "Auto SL TP Risk";

// === INTERNAL CALCULATIONS ===
void OnStart()
{
   double accountBalance = AccountBalance();
   double riskAmount = accountBalance * (RiskPercent / 100.0);
   
   double slInPips = MathAbs(StopLossPrice - EntryPrice) / Point;
   double pipValuePerLot = MarketInfo(Symbol(), MODE_TICKVALUE);
   
   // Calculate lot size
   double lotSize = NormalizeDouble(riskAmount / (slInPips * pipValuePerLot), 2);
   
   // Place Sell Limit Order
   int ticket = OrderSend(
      Symbol(),
      OP_SELLLIMIT,
      lotSize,
      EntryPrice,
      3,
      StopLossPrice,
      TakeProfitPrice,
      OrderComment,
      0,
      clrRed
   );

   if (ticket < 0)
   {
      Print("❌ OrderSend failed: ", GetLastError());
   }
   else
   {
      Print("✅ Sell Limit Order Placed — Ticket #: ", ticket);
      Print("Lot Size: ", lotSize, " | Risk: $", riskAmount, " | SL (pips): ", slInPips);
   }
}


