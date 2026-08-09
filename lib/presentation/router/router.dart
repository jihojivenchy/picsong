import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/question/question_result.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/router/pages/fade_transition_page.dart';
import 'package:picsong/presentation/screens/home/app_info/app_info_screen.dart';
import 'package:picsong/presentation/screens/home/home_screen.dart';
import 'package:picsong/presentation/screens/image_detail/image_detail_screen.dart';
import 'package:picsong/presentation/screens/model_download/model_download_screen.dart';
import 'package:picsong/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_screen.dart';
import 'package:picsong/presentation/screens/question/question_screen.dart';
import 'package:picsong/presentation/screens/question/result/question_result_screen.dart';
import 'package:picsong/presentation/screens/round_preparation/round_preparation_screen.dart';
import 'package:picsong/presentation/screens/round_result/round_result_screen.dart';
import 'package:picsong/presentation/screens/splash/splash_screen.dart';

part 'router.g.dart';

/// 루트 네비게이터 키 — Dialog/Toast 서비스가 전역 context 확보에 사용
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

///
/// 앱 라우터
///
/// 목적지 판정은 화면이 한다 — 스플래시의 BlocListener가 홈/온보딩을 고르고,
/// 라우터는 redirect 게이트를 두지 않는다.
///
/// 객체 전달 규약:
/// - 라우트 클래스의 선언 필드는 path/query 파라미터만 둔다.
/// - 객체는 `context.push(SomeRoute().location, extra: object)`로 싣고
///   build에서 `state.extra`를 수동 캐스트한다.
///   (부모/자식 라우트가 모두 $extra를 선언하면 덮어쓰는 이슈: flutter/flutter#106121)
///
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: SplashRoute.path,
  routes: $appRoutes,
);

/// 퀴즈 진입에 필요한 라운드 재료 (extra)
typedef QuestionArgs = ({
  Era era,
  List<Question> questionList,
  String firstImagePath,
});

/// 문제 결과 화면 구성값 — 진행 콜백까지 함께 넘긴다 (extra)
typedef QuestionResultArgs = ({
  Era era,
  Question question,
  List<String> imagePathList,
  void Function(int index) onSceneTapped,
  bool isCorrect,
  bool isLast,
  VoidCallback onNext,
});

/// 라운드 결과 요약 (extra)
typedef RoundResultArgs = ({Era era, List<QuestionResult> resultList});

/// 크게 볼 그림 목록과 시작 위치 (extra)
typedef ImageDetailArgs = ({List<String> imagePathList, int initialIndex});

///
/// 스플래시 — 앱 진입점
///
@TypedGoRoute<SplashRoute>(path: SplashRoute.path, name: SplashRoute.name)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  static const String path = '/splash';
  static const String name = 'splash';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      FadeTransitionPage<void>(key: state.pageKey, child: const SplashScreen());
}

///
/// 온보딩 — 최초 1회
///
@TypedGoRoute<OnboardingRoute>(
  path: OnboardingRoute.path,
  name: OnboardingRoute.name,
)
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  static const String path = '/onboarding';
  static const String name = 'onboarding';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      FadeTransitionPage<void>(
        key: state.pageKey,
        child: const OnboardingScreen(),
      );
}

