////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// ChartType Enum defines the valid chart types avaliable in the packge.
///
/// AmountChart - Typical bar chart. Can be used to plot doubles or total hours from DateTimeRanges.
/// TimeChart - Plots time chunks on a graph that display when an event started and when an event ended.
///             Works best with DateTimeRanges or DateTime objects.
///////////////////////////////////////////////////////////////////

enum ChartType {
  time,
  amount,
}
