enum CityType {
  seoul(name: '서울특별시', queryValue: '서울'),
  incheon(name: '인천광역시', queryValue: '인천'),
  busan(name: '부산광역시', queryValue: '부산'),
  daejeon(name: '대전광역시', queryValue: '대전'),
  daegu(name: '대구광역시', queryValue: '대구'),
  ulsan(name: '울산광역시', queryValue: '울산'),
  gwangju(name: '광주광역시', queryValue: '광주'),
  jeju(name: '제주특별자치도', queryValue: '제주'),
  sejong(name: '세종특별자치시', queryValue: '세종'),
  gyeonggi(name: '경기도', queryValue: '경기도'),
  gangwon(name: '강원도', queryValue: '강원도'),
  chungcheongbuk(name: '충청북도', queryValue: '충청북도'),
  chungcheongnam(name: '충청남도', queryValue: '충청남도'),
  gyeongsangbuk(name: '경상북도', queryValue: '경상북도'),
  gyeongsangnam(name: '경상남도', queryValue: '경상남도'),
  jeonbuk(name: '전라북도', queryValue: '전라북도'),
  jeonnam(name: '전라남도', queryValue: '전라남도'),
  none(name: '', queryValue: null);

  final String name;
  final String? queryValue;

  const CityType({
    required this.name,
    required this.queryValue,
  });

  static CityType fromQueryValue(String? query) {
    if (query == null) {
      return CityType.none;
    }

    return CityType.values.firstWhere(
      (e) => e.queryValue == query,
      orElse: () => CityType.none,
    );
  }
}

class Region {
  final CityType city; // 시도
  final List<District> districtList; // 시군구 리스트

  Region({
    required this.city,
    required this.districtList,
  });

