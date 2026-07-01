import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

class CustomHTMLView extends StatelessWidget {
  CustomHTMLView({super.key, required this.content});
  String content;

  @override
  Widget build(BuildContext context) {
    String htmlContent = getCleanVideoHtml(content);

    return Html(
      data: htmlContent,
      style: {
        "p": Style(
            fontSize: FontSize(16.0),
            fontWeight: FontWeight.w300,
            fontFamily: AppFonts.pretendard,
            color: AppColors.color42),
        "body": Style(
            fontSize: FontSize(16.0),
            fontWeight: FontWeight.w300,
            fontFamily: AppFonts.pretendard,
            color: AppColors.color42),
      },
      onAnchorTap: (url, attr, element) async {
        if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      extensions: [
        TagExtension(
          tagsToExtend: {"iframe"},
          builder: (context) {
            final src = context.attributes['src'] ?? '';
            return IframeWidget(src: src);
          },
        ),
        TagExtension(
          tagsToExtend: {"video"},
          builder: (context) {
            String? src;

            // 1. <video src="...">
            if (context.attributes['src'] != null) {
              src = context.attributes['src'];
            }

            // 2. <video><source src="..."></video>
            else {
              try {
                final sourceElement = context.element?.children.firstWhere(
                  (e) => e.localName == 'source' && e.attributes['src'] != null,
                );
                src = sourceElement?.attributes['src'];
              } catch (_) {
                // firstWhere에 아무것도 없으면 여기로 옴
                src = null;
              }
            }

            return src != null
                ? VideoPlayerWidget(url: src)
                : const SizedBox.shrink();
          },
        )
      ],
    );
  }

  String getCleanVideoHtml(String rawHtml) {
    String parsedHtml = rawHtml
        .replaceAll(RegExp('<(figure).*?>|</figure>'), "")
        .replaceAll(RegExp('<p style="margin-.*?>|</p>'), "")
        .replaceAllMapped(
      RegExp(r'<img[^>]+>', caseSensitive: false),
      (match) {
        String imgTag = match.group(0) ?? '';
        imgTag = imgTag.replaceAll(
            RegExp(r'(width|height)="\d+"', caseSensitive: false), '');
        return imgTag;
      },
    ).replaceAllMapped(
      RegExp(r'<oembed\s+url="(.*?)"\s*></oembed>'),
      (match) {
        final url = match.group(1)?.replaceAll('&amp;', '&') ?? '';

        if (url.contains('youtube.com/watch')) {
          final embedUrl = url.replaceFirst('watch?v=', 'embed/');
          return '''
        <iframe width="100%" height="200" src="$embedUrl" frameborder="0" allowfullscreen></iframe>
      ''';
        } else if (url.endsWith('.mp4')) {
          return '''
        <video width="100%" height="200" controls>
          <source src="$url" type="video/mp4">
          Your browser does not support the video tag.
        </video>
      ''';
        } else {
          return '<a href="$url" target="_blank">$url</a>';
        }
      },
    );

    return parsedHtml;
  }
}

class IframeWidget extends StatefulWidget {
  final String src;

  const IframeWidget({super.key, required this.src});

  @override
  State<IframeWidget> createState() => _IframeWidgetState();
}

class _IframeWidgetState extends State<IframeWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.src));
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: WebViewWidget(controller: _controller),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
      _controller
        ..setLooping(true)
        ..play();
    }).catchError((error) {
      setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("⚠️ 영상 재생에 실패했습니다")),
      );
    }

    if (!_isInitialized) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.only(top: AppSpacing.xs),
          ),
        ],
      ),
    );
  }
}
