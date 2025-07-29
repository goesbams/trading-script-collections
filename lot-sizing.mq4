//+------------------------------------------------------------------+
//| Script to place a Sell Limit order with risk-based lot sizing   |
//+------------------------------------------------------------------+
#property strict

// User Inputs
input double RiskPercent = 1.0;        // Risk per trade (%)
input double StopLossPips = 18;        // Stop Loss in pips
input double EntryPrice = 0.65610;     // Entry (Sell Limit) price
input double TakeProfitPrice = 0.65249; // Take Profit price
input double StopLossPrice = 0.65790;   // Stop Loss price
input string OrderComment = "RiskBasedSellLimit";

void OnStart()
{
   double accountBalance = AccountBalance();
   double riskAmount = accountBalance * (RiskPercent / 100.0);
   
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double slPoints = StopLossPips * 10; // Convert pips to points (MT4 uses points)
   
   // Calculate lot size
   double lotSize = NormalizeDouble(riskAmount / (StopLossPips * tickValue / 10.0), 2);
   
   // Place Sell Limit order
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
      0,
      clrRed
   );
   
   if (ticket < 0)
   {
      Print("OrderSend failed with error: ", GetLastError());
   }
   else
   {
      Print("Sell Limit Order placed. Ticket #: ", ticket);
   }
}