  static List<Region> baseList = [
    Region(
      city: CityType.seoul,
      districtList: [
        District(cityType: CityType.seoul, name: "강남구"),
        District(cityType: CityType.seoul, name: "강동구"),
        District(cityType: CityType.seoul, name: "강북구"),
        District(cityType: CityType.seoul, name: "강서구"),
        District(cityType: CityType.seoul, name: "관악구"),
        District(cityType: CityType.seoul, name: "광진구"),
        District(cityType: CityType.seoul, name: "구로구"),
        District(cityType: CityType.seoul, name: "금천구"),
        District(cityType: CityType.seoul, name: "노원구"),
        District(cityType: CityType.seoul, name: "도봉구"),
        District(cityType: CityType.seoul, name: "동대문구"),
        District(cityType: CityType.seoul, name: "동작구"),
        District(cityType: CityType.seoul, name: "마포구"),
        District(cityType: CityType.seoul, name: "서대문구"),
        District(cityType: CityType.seoul, name: "서초구"),
        District(cityType: CityType.seoul, name: "성동구"),
        District(cityType: CityType.seoul, name: "성북구"),
        District(cityType: CityType.seoul, name: "송파구"),
        District(cityType: CityType.seoul, name: "양천구"),
        District(cityType: CityType.seoul, name: "영등포구"),
        District(cityType: CityType.seoul, name: "용산구"),
        District(cityType: CityType.seoul, name: "은평구"),
        District(cityType: CityType.seoul, name: "종로구"),
        District(cityType: CityType.seoul, name: "중구"),
        District(cityType: CityType.seoul, name: "중랑구"),
      ],
    ),
    Region(
      city: CityType.incheon,
      districtList: [
        District(cityType: CityType.incheon, name: "계양구"),
        District(cityType: CityType.incheon, name: "남동구"),
        District(cityType: CityType.incheon, name: "동구"),
        District(cityType: CityType.incheon, name: "미추홀구"),
        District(cityType: CityType.incheon, name: "부평구"),
        District(cityType: CityType.incheon, name: "서구"),
        District(cityType: CityType.incheon, name: "연수구"),
        District(cityType: CityType.incheon, name: "중구"),
      ],
    ),
    Region(
      city: CityType.busan,
      districtList: [
        District(cityType: CityType.busan, name: "강서구"),
        District(cityType: CityType.busan, name: "금정구"),
        District(cityType: CityType.busan, name: "남구"),
        District(cityType: CityType.busan, name: "동구"),
        District(cityType: CityType.busan, name: "동래구"),
        District(cityType: CityType.busan, name: "부산진구"),
        District(cityType: CityType.busan, name: "북구"),
        District(cityType: CityType.busan, name: "사상구"),
        District(cityType: CityType.busan, name: "사하구"),
        District(cityType: CityType.busan, name: "서구"),
        District(cityType: CityType.busan, name: "수영구"),
        District(cityType: CityType.busan, name: "연제구"),
        District(cityType: CityType.busan, name: "영도구"),
        District(cityType: CityType.busan, name: "중구"),
        District(cityType: CityType.busan, name: "해운대구"),
      ],
    ),
    Region(
      city: CityType.daejeon,
      districtList: [
        District(cityType: CityType.daejeon, name: "대덕구"),
        District(cityType: CityType.daejeon, name: "동구"),
        District(cityType: CityType.daejeon, name: "서구"),
        District(cityType: CityType.daejeon, name: "유성구"),
        District(cityType: CityType.daejeon, name: "중구"),
      ],
    ),
    Region(
      city: CityType.daegu,
      districtList: [
        District(cityType: CityType.daegu, name: "남구"),
        District(cityType: CityType.daegu, name: "달서구"),
        District(cityType: CityType.daegu, name: "달서군"),
        District(cityType: CityType.daegu, name: "동구"),
        District(cityType: CityType.daegu, name: "북구"),
        District(cityType: CityType.daegu, name: "서구"),
        District(cityType: CityType.daegu, name: "수성구"),
        District(cityType: CityType.daegu, name: "중구"),
      ],
    ),
    Region(
      city: CityType.ulsan,
      districtList: [
        District(cityType: CityType.ulsan, name: "남구"),
        District(cityType: CityType.ulsan, name: "동구"),
        District(cityType: CityType.ulsan, name: "북구"),
        District(cityType: CityType.ulsan, name: "중구"),
        District(cityType: CityType.ulsan, name: "울주군"),
      ],
    ),
    Region(
      city: CityType.gwangju,
      districtList: [
        District(cityType: CityType.gwangju, name: "광산구"),
        District(cityType: CityType.gwangju, name: "남구"),
        District(cityType: CityType.gwangju, name: "동구"),
        District(cityType: CityType.gwangju, name: "북구"),
        District(cityType: CityType.gwangju, name: "서구"),
      ],
    ),
    Region(
      city: CityType.jeju,
      districtList: [
        District(cityType: CityType.jeju, name: "서귀포시"),
        District(cityType: CityType.jeju, name: "제주시"),
      ],
    ),
    Region(
      city: CityType.sejong,
      districtList: [
        District(cityType: CityType.sejong, name: "세종특별자치시"),
      ],
    ),
    Region(
      city: CityType.gyeonggi,
      districtList: [
        District(cityType: CityType.gyeonggi, name: "고양시"),
        District(cityType: CityType.gyeonggi, name: "과천시"),
        District(cityType: CityType.gyeonggi, name: "광명시"),
        District(cityType: CityType.gyeonggi, name: "광주시"),
        District(cityType: CityType.gyeonggi, name: "구리시"),
        District(cityType: CityType.gyeonggi, name: "군포시"),
        District(cityType: CityType.gyeonggi, name: "김포시"),
        District(cityType: CityType.gyeonggi, name: "남양주시"),
        District(cityType: CityType.gyeonggi, name: "동두천시"),
        District(cityType: CityType.gyeonggi, name: "부천시"),
        District(cityType: CityType.gyeonggi, name: "성남시"),
        District(cityType: CityType.gyeonggi, name: "수원시"),
        District(cityType: CityType.gyeonggi, name: "시흥시"),
        District(cityType: CityType.gyeonggi, name: "안산시"),
        District(cityType: CityType.gyeonggi, name: "안성시"),
        District(cityType: CityType.gyeonggi, name: "안양시"),
        District(cityType: CityType.gyeonggi, name: "양주시"),
        District(cityType: CityType.gyeonggi, name: "여주시"),
        District(cityType: CityType.gyeonggi, name: "오산시"),
        District(cityType: CityType.gyeonggi, name: "용인시"),
        District(cityType: CityType.gyeonggi, name: "의왕시"),
        District(cityType: CityType.gyeonggi, name: "의정부시"),
        District(cityType: CityType.gyeonggi, name: "이천시"),
        District(cityType: CityType.gyeonggi, name: "파주시"),
        District(cityType: CityType.gyeonggi, name: "평택시"),
        District(cityType: CityType.gyeonggi, name: "포천시"),
        District(cityType: CityType.gyeonggi, name: "하남시"),
        District(cityType: CityType.gyeonggi, name: "화성시"),
        District(cityType: CityType.gyeonggi, name: "가평군"),
        District(cityType: CityType.gyeonggi, name: "양평군"),
        District(cityType: CityType.gyeonggi, name: "연천군"),
      ],
    ),
    Region(
      city: CityType.gangwon,
      districtList: [
        District(cityType: CityType.gangwon, name: "강릉시"),
        District(cityType: CityType.gangwon, name: "동해시"),
        District(cityType: CityType.gangwon, name: "삼척시"),
        District(cityType: CityType.gangwon, name: "속초시"),
        District(cityType: CityType.gangwon, name: "원주시"),
        District(cityType: CityType.gangwon, name: "춘천시"),
        District(cityType: CityType.gangwon, name: "태백시"),
        District(cityType: CityType.gangwon, name: "고성군"),
        District(cityType: CityType.gangwon, name: "양구군"),
        District(cityType: CityType.gangwon, name: "양양군"),
        District(cityType: CityType.gangwon, name: "영월군"),
        District(cityType: CityType.gangwon, name: "인제군"),
        District(cityType: CityType.gangwon, name: "정선군"),
        District(cityType: CityType.gangwon, name: "철원군"),
        District(cityType: CityType.gangwon, name: "평창군"),
        District(cityType: CityType.gangwon, name: "홍천군"),
        District(cityType: CityType.gangwon, name: "화천군"),
        District(cityType: CityType.gangwon, name: "횡성군"),
      ],
    ),
    Region(
      city: CityType.chungcheongbuk,
      districtList: [
        District(cityType: CityType.chungcheongbuk, name: "제천시"),
        District(cityType: CityType.chungcheongbuk, name: "청주시"),
        District(cityType: CityType.chungcheongbuk, name: "충주시"),
        District(cityType: CityType.chungcheongbuk, name: "괴산군"),
        District(cityType: CityType.chungcheongbuk, name: "단양군"),
        District(cityType: CityType.chungcheongbuk, name: "보은군"),
        District(cityType: CityType.chungcheongbuk, name: "영동군"),
        District(cityType: CityType.chungcheongbuk, name: "옥천군"),
        District(cityType: CityType.chungcheongbuk, name: "음성군"),
        District(cityType: CityType.chungcheongbuk, name: "증평군"),
        District(cityType: CityType.chungcheongbuk, name: "진천군"),
      ],
    ),
    Region(
      city: CityType.chungcheongnam,
      districtList: [
        District(cityType: CityType.chungcheongnam, name: "계룡시"),
        District(cityType: CityType.chungcheongnam, name: "공주시"),
        District(cityType: CityType.chungcheongnam, name: "논산시"),
        District(cityType: CityType.chungcheongnam, name: "당진시"),
        District(cityType: CityType.chungcheongnam, name: "보령시"),
        District(cityType: CityType.chungcheongnam, name: "서산시"),
        District(cityType: CityType.chungcheongnam, name: "아산시"),
        District(cityType: CityType.chungcheongnam, name: "천안시"),
        District(cityType: CityType.chungcheongnam, name: "금산군"),
        District(cityType: CityType.chungcheongnam, name: "부여군"),
        District(cityType: CityType.chungcheongnam, name: "서천군"),
        District(cityType: CityType.chungcheongnam, name: "예산군"),
        District(cityType: CityType.chungcheongnam, name: "청양군"),
        District(cityType: CityType.chungcheongnam, name: "태안군"),
        District(cityType: CityType.chungcheongnam, name: "홍성군"),
      ],
    ),
    Region(
      city: CityType.gyeongsangbuk,
      districtList: [
        District(cityType: CityType.gyeongsangbuk, name: "경산시"),
        District(cityType: CityType.gyeongsangbuk, name: "경주시"),
        District(cityType: CityType.gyeongsangbuk, name: "구미시"),
        District(cityType: CityType.gyeongsangbuk, name: "김천시"),
        District(cityType: CityType.gyeongsangbuk, name: "문경시"),
        District(cityType: CityType.gyeongsangbuk, name: "상주시"),
        District(cityType: CityType.gyeongsangbuk, name: "안동시"),
        District(cityType: CityType.gyeongsangbuk, name: "영주시"),
        District(cityType: CityType.gyeongsangbuk, name: "영천시"),
        District(cityType: CityType.gyeongsangbuk, name: "포항시"),
        District(cityType: CityType.gyeongsangbuk, name: "고령군"),
        District(cityType: CityType.gyeongsangbuk, name: "군위군"),
        District(cityType: CityType.gyeongsangbuk, name: "봉화군"),
        District(cityType: CityType.gyeongsangbuk, name: "성주군"),
        District(cityType: CityType.gyeongsangbuk, name: "영덕군"),
        District(cityType: CityType.gyeongsangbuk, name: "영양군"),
        District(cityType: CityType.gyeongsangbuk, name: "예천군"),
        District(cityType: CityType.gyeongsangbuk, name: "울릉군"),
        District(cityType: CityType.gyeongsangbuk, name: "울진군"),
        District(cityType: CityType.gyeongsangbuk, name: "의성군"),
        District(cityType: CityType.gyeongsangbuk, name: "청도군"),
        District(cityType: CityType.gyeongsangbuk, name: "청송군"),
        District(cityType: CityType.gyeongsangbuk, name: "칠곡군"),
      ],
    ),
    Region(
      city: CityType.gyeongsangnam,
      districtList: [
        District(cityType: CityType.gyeongsangnam, name: "거제시"),
        District(cityType: CityType.gyeongsangnam, name: "김해시"),
        District(cityType: CityType.gyeongsangnam, name: "밀양시"),
        District(cityType: CityType.gyeongsangnam, name: "사천시"),
        District(cityType: CityType.gyeongsangnam, name: "양산시"),
        District(cityType: CityType.gyeongsangnam, name: "진주시"),
        District(cityType: CityType.gyeongsangnam, name: "창원시"),
        District(cityType: CityType.gyeongsangnam, name: "통영시"),
        District(cityType: CityType.gyeongsangnam, name: "거창군"),
        District(cityType: CityType.gyeongsangnam, name: "고성군"),
        District(cityType: CityType.gyeongsangnam, name: "남해군"),
        District(cityType: CityType.gyeongsangnam, name: "산청군"),
        District(cityType: CityType.gyeongsangnam, name: "의령군"),
        District(cityType: CityType.gyeongsangnam, name: "창녕군"),
        District(cityType: CityType.gyeongsangnam, name: "하동군"),
        District(cityType: CityType.gyeongsangnam, name: "함안군"),
        District(cityType: CityType.gyeongsangnam, name: "함양군"),
        District(cityType: CityType.gyeongsangnam, name: "합천군"),
      ],
    ),
    Region(
      city: CityType.jeonbuk,
      districtList: [
        District(cityType: CityType.jeonbuk, name: "군산시"),
        District(cityType: CityType.jeonbuk, name: "김제시"),
        District(cityType: CityType.jeonbuk, name: "남원시"),
        District(cityType: CityType.jeonbuk, name: "익산시"),
        District(cityType: CityType.jeonbuk, name: "전주시"),
        District(cityType: CityType.jeonbuk, name: "정읍시"),
        District(cityType: CityType.jeonbuk, name: "고창군"),
        District(cityType: CityType.jeonbuk, name: "무주군"),
        District(cityType: CityType.jeonbuk, name: "부안군"),
        District(cityType: CityType.jeonbuk, name: "순창군"),
        District(cityType: CityType.jeonbuk, name: "완주군"),
        District(cityType: CityType.jeonbuk, name: "임실군"),
        District(cityType: CityType.jeonbuk, name: "장수군"),
        District(cityType: CityType.jeonbuk, name: "진안군"),
      ],
    ),
    Region(
      city: CityType.jeonnam,
      districtList: [
        District(cityType: CityType.jeonnam, name: "광양시"),
        District(cityType: CityType.jeonnam, name: "나주시"),
        District(cityType: CityType.jeonnam, name: "목포시"),
        District(cityType: CityType.jeonnam, name: "순천시"),
        District(cityType: CityType.jeonnam, name: "여수시"),
        District(cityType: CityType.jeonnam, name: "강진군"),
        District(cityType: CityType.jeonnam, name: "고흥군"),
        District(cityType: CityType.jeonnam, name: "곡성군"),
        District(cityType: CityType.jeonnam, name: "구례군"),
        District(cityType: CityType.jeonnam, name: "담양군"),
        District(cityType: CityType.jeonnam, name: "무안군"),
        District(cityType: CityType.jeonnam, name: "보성군"),
        District(cityType: CityType.jeonnam, name: "신안군"),
        District(cityType: CityType.jeonnam, name: "영광군"),
        District(cityType: CityType.jeonnam, name: "영암군"),
        District(cityType: CityType.jeonnam, name: "완도군"),
        District(cityType: CityType.jeonnam, name: "장성군"),
        District(cityType: CityType.jeonnam, name: "장흥군"),
        District(cityType: CityType.jeonnam, name: "진도군"),
        District(cityType: CityType.jeonnam, name: "함평군"),
        District(cityType: CityType.jeonnam, name: "해남군"),
        District(cityType: CityType.jeonnam, name: "화순군"),
      ],
    ),
  ];

