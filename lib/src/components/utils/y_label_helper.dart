////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// YLabelCalculator is used to calculate the nearest dividens for the X Axis Labels.
///
/// This ensure that the Y axis labels are clean numbers and look less arbitrary/ random.
///////////////////////////////////////////////////////////////////

class YLabelCalculator {
  // JS - nearestUpperDividend Rounds n to the nearest UPPER m.
  // Example:
  // N = 103
  // M = 10
  // Output would be 110 since 110 is the closest upper number to 103 that is also divisible by 10.
  static int nearestUpperDividend(int n, int m) {
    // Quotiant of the two values
    int q = 0;
    // First possibility for rounding. (Not used currently. Holds the value of the lower rounding outcome. Could be used later.)
    int n1 = 0;
    // Second possibility for rounding.
    int n2 = 0;

    q = (n / m).floor();
    n1 = m * q;

    if ((n * m) > 0) {
      n2 = m * (q + 1);
    } else {
      n2 = m * (q - 1);
    }

    return n2; // Will be the upper dividend
  }

  // JS - timeStep calculates the amount of hours between each Y Axis label.
  // If the max value passed in is divisble by 3 then we will have 4 Y-axis labels (including 0)
  // If the max value passed in is divisble by 4 then we will have 5 Y-axis labels (including 0)
  // If neither is true then we will keep it safe and just use the y max and 0 to ensure a clean graph.
  static int timeStep(int max) {
    int timeStep = max;

    if (max % 3 == 0) {
      timeStep = (max / 3).floor();
    }
    if (max % 4 == 0) {
      timeStep = (max / 4).floor();
    }

    return timeStep;
  }

  // JS - nearestCustomUpperDividend Rounds n to the nearest UPPER m that is ALSO divisble by 3 or 4.
  // NOTE: Due to the complexity of finding a number closest to x that is a multiple of y and divisible by z a while
  //       loop is used to check each multiple of 5. However due to the frequency of true conditions time complexity should not be an issue.
  static int customNearestUpperDividend(int max) {
    int customDividend = nearestDividend(max, 5);

    while ((customDividend % 3 != 0) && (customDividend % 4 != 0)) {
      customDividend = customDividend + 5;
    }
    return customDividend;
  }

  // JS - nearestDividend Rounds n to the nearest m.
  // Example:
  // N = 103
  // M = 10
  // Output would be 100 since 100 is the closest number to 103 that is also divisible by 10.
  static int nearestDividend(int n, int m) {
    // Quotiant of the two values
    int q = 0;
    // First possibility for rounding. (Not used currently. Holds the value of the lower rounding outcome. Could be used later.)
    int n1 = 0;
    // Second possibility for rounding.
    int n2 = 0;

    q = (n / m).floor();
    n1 = m * q;

    if ((n * m) > 0) {
      n2 = m * (q + 1);
    } else {
      n2 = m * (q - 1);
    }

    if ((n - n1).abs() < (n - n2).abs()) {
      return n1; // Will be the lower dividend
    }

    return n2; // Will be the upper dividend
  }
}
