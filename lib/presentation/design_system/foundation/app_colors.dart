
import 'package:flutter/cupertino.dart';

// 앱 컬러 셋
class AppColors {
  // ============ 디자인 시스템 컬러 ============
  // Brand (픽송 워밍 리브랜드 — 코랄 primary / 샌드 secondary)
  static const Color primary = Color(0xffC0563A);
  static const Color secondary = Color(0xff6B6456);

  // Splash (Figma 시안 sampling)
  static const Color splashBlueTop = Color(0xff0F70E6);
  static const Color splashBlueBottom = Color(0xff5DD8E8);

  // Primary Palette
  static const Color primary50 = Color(0xffEBF4FF);
  static const Color primary100 = Color(0xffD8EAFF);
  static const Color primary200 = Color(0xffA5CEFF);
  static const Color primary300 = Color(0xff6AADFF);
  static const Color primary400 = Color(0xff3791FF);
  static const Color primary500 = primary;
  static const Color primary600 = Color(0xff045ECC);
  static const Color primary700 = Color(0xff03479A);
  static const Color primary800 = Color(0xff02387A);
  static const Color primary900 = Color(0xff022B5C);

  // Secondary Palette
  static const Color secondary50 = Color(0xffEFFAF5);
  static const Color secondary100 = Color(0xffDFF6EB);
  static const Color secondary200 = Color(0xffB5E9D1);
  static const Color secondary300 = Color(0xff84DBB3);
  static const Color secondary400 = Color(0xff5ACF99);
  static const Color secondary500 = secondary;
  static const Color secondary600 = Color(0xff279C66);
  static const Color secondary700 = Color(0xff1E764D);
  static const Color secondary800 = Color(0xff175D3D);
  static const Color secondary900 = Color(0xff12462E);