  /// 입력된 텍스트로 지역 정보를 찾습니다.
  static District? findDistrictByInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    // 구군명 단독 입력 매칭
    final normalized = trimmed.replaceAll(RegExp(r'\s+'), '');
    for (final region in baseList) {
      for (final district in region.districtList) {
        final districtName = district.name.replaceAll(RegExp(r'\s+'), '');
        if (districtName == normalized) {
          return district;
        }
      }
    }

    // "서울, 강남구" 또는 "서울 강남구" 형태 매칭
    final separator = trimmed.contains(',') ? ',' : ' ';
    final parts = trimmed.split(separator).map((e) => e.trim()).toList();
    if (parts.length >= 2) {
      final cityToken = parts[0];
      final districtToken = parts[1];

      final cityType = CityType.values.firstWhere(
        (e) => e.name == cityToken || e.queryValue == cityToken,
        orElse: () => CityType.none,
      );

      if (cityType != CityType.none) {
        final region = baseList.firstWhere(
          (element) => element.city == cityType,
          orElse: () => Region(city: CityType.none, districtList: []),
        );

        if (region.city != CityType.none) {
          return region.districtList.firstWhere(
            (element) => element.name == districtToken,
            orElse: () => District(cityType: CityType.none, name: trimmed),
          );
        }
      }
    }

    return null;
  }
}

///
/// 지역 데이터
///
class District {
  final CityType cityType; // 소속된 도시 정보
  final String name; // 시군구 이름

  District({
    required this.cityType,
    required this.name,
  });

  String get fullName {
    return '${cityType.name}, $name';
  }

  ///
  /// 객체 비교
  ///
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is District &&
        other.name == name &&
        other.cityType.queryValue == cityType.queryValue;
  }

  ///
  /// 해시 코드 생성
  ///
  @override
  int get hashCode => Object.hash(name, cityType.queryValue);
}
