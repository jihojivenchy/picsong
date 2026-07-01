import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/domain/entities/region/region.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 지역 선택 모드
enum RegionSelectionMode {
  single,
  multi,
}

class RegionPickerBottomSheet extends StatefulWidget {
  const RegionPickerBottomSheet({
    super.key,
    required this.selectedDistricts,
    required this.onRegionSelected,
    this.selectionMode = RegionSelectionMode.single,
  });

  final List<District> selectedDistricts;
  final RegionSelectionMode selectionMode;
  final Function(List<District> districts) onRegionSelected;

  ///
  /// 지역 선택 바텀 시트
  ///
  static void show(
    BuildContext context, {
    required List<District> selectedDistricts,
    required Function(List<District> districts) onRegionSelected,
    RegionSelectionMode selectionMode = RegionSelectionMode.single,
  }) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return RegionPickerBottomSheet(
          selectedDistricts: selectedDistricts,
          selectionMode: selectionMode,
          onRegionSelected: (districts) {
            Get.back();
            onRegionSelected(districts);
          },
        );
      },
    );
  }

  @override
  State<RegionPickerBottomSheet> createState() =>
      _RegionPickerBottomSheetState();
}

class _RegionPickerBottomSheetState extends State<RegionPickerBottomSheet> {
  int selectedCityIndex = 0;
  int selectedDistrictIndex = 0;
  late List<District> selectedDistricts;

  @override
  void initState() {
    super.initState();
    selectedDistricts = List<District>.from(widget.selectedDistricts);
    _syncSelectionFromInput();
  }

  @override
  void didUpdateWidget(covariant RegionPickerBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.selectedDistricts, widget.selectedDistricts)) {
      selectedDistricts = List<District>.from(widget.selectedDistricts);
      _syncSelectionFromInput();
    }
  }

  ///
  /// 외부에서 주입된 값 변경 시 내부 상태 동기화
  ///
  void _syncSelectionFromInput() {
    // 외부에서 주입된 값이 없으면 초기화
    if (selectedDistricts.isEmpty) {
      selectedCityIndex = 0;
      selectedDistrictIndex = 0;

      // 단일 선택 모드일 때 초기 선택 값 설정
      if (widget.selectionMode == RegionSelectionMode.single) {
        final district = Region
            .baseList[selectedCityIndex].districtList[selectedDistrictIndex];
        selectedDistricts = [district];
      }
      return;
    }

    // 초기 선택된 도시/구군 인덱스 찾기
    final initialDistrict = selectedDistricts.first;
    final foundCityIndex = Region.baseList.indexWhere(
      (element) => element.city == initialDistrict.cityType,
    );

    // 도시/구군 인덱스가 없으면 초기화
    if (foundCityIndex == -1) {
      selectedCityIndex = 0;
      selectedDistrictIndex = 0;
      return;
    }

    // 도시/구군 인덱스 설정
    selectedCityIndex = foundCityIndex;
    final foundDistrictIndex =
        Region.baseList[selectedCityIndex].districtList.indexWhere(
      (element) => element.name == initialDistrict.name,
    );

    // 구군 인덱스가 없으면 초기화
    selectedDistrictIndex = foundDistrictIndex == -1 ? 0 : foundDistrictIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: AppSpacing.xl),
            child: Container(
              width: 34,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.gray6F767F,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (widget.selectionMode == RegionSelectionMode.multi) ...[
            _buildSelectedBar(),
          ],
          Expanded(
            child: Row(
              children: [
                // 시도 리스트
                _buildCityList(),
                // 시군구 리스트
                _buildDistrictList(),
              ],
            ),
          ),
          const Gap(height: 10),
          AppButton(
            text: '완료',
            margin: 16,
            textColor: AppColors.white,
            fontSize: 16,
            onTapped: () {
              if (widget.selectionMode == RegionSelectionMode.single) {
                if (selectedDistricts.isEmpty) {
                  final district = Region.baseList[selectedCityIndex]
                      .districtList[selectedDistrictIndex];
                  widget.onRegionSelected([district]);
                  return;
                }
              }
              widget.onRegionSelected(List<District>.from(selectedDistricts));
            },
          ),
          const Gap(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  /// 시도 리스트
  Widget _buildCityList() {
    return Container(
      width: 170,
      color: AppColors.gray10,
      child: ListView.builder(
        itemCount: Region.baseList.length,
        itemBuilder: (context, index) {
          final region = Region.baseList[index];
          final isSelected = selectedCityIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCityIndex = index;
                selectedDistrictIndex = 0;
              });
            },
            child: Container(
              height: 48,
              color: isSelected ? Colors.white : AppColors.gray10,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  text: region.city.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.gray26282B
                      : AppColors.labelTertiary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 시군구 리스트
  Widget _buildDistrictList() {
    final selectedCity = Region.baseList[selectedCityIndex];
    final districtList = selectedCity.districtList;

    return Expanded(
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: districtList.length,
          itemBuilder: (context, index) {
            final district = districtList[index];
            final isSelected =
                widget.selectionMode == RegionSelectionMode.single
                    ? index == selectedDistrictIndex
                    : selectedDistricts.contains(district);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  if (widget.selectionMode == RegionSelectionMode.single) {
                    selectedDistrictIndex = index;
                    selectedDistricts = [district];
                    return;
                  }

                  if (selectedDistricts.contains(district)) {
                    selectedDistricts.remove(district);
                  } else {
                    selectedDistricts.add(district);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                height: 48,
                color: isSelected ? AppColors.grayF1F1F1 : Colors.white,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    text: district.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.gray26282B
                        : AppColors.labelTertiary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 멀티 선택된 지역 표시 바
  Widget _buildSelectedBar() {
    if (selectedDistricts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xl),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: selectedDistricts.length,
            separatorBuilder: (_, __) => const Gap(width: 6),
            itemBuilder: (context, index) {
              final district = selectedDistricts[index];

              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppText(
                    text: district.fullName,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
