import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import '../../../../domain/entities/date/app_date.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class DatePickerBottomSheet extends StatefulWidget {
  const DatePickerBottomSheet({
    super.key,
    required this.birthDate,
    required this.onChangeDate,
    this.yearList,
  });

  final AppDate birthDate;
  final List<String>? yearList;

  final void Function(AppDate date) onChangeDate;

  /// 바텀 시트 표시
  static void show(
    BuildContext context, {
    required AppDate birthDate,
    required void Function(AppDate date) onChangeDate,
    List<String>? yearList,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DatePickerBottomSheet(
        birthDate: birthDate,
        onChangeDate: (date) {
          Get.back();
          onChangeDate(date);
        },
        yearList: yearList,
      ),
    );
  }

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  List<String> _yearList = []; // 년도 리스트
  List<String> _monthList = [];
  List<String> _dayList = [];

  late String _selectedYear; // 년
  late String _selectedMonth; // 월
  late String _selectedDay; // 일

  FixedExtentScrollController? _yearPickerController;
  FixedExtentScrollController? _monthPickerController;
  FixedExtentScrollController? _dayPickerController;

  @override
  void initState() {
    super.initState();
    // 외부로부터 전달받은 년도 리스트가 없으면 새로 생성 (현재 년도부터 과거 100년)
    if (widget.yearList == null) {
      final currentYear = DateTime.now().year;
      _yearList = List.generate(
        100,
        (index) => (currentYear - index).toString(),
      );
    } else {
      _yearList = widget.yearList!;
    }

    // 월 리스트 생성 (01-12)
    _monthList = List.generate(
      12,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );

    final now = DateTime.now();

    // 선택된 년도를 설정
    _selectedYear = widget.birthDate.year.isEmpty
        ? now.year.toString()
        : widget.birthDate.year;

    // 선택된 월을 설정
    _selectedMonth = widget.birthDate.month.isEmpty
        ? now.month.toString()
        : widget.birthDate.month;

    // 선택된 일을 설정
    _selectedDay = widget.birthDate.day.isEmpty
        ? now.day.toString()
        : widget.birthDate.day;

    // 해당 월에 맞는 일 리스트 생성
    _updateDaysForSelectedMonthAndYear();

    // 초기 스크롤 컨트롤러 설정
    _initScrollControllers();
  }

  @override
  void dispose() {
    _yearPickerController?.dispose();
    _monthPickerController?.dispose();
    _dayPickerController?.dispose();
    super.dispose();
  }

  ///
  /// 컨트롤러 초기화
  ///
  void _initScrollControllers() {
    // 선택된 값의 인덱스 찾기
    final yearIndex = _yearList.indexOf(_selectedYear);
    final monthIndex = int.parse(_selectedMonth) - 1; // 월은 1부터 시작하므로 -1
    final dayIndex = int.parse(_selectedDay) - 1; // 일은 1부터 시작하므로 -1

    // 각 피커의 초기 위치를 설정하는 ScrollController
    _yearPickerController = FixedExtentScrollController(
      initialItem: yearIndex >= 0 ? yearIndex : 0,
    );
    _monthPickerController = FixedExtentScrollController(
      initialItem: monthIndex >= 0 ? monthIndex : 0,
    );
    _dayPickerController = FixedExtentScrollController(
      initialItem: dayIndex >= 0 ? dayIndex : 0,
    );
  }

  ///
  /// 선택한 연도와 월을 가지고 일수 계산
  ///
  void _updateDaysForSelectedMonthAndYear() {
    final year = int.parse(_selectedYear);
    final month = int.parse(_selectedMonth);

    // 해당 월의 일수 계산
    final daysInMonth = _getDaysInMonth(year, month);

    // 1부터 해당 월의 마지막 날까지의 일 리스트 생성
    _dayList = List.generate(
      daysInMonth,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );

    // 선택된 일이 현재 월의 최대 일수를 초과하는 경우 조정
    if (int.parse(_selectedDay) > daysInMonth) {
      _selectedDay = daysInMonth.toString().padLeft(2, '0');
      // 컨트롤러가 이미 초기화된 경우에만 점프
      if (_dayPickerController != null) {
        _dayPickerController!.jumpToItem(daysInMonth - 1);
      }
    }
  }

  ///
  /// 해당 월의 일수 계산
  ///
  int _getDaysInMonth(int year, int month) {
    // 각 월의 일수
    const daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // 2월이고 윤년인 경우 29일, 아니면 해당 월의 기본 일수
    if (month == 2 && _isLeapYear(year)) {
      return 29;
    }

    return daysInMonth[month];
  }

  ///
  /// 윤년 계산
  ///
  bool _isLeapYear(int year) {
    // 4로 나누어 떨어지고, 100으로 나누어 떨어지지 않거나 400으로 나누어 떨어지는 해
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(height: 10),
            Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.gray30,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Gap(height: AppSpacing.xl),
            AppText(
              text: '날짜 선택',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray50,
            ),
            const Gap(height: AppSpacing.sm),
            SizedBox(
              width: 230,
              height: 120,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white,
                      Colors.white.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _yearPickerController,
                        backgroundColor: Colors.transparent,
                        itemExtent: 40,
                        diameterRatio: 20,
                        squeeze: 1.2,
                        selectionOverlay: null,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedYear = _yearList[index];
                            _updateDaysForSelectedMonthAndYear();
                          });
                        },
                        children: _yearList
                            .map(
                              (year) => Center(
                                child: AppText(
                                  text: year,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.basicText,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _monthPickerController,
                        backgroundColor: Colors.transparent,
                        itemExtent: 40,
                        diameterRatio: 20,
                        squeeze: 1.2,
                        selectionOverlay: null,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMonth = _monthList[index];
                            _updateDaysForSelectedMonthAndYear();
                          });
                        },
                        children: _monthList.map((month) {
                          return Center(
                            child: AppText(
                              text: month,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.basicText,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _dayPickerController,
                        backgroundColor: Colors.transparent,
                        itemExtent: 40,
                        diameterRatio: 20,
                        squeeze: 1.2,
                        selectionOverlay: null,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedDay = _dayList[index];
                          });
                        },
                        children: _dayList.map((day) {
                          return Center(
                            child: AppText(
                              text: day,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.basicText,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(height: 30),
            AppButton(
              text: '확인',
              margin: 0,
              onTapped: () {
                widget.onChangeDate(
                  AppDate(
                    year: _selectedYear,
                    month: _selectedMonth,
                    day: _selectedDay,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
