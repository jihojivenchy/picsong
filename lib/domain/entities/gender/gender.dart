enum Gender {
  male(displayText: "남성", queryValue: "MALE"),
  female(displayText: "여성", queryValue: "FEMALE"),
  none(displayText: "미지정", queryValue: "UNSPECIFIED");

  final String displayText;
  final String queryValue;

  const Gender({
    required this.displayText,
    required this.queryValue,
  });
}