///
/// 홈 — 게임 플로우의 뿌리
///
/// 홈 위에만 쌓이는 화면들을 자식으로 둔다. `go`로 진입해도 홈이 스택 바닥에 깔려
/// 뒤로가기가 항상 홈으로 떨어진다.
///
@TypedGoRoute<HomeRoute>(
  path: HomeRoute.path,
  name: HomeRoute.name,
  routes: <TypedRoute<GoRouteData>>[
    TypedGoRoute<AppInfoRoute>(path: AppInfoRoute.path, name: AppInfoRoute.name),
    TypedGoRoute<ModelDownloadRoute>(
      path: ModelDownloadRoute.path,
      name: ModelDownloadRoute.name,
    ),
    TypedGoRoute<RoundPreparationRoute>(
      path: RoundPreparationRoute.path,
      name: RoundPreparationRoute.name,
    ),
    TypedGoRoute<QuestionRoute>(
      path: QuestionRoute.path,
      name: QuestionRoute.name,
    ),
    TypedGoRoute<QuestionResultRoute>(
      path: QuestionResultRoute.path,
      name: QuestionResultRoute.name,
    ),
    TypedGoRoute<RoundResultRoute>(
      path: RoundResultRoute.path,
      name: RoundResultRoute.name,
    ),
    TypedGoRoute<ImageDetailRoute>(
      path: ImageDetailRoute.path,
      name: ImageDetailRoute.name,
    ),
    TypedGoRoute<PromptLabRoute>(
      path: PromptLabRoute.path,
      name: PromptLabRoute.name,
    ),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  static const String path = '/';
  static const String name = 'home';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      FadeTransitionPage<void>(key: state.pageKey, child: const HomeScreen());
}

///
/// 앱 정보 — 라이선스 고지
///
class AppInfoRoute extends GoRouteData with $AppInfoRoute {
  const AppInfoRoute();

  static const String path = 'app-info';
  static const String name = 'app-info';

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AppInfoScreen();
}

///
/// 모델 다운로드 — 받고 나면 이 시대의 라운드로 들어간다
///
class ModelDownloadRoute extends GoRouteData with $ModelDownloadRoute {
  const ModelDownloadRoute({required this.era});

  static const String path = 'model-download';
  static const String name = 'model-download';

  /// 다운로드 후 진입할 시대 — `Era.queryValue` (query parameter)
  final String era;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ModelDownloadScreen(era: Era.fromQueryValue(era));
}

///
/// 라운드 준비 — 곡을 뽑고 첫 그림을 그리는 동안
///
class RoundPreparationRoute extends GoRouteData with $RoundPreparationRoute {
  const RoundPreparationRoute({required this.era});

  static const String path = 'round-preparation';
  static const String name = 'round-preparation';

  /// 라운드를 준비할 시대 — `Era.queryValue` (query parameter)
  final String era;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RoundPreparationScreen(era: Era.fromQueryValue(era));
}

///
/// 퀴즈 — 준비된 문제 목록을 extra로 받는다
///
class QuestionRoute extends GoRouteData with $QuestionRoute {
  const QuestionRoute();

  static const String path = 'question';
  static const String name = 'question';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final QuestionArgs args = state.extra! as QuestionArgs;
    return QuestionScreen(
      era: args.era,
      questionList: args.questionList,
      firstImagePath: args.firstImagePath,
    );
  }
}

///
/// 문제 결과 — 정오 공개와 다음 단계 진행
///
class QuestionResultRoute extends GoRouteData with $QuestionResultRoute {
  const QuestionResultRoute();

  static const String path = 'question-result';
  static const String name = 'question-result';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final QuestionResultArgs args = state.extra! as QuestionResultArgs;
    return QuestionResultScreen(
      era: args.era,
      question: args.question,
      imagePathList: args.imagePathList,
      onSceneTapped: args.onSceneTapped,
      isCorrect: args.isCorrect,
      isLast: args.isLast,
      onNext: args.onNext,
    );
  }
}

///
/// 라운드 결과 — 점수 요약
///
class RoundResultRoute extends GoRouteData with $RoundResultRoute {
  const RoundResultRoute();

  static const String path = 'round-result';
  static const String name = 'round-result';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final RoundResultArgs args = state.extra! as RoundResultArgs;
    return RoundResultScreen(era: args.era, resultList: args.resultList);
  }
}

///
/// 그림 크게 보기 — 뒤 화면이 비치는 반투명 오버레이
///
/// `opaque: false`로 뒤 화면을 살려두고, 페이드로만 덮는다.
/// `CustomTransitionPage`는 Material 라우트가 아니라서 아래 화면의
/// 퇴장 애니메이션(canTransitionTo)이 돌지 않는다 — 뒤 화면이 밀려나지 않는다.
///
class ImageDetailRoute extends GoRouteData with $ImageDetailRoute {
  const ImageDetailRoute();

  static const String path = 'image-detail';
  static const String name = 'image-detail';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final ImageDetailArgs args = state.extra! as ImageDetailArgs;
    return CustomTransitionPage<void>(
      key: state.pageKey,
      opaque: false,
      barrierDismissible: false,
      transitionDuration: AppMotion.durationBase,
      reverseTransitionDuration: AppMotion.durationBase,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: ImageDetailScreen(
        imagePathList: args.imagePathList,
        initialIndex: args.initialIndex,
      ),
    );
  }
}

///
/// 프롬프트 실험실 — 진단 전용, 원인 규명이 끝나면 제거한다
///
class PromptLabRoute extends GoRouteData with $PromptLabRoute {
  const PromptLabRoute({required this.tag});

  static const String path = 'prompt-lab';
  static const String name = 'prompt-lab';

  /// 실행할 배치 식별자 — `PromptLabBatch.tag` (query parameter)
  final String tag;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PromptLabScreen(batch: PromptLabBatches.fromTag(tag));
}
