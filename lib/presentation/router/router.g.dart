// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $splashRoute,
      $onboardingRoute,
      $homeRoute,
    ];

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      name: 'splash',
      factory: $SplashRoute._fromState,
    );

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location(
        '/splash',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      name: 'onboarding',
      factory: $OnboardingRoute._fromState,
    );

mixin $OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  @override
  String get location => GoRouteData.$location(
        '/onboarding',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      name: 'home',
      factory: $HomeRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'app-info',
          name: 'app-info',
          factory: $AppInfoRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'model-download',
          name: 'model-download',
          factory: $ModelDownloadRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'round-preparation',
          name: 'round-preparation',
          factory: $RoundPreparationRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'question',
          name: 'question',
          factory: $QuestionRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'question-result',
          name: 'question-result',
          factory: $QuestionResultRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'round-result',
          name: 'round-result',
          factory: $RoundResultRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'image-detail',
          name: 'image-detail',
          factory: $ImageDetailRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'prompt-lab',
          name: 'prompt-lab',
          factory: $PromptLabRoute._fromState,
        ),
      ],
    );

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AppInfoRoute on GoRouteData {
  static AppInfoRoute _fromState(GoRouterState state) => const AppInfoRoute();

  @override
  String get location => GoRouteData.$location(
        '/app-info',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ModelDownloadRoute on GoRouteData {
  static ModelDownloadRoute _fromState(GoRouterState state) =>
      ModelDownloadRoute(
        era: state.uri.queryParameters['era']!,
      );

  ModelDownloadRoute get _self => this as ModelDownloadRoute;

  @override
  String get location => GoRouteData.$location(
        '/model-download',
        queryParams: {
          'era': _self.era,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RoundPreparationRoute on GoRouteData {
  static RoundPreparationRoute _fromState(GoRouterState state) =>
      RoundPreparationRoute(
        era: state.uri.queryParameters['era']!,
      );

  RoundPreparationRoute get _self => this as RoundPreparationRoute;

  @override
  String get location => GoRouteData.$location(
        '/round-preparation',
        queryParams: {
          'era': _self.era,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuestionRoute on GoRouteData {
  static QuestionRoute _fromState(GoRouterState state) => const QuestionRoute();

  @override
  String get location => GoRouteData.$location(
        '/question',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $QuestionResultRoute on GoRouteData {
  static QuestionResultRoute _fromState(GoRouterState state) =>
      const QuestionResultRoute();

  @override
  String get location => GoRouteData.$location(
        '/question-result',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RoundResultRoute on GoRouteData {
  static RoundResultRoute _fromState(GoRouterState state) =>
      const RoundResultRoute();

  @override
  String get location => GoRouteData.$location(
        '/round-result',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ImageDetailRoute on GoRouteData {
  static ImageDetailRoute _fromState(GoRouterState state) =>
      const ImageDetailRoute();

  @override
  String get location => GoRouteData.$location(
        '/image-detail',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PromptLabRoute on GoRouteData {
  static PromptLabRoute _fromState(GoRouterState state) => PromptLabRoute(
        tag: state.uri.queryParameters['tag']!,
      );

  PromptLabRoute get _self => this as PromptLabRoute;

  @override
  String get location => GoRouteData.$location(
        '/prompt-lab',
        queryParams: {
          'tag': _self.tag,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
