enum ViewMode {
  weekly(7),
  monthly(31),
  sixMonth(26),
  year(12);

  const ViewMode(this.dayCount);

  /// The count of blocks in the x-axis direction.
  final int dayCount;
}
