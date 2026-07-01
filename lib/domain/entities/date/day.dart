/// 달력 시작 요일
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class Day {
  final DateTime date;
  final bool isOutside;
  final DayCellState state;

  const Day({required this.date, required this.isOutside, required this.state});

  @override
  String toString() {
    return 'Day(day: ${date.day}, isOutside: $isOutside)';
  }

  static Day today = Day(
    date: DateTime.now(),
    isOutside: false,
    state: DayCellState.today,
  );
}

enum DayCellState { basic, sunday, saturday, today }
