//+------------------------------------------------------------------+
//|                                              GUI_EA_Latest.mq4   |
//|   Risk-Based Pending Order EA with GUI Panel for MT4            |
//+------------------------------------------------------------------+
#property strict
#include <Controls\\Dialog.mqh>
#include <Controls\\Button.mqh>
#include <Controls\\Edit.mqh>
#include <Controls\\ComboBox.mqh>
#include <Controls\\Label.mqh>

CDialog panel;
CComboBox comboOrderType;
CEdit inputEntry, inputSL, inputTP, inputRisk;
CButton btnPlaceOrder;
CLabel lblResult;

enum OrderTypes {
   Buy_Limit = 0,
   Sell_Limit,
   Buy_Stop,
   Sell_Stop
};

//+------------------------------------------------------------------+
int OnInit()
{
   int x = 20, y = 20, w = 200, h = 25;

   panel.Create(0, "RiskOrderPanel", 0, 10, 10, 260, 240);
   panel.Caption("Risk-Based Order Panel");

   comboOrderType.Create(panel, "orderType", x, y, w, h);
   comboOrderType.AddItem("Buy Limit", Buy_Limit);
   comboOrderType.AddItem("Sell Limit", Sell_Limit);
   comboOrderType.AddItem("Buy Stop", Buy_Stop);
   comboOrderType.AddItem("Sell Stop", Sell_Stop);
   comboOrderType.Select(1); y += 30;

   inputEntry.Create(panel, "entry", x, y, w, h); inputEntry.Text(DoubleToString(Bid, Digits)); inputEntry.Caption("Entry Price"); y += 30;
   inputSL.Create(panel, "sl", x, y, w, h); inputSL.Text(DoubleToString(Bid + 0.0010, Digits)); inputSL.Caption("Stop Loss"); y += 30;
   inputTP.Create(panel, "tp", x, y, w, h); inputTP.Text(DoubleToString(Bid - 0.0020, Digits)); inputTP.Caption("Take Profit"); y += 30;
   inputRisk.Create(panel, "risk", x, y, w, h); inputRisk.Text("1.0"); inputRisk.Caption("Risk %"); y += 30;

   btnPlaceOrder.Create(panel, "placeOrder", x, y, w, h); btnPlaceOrder.Text("Place Order"); y += 30;
   lblResult.Create(panel, "result", x, y, 300, h); lblResult.Text("Ready");

   panel.Run();
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) { panel.Destroy(reason); }

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   panel.ChartEvent(id, lparam, dparam, sparam);

   if (id == CHARTEVENT_BUTTON_CLICK && sparam == "placeOrder")
   {
      int selType = comboOrderType.Value();
      double entry = StringToDouble(inputEntry.Text());
      double sl = StringToDouble(inputSL.Text());
      double tp = StringToDouble(inputTP.Text());
      double riskPercent = StringToDouble(inputRisk.Text());

      if (sl == entry || riskPercent <= 0 || entry <= 0 || sl <= 0 || tp <= 0)
      {
         lblResult.Text("❌ Invalid input values.");
         return;
      }

      double slPips = MathAbs(entry - sl) / Point;
      double riskAmount = AccountBalance() * (riskPercent / 100.0);
      double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
      double lotSize = NormalizeDouble(riskAmount / (slPips * tickValue), 2);

      int mt4OrderType;
      switch (selType)
      {
         case Buy_Limit:  mt4OrderType = OP_BUYLIMIT; break;
         case Sell_Limit: mt4OrderType = OP_SELLLIMIT; break;
         case Buy_Stop:   mt4OrderType = OP_BUYSTOP; break;
         case Sell_Stop:  mt4OrderType = OP_SELLSTOP; break;
         default: lblResult.Text("❌ Invalid order type."); return;
      }

      int ticket = OrderSend(Symbol(), mt4OrderType, lotSize, entry, 3, sl, tp, "GUI Risk EA", 0, 0, clrDodgerBlue);
      if (ticket < 0)
         lblResult.Text("❌ Error: " + IntegerToString(GetLastError()));
      else
         lblResult.Text("✅ Order Placed. Ticket #" + IntegerToString(ticket));
   }
}
