#property strict

// Parameters to define what constitutes a "boring candle"
input double BoringCandleThreshold = 50; // Maximum absolute difference between open and close to be considered boring (in points)

//+------------------------------------------------------------------+
//| Script initialization function                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
   // Get the number of bars on the chart
   int rates_total = Bars;
   
   // Loop through each candle on the chart
   for(int i = rates_total - 1; i >= 0; i--)
     {
      // Retrieve open, close, high, and time values using iSeries functions
      double openPrice = iOpen(Symbol(), PERIOD_CURRENT, i);
      double closePrice = iClose(Symbol(), PERIOD_CURRENT, i);
      double highPrice = iHigh(Symbol(), PERIOD_CURRENT, i);
      datetime time = iTime(Symbol(), PERIOD_CURRENT, i);
      
      // Define a boring candle as one with a small body size
      double bodySize = MathAbs(openPrice - closePrice);
      
      // If the body size is smaller than or equal to the threshold, it's a boring candle
      if(bodySize <= BoringCandleThreshold * _Point)
        {
         // Create an arrow above the boring candle to mark it
         string arrowName = "BoringArrow_" + IntegerToString(i);
         
         // Create the arrow above the candle
         ObjectCreate(0, arrowName, OBJ_ARROW, 0, time, highPrice + 10 * _Point); // Arrow above the candle
         
         // Set the properties for the arrow
         ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clrOrange);  // Set the arrow color to orange
         ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, 233);  // Arrow symbol code (can be changed)
        }
     }
  }