  // Gray
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xffFFFFFF);
  static const Color gray100 = Color(0xffF3F4F8);
  static const Color gray200 = Color(0xffDBE1E8);
  static const Color gray400 = Color(0xff939BA7);
  static const Color gray600 = Color(0xff606874);
  static const Color gray900 = Color(0xff2B2F34);

  // 스켈레톤 shimmer 전용 (기존 Colors.grey.shade300/100 값 유지)
  static const Color skeletonBase = Color(0xffE0E0E0);
  static const Color skeletonHighlight = Color(0xffF5F5F5);

  // Figma gray/200 (#E0E4E9) — 디자인시스템 gray200(#DBE1E8)과 다름
  static const Color figmaGray200 = Color(0xffE0E4E9);

  // Figma #464646 — 약관/본문 텍스트 회색 (디자인시스템 미포함)
  static const Color figmaGray464 = Color(0xff464646);

  // Figma #7E7E7E — 새 소식 본문 텍스트 회색 (디자인시스템 미포함)
  static const Color figmaGray7E = Color(0xff7E7E7E);

  // Status
  static const Color statusRed = Color(0xffFE6060);
  static const Color statusRed100 = Color(0xffFFEFEF);
  static const Color statusBlue = Color(0xff4884FF);
  static const Color statusBlue100 = Color(0xffEDF3FF);
  static const Color statusGreen = Color(0xff00C877);
  static const Color statusGreen100 = Color(0xffE5F9F1);
  static const Color statusPurple = Color(0xff815BD3);
  static const Color statusPink = Color(0xffFF6AA0);
  static const Color badgePink = Color(0xffFF55C1);
  static const Color badgeSkyBlue = Color(0xff4DD1FD);

  // ---- 구독 패스 ----
  static const Color passFreeBackground = Color(0xFF05219A);
  static const Color passDiscountBackground = Color(0xFF26E5E7);
  static const Color passDiscountAccent = Color(0xFF0101B4);

  // ---- Legacy (디자인시스템 미포함, 기존 사용처 유지) ----
  static const Color systemBlue = Color(0xff3B82F6);
  static const Color systemRed = Color(0xffEF4444);
  static const Color gray500 = Color(0xff8B8D95);
  static const Color gray700 = Color(0xff4D545D);
  static const Color gray800 = Color(0xff2D343F);

  static const Color appColor = Color(0xff4d55f5);

  static const Color stroke = Color(0xfff2f2f2);
  static const Color labelPrimary = Color(0xff121212);
  static const Color labelSecondary = Color(0xff565656);
  static const Color labelTertiary = Color(0xff898989);

  // Semantic aliases
  static const Color appPink = secondary;
  static const Color background = Color(0xffffffff);
  static const Color basicText = labelPrimary;
  static const Color subText = labelSecondary;
  static const Color gray10 = Color(0xFFF8F8F8);
  static const Color gray20 = Color(0xFFCECECE);
  static const Color gray30 = Color(0xFF767676);
  static const Color gray50 = gray600;
  static const Color colorE5 = Color(0xffE5DCD5);
  static const Color color5B463A = Color(0xff5B463A);
  static const Color color8C7565 = Color(0xff8C7565);
  static const Color colorFFD7D0 = Color(0xffFFD7D0);
  static const Color colorF7F3EF = Color(0xffF7F3EF);

  static const Color black = Color(0xff000000);

  static const Color appBlack = Color(0xff404040);

  static const Color color42 = Color(0xff424242);

  // 소셜 로그인 컬러
  static const Color fillKakao = Color(0xfffee500);
  static const Color fillNaver = Color(0xff03C75A);
  static const Color googleBorder = Color(0xffE0E4E9);

  // ---- 결제 수단 브랜드 컬러 ----
  static const Color paymentKakao = Color(0xffFFEB00);
  static const Color paymentNaver = Color(0xff00DE5A);
  static const Color paymentPayco = Color(0xffFF2233);

  // ---- 공통 오버레이/그림자 ----
  /// 기본 그림자 (25% 회색 AFAFAF)
  static const Color shadowDefault = Color(0x40AFAFAF);
  /// QR 스캔 오버레이 (66% 검정)
  static const Color overlayBlack66 = Color(0xAA000000);

  // ---- 기타 공통 토큰 ----
  static const Color backgroundSoftGray = Color(0xFFF7F7F7);
  static const Color accentTeal = Color(0xFF17B179);
  static const Color accentTealSoft = Color(0xFFE8F7F2);
  static const Color accentCoral = Color(0xffFF6B6B);
  static const Color ratingAmber = Color(0xFFFFC107);
  static const Color dividerLight = Color(0xFFD2D5D7);
  static const Color reportRed = Color(0xFFF05859);
  static const Color deleteRed = Color(0xfff05858);
  static const Color gray696E78 = Color(0xFF696E78);
  static const Color gray6F767F = Color(0xFF6F767F);
  static const Color gray26282B = Color(0xFF26282B);
  static const Color grayF1F1F1 = Color(0xFFF1F1F1);

  // ============ 픽송 디자인 시스템 (워밍 리브랜드) ============
  // 라이트 전용. 캔버스는 따뜻한 저채도 뉴트럴 → AI 이미지가 주인공.

  // ---- 워밍 뉴트럴 램프 (텍스트·구조) ----
  static const Color neutral0 = Color(0xffFFFFFF);
  static const Color neutral50 = Color(0xffFAF8F4);
  static const Color neutral100 = Color(0xffF1EDE5);
  static const Color neutral200 = Color(0xffE7E1D7);
  static const Color neutral300 = Color(0xffD9D1C3);
  static const Color neutral400 = Color(0xffB8AF9E);
  static const Color neutral500 = Color(0xff8C8475);
  static const Color neutral600 = Color(0xff6B6456);
  static const Color neutral700 = Color(0xff4E483D);
  static const Color neutral800 = Color(0xff35302A);
  static const Color neutral900 = Color(0xff211D18);

  // ---- Primary (워밍 코랄) · Secondary (워밍 샌드) 보조 토큰 ----
  static const Color primaryHover = Color(0xffAB4A30);
  static const Color primaryPressed = Color(0xff963F29);
  static const Color primarySoft = Color(0xffFAE8E1);
  static const Color onPrimary = white;
  static const Color secondarySoft = Color(0xffEFECE4);
  static const Color onSecondary = white;

  // ---- 시대 색 (80~90s~2020s, 한 가족) ----
  static const Color era8090s = Color(0xffC25B86);
  static const Color era8090sSoft = Color(0xffF7E6EE);
  static const Color era00s = Color(0xff2F9685);
  static const Color era00sSoft = Color(0xffDCF0EC);
  static const Color era10s = Color(0xff4F73C4);
  static const Color era10sSoft = Color(0xffE4EBF8);
  static const Color era20s = Color(0xff8A63BE);
  static const Color era20sSoft = Color(0xffEFE7F7);
  static const Color onEra = white;

  // ---- 시맨틱 (부드럽게, 경보 아님) ----
  static const Color success = Color(0xff2E9D63);
  static const Color successSoft = Color(0xffE2F3E8);
  static const Color onSuccess = white;
  static const Color warning = Color(0xffC98A2A);
  static const Color warningSoft = Color(0xffF6ECD6);
  static const Color onWarning = white;
  static const Color error = Color(0xffC0503F);
  static const Color errorSoft = Color(0xffF8E6E2);
  static const Color onError = white;
  static const Color info = Color(0xff3F7CC0);
  static const Color infoSoft = Color(0xffE4EEF8);
  static const Color onInfo = white;

  // ---- 서피스 ----
  static const Color surfaceCanvas = Color(0xffF5F2EC);
  static const Color surfaceCard = Color(0xffFFFFFF);
  static const Color surfaceRaised = Color(0xffFFFFFF);
  static const Color surfaceSunken = Color(0xffEFEAE1);
  static const Color surfaceOverlay = Color(0x6B211D18);

  // ---- 보더 / 디바이더 ----
  static const Color borderSubtle = Color(0xffECE6DC);
  static const Color borderDefault = Color(0xffDDD5C8);
  static const Color borderStrong = Color(0xffC9BFAE);

  // ---- 시맨틱 텍스트 alias ----
  static const Color textStrong = neutral900;
  static const Color textBody = neutral800;
  static const Color textMuted = neutral600;
  static const Color textSubtle = neutral500;
  static const Color textOnPrimary = onPrimary;
  static const Color textLink = primary;

}
