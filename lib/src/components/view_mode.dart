////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// ViewMode is an enum that contains the various view modes that are avaliable
/// for each graph type.
///////////////////////////////////////////////////////////////////

enum ViewMode {
  hourly(24),
  weekly(7),
  monthly(31),
  sixMonth(26),
  year(12);

  const ViewMode(this.dayCount);

  /// The count of blocks in the x-axis direction.
  final int dayCount;
}
