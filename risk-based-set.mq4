//+------------------------------------------------------------------+
//| Universal Risk-Based Pending Order Script                        |
//| Supports: Buy Limit, Sell Limit, Buy Stop, Sell Stop             |
//| Calculates volume based on % risk and SL distance                |
//+------------------------------------------------------------------+
#property strict

// === USER INPUTS ===
enum OrderType {
   Buy_Limit = 0,
   Sell_Limit,
   Buy_Stop,
   Sell_Stop
};

input OrderType PendingOrderType = Sell_Limit; // Select order type
input double RiskPercent       = 1.0;           // Risk per trade in %
input double EntryPrice        = 0.65610;       // Pending entry price
input double StopLossPrice     = 0.65790;       // Stop Loss price
input double TakeProfitPrice   = 0.65249;       // Take Profit price
input string OrderComment      = "Auto Risk Pending Order";

// === INTERNAL FUNCTION ===
void OnStart()
{
   double balance = AccountBalance();
   double riskAmount = balance * (RiskPercent / 100.0);
   double slPips = MathAbs(EntryPrice - StopLossPrice) / Point;

   if (slPips <= 0) {
      Print("❌ Stop Loss must differ from Entry Price.");
      return;
   }

   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotSize = NormalizeDouble(riskAmount / (slPips * tickValue), 2);

   int orderType = -1;
   string orderTypeName = "";

   switch (PendingOrderType)
   {
      case Buy_Limit:  orderType = OP_BUYLIMIT;  orderTypeName = "Buy Limit";  break;
      case Sell_Limit: orderType = OP_SELLLIMIT; orderTypeName = "Sell Limit"; break;
      case Buy_Stop:   orderType = OP_BUYSTOP;   orderTypeName = "Buy Stop";   break;
      case Sell_Stop:  orderType = OP_SELLSTOP;  orderTypeName = "Sell Stop";  break;
      default:         Print("❌ Invalid order type."); return;
   }

   int ticket = OrderSend(
      Symbol(),
      orderType,
      lotSize,
      EntryPrice,
      3,
      StopLossPrice,
      TakeProfitPrice,
      OrderComment,
      0,
      0,
      clrAqua
   );

   if (ticket < 0)
   {
      Print("❌ OrderSend failed. Error code: ", GetLastError());
   }
   else
   {
      Print("✅ ", orderTypeName, " placed. Ticket #", ticket);
      Print("Lot Size: ", lotSize, " | Risk: $", riskAmount, " | SL (pips): ", slPips);
   }
}
