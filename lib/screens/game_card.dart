import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:game_explorer/core/model/game_model.dart';
import 'package:game_explorer/core/constants/sizes.dart';
import 'package:game_explorer/core/constants/gaps.dart';
import 'package:game_explorer/core/constants/colors.dart';
import 'package:game_explorer/core/constants/animation_constants.dart';
import 'package:game_explorer/screens/widgets/game_detail_content.dart';

class GameCard extends StatefulWidget {
  final GameModel game;
  final double scrollProgress;

  const GameCard({super.key, required this.game, this.scrollProgress = 0.0});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러
  bool _isExpanded = false;
  double _dragAccumulation = 0.0;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _detailController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _detailCurve = CurvedAnimation(
    parent: _detailController,
    curve: Curves.easeInOutCubic,
  );

  void _toggleExpanded({bool? expand}) {
    final shouldExpand = expand ?? !_isExpanded;
    if (shouldExpand) {
      _detailController.forward();
    } else {
      _detailController.reverse();
    }
    setState(() {
      _isExpanded = shouldExpand;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isExpanded && _scrollController.hasClients) {
      final isAtBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent;
      if (isAtBottom && details.delta.dy < 0) {
        _dragAccumulation += details.delta.dy;
      }
    } else {
      _dragAccumulation += details.delta.dy;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;

    if (_isExpanded) {
      if (velocity < -AnimationConstants.dragVelocityThreshold ||
          _dragAccumulation < -AnimationConstants.dragDistanceThreshold) {
        _toggleExpanded(expand: false);
      }
    } else {
      if (velocity > AnimationConstants.dragVelocityThreshold) {
        _toggleExpanded(expand: true);
      } else if (velocity < -AnimationConstants.dragVelocityThreshold) {
        _toggleExpanded(expand: false);
      } else {
        if (_dragAccumulation > AnimationConstants.dragDistanceThreshold) {
          _toggleExpanded(expand: true);
        } else if (_dragAccumulation <
            -AnimationConstants.dragDistanceThreshold) {
          _toggleExpanded(expand: false);
        }
      }
    }
    _dragAccumulation = 0.0;
  }

  Color _getRatingColor(String rating) {
    if (rating.contains('긍정적')) {
      return const Color(0xFF66C0F4);
    } else if (rating.contains('복합적')) {
      return const Color(0xFFCCA86A);
    } else if (rating.contains('부정적')) {
      return const Color(0xFFA34C25);
    }
    return AppColors.steamGrey;
  }

  @override
  void didUpdateWidget(GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isExpanded && widget.scrollProgress.abs() > 0.5) {
      _toggleExpanded(expand: false);
    }
  }

  double _calculateCoverImageScale() {
    final scaleFactor =
        widget.scrollProgress.abs() * AnimationConstants.pageScaleFactor;
    if (scaleFactor > 0) {
      return 1.0 / (1 - scaleFactor);
    }
    return 1.0;
  }

  @override
  void dispose() {
    _detailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 크기 및 레이아웃 계산
    final size = MediaQuery.of(context).size;
    final baseWidth = size.width * AnimationConstants.cardBaseWidthFactor;
    final coverUrl = widget.game.headerImage;
    const coverAspectRatio = AnimationConstants.coverAspectRatio;
    final fixedCoverWidth = baseWidth * AnimationConstants.coverWidthFactor;
    final coverHeight = fixedCoverWidth / coverAspectRatio;
    final overlapOffset = coverHeight * AnimationConstants.overlapFactor;
    final baseInfoTop = (coverHeight - overlapOffset).clamp(
      0.0,
      double.infinity,
    );

    return Hero(
      tag: 'game-${widget.game.appId}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: AnimatedBuilder(
            animation: _detailController,
            builder: (context, _) {
              // 애니메이션 값 계산
              final t = _detailCurve.value;
              final width = lerpDouble(baseWidth, size.width, t)!;
              final height = lerpDouble(
                size.height * AnimationConstants.cardBaseHeightFactor,
                size.height,
                t,
              )!;
              final infoTop = lerpDouble(baseInfoTop, 0, t)!;
              final statusBarHeight = MediaQuery.of(context).padding.top;
              final infoPaddingTop = lerpDouble(
                coverHeight * AnimationConstants.overlapFactor,
                statusBarHeight + Sizes.size60,
                t,
              )!;
              final infoHorizontalPadding = lerpDouble(
                Sizes.size24,
                Sizes.size32,
                t,
              )!;
              final targetLift = coverHeight * 0.9 - statusBarHeight;
              final coverLift = lerpDouble(0, targetLift, t)!;
              final baseScale = lerpDouble(1.0, 1.2, t)!;
              final scrollEffect = t > 0
                  ? (widget.scrollProgress.abs() * 0.2)
                  : 0.0;
              final cardScale = (baseScale - scrollEffect).clamp(1.0, 1.2);

              // Parallax 효과 계산
              final imageParallaxOffset =
                  widget.scrollProgress * AnimationConstants.parallaxMultiplier;
              final cardParallaxOffset =
                  widget.scrollProgress *
                  AnimationConstants.parallaxMultiplier *
                  0.01;

              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // 정보 카드
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: infoTop),
                        child: Transform.translate(
                          offset: Offset(cardParallaxOffset, 0),
                          child: Transform.scale(
                            scale: cardScale,
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: width,
                              constraints: BoxConstraints(
                                minHeight: (height - infoTop + Sizes.size100)
                                    .clamp(0.0, height),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                infoHorizontalPadding,
                                infoPaddingTop * 1.1,
                                infoHorizontalPadding,
                                Sizes.size32,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.steamBlue.withValues(
                                  alpha: 0.94,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Sizes.size32,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: Sizes.size24,
                                    offset: Offset(0, Sizes.size12),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.game.name,
                                      style: const TextStyle(
                                        fontSize: Sizes.size22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.steamWhite,
                                      ),
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Gaps.v12,
                                    if (widget.game.genres.isNotEmpty)
                                      Text(
                                        widget.game.genres.join(', '),
                                        style: const TextStyle(
                                          fontSize: Sizes.size16,
                                          color: AppColors.steamGrey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Gaps.v16,
                                    AnimatedCrossFade(
                                      firstChild: Text(
                                        widget.game.shortDescription,
                                        style: const TextStyle(
                                          fontSize: Sizes.size14,
                                          color: AppColors.steamWhite,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      secondChild: GameDetailContent(
                                        game: widget.game,
                                        scrollController: _scrollController,
                                        getRatingColor: _getRatingColor,
                                      ),
                                      crossFadeState: _isExpanded
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                    ),
                                    Gaps.v20,
                                    AnimatedOpacity(
                                      opacity: _isExpanded ? 0.0 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Price',
                                                style: TextStyle(
                                                  fontSize: Sizes.size12,
                                                  color: AppColors.steamGrey,
                                                ),
                                              ),
                                              Gaps.v4,
                                              Text(
                                                widget.game.price,
                                                style: const TextStyle(
                                                  fontSize: Sizes.size20,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.steamAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'Rating',
                                                style: TextStyle(
                                                  fontSize: Sizes.size12,
                                                  color: AppColors.steamGrey,
                                                ),
                                              ),
                                              Gaps.v4,
                                              Text(
                                                widget.game.rating,
                                                style: TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getRatingColor(
                                                    widget.game.rating,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 커버 이미지
                    Align(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: Offset(imageParallaxOffset, -coverLift),
                        child: Transform.scale(
                          scale: _calculateCoverImageScale(),
                          child: _CoverArt(
                            imageUrl: coverUrl,
                            width: fixedCoverWidth,
                            aspectRatio: coverAspectRatio,
                          ),
                        ),
                      ),
                    ),
                    // 토글 버튼
                    Positioned(
                      bottom: Sizes.size16,
                      child: IconButton(
                        onPressed: _toggleExpanded,
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.steamWhite,
                          size: Sizes.size28,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({
    required this.imageUrl,
    required this.width,
    required this.aspectRatio,
  });

  final String imageUrl;
  final double width;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.size24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: Sizes.size20,
            offset: Offset(0, Sizes.size12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Sizes.size24),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.steamBlue,
                child: const Center(
                  child: Icon(
                    Icons.sports_esports,
                    size: Sizes.size64,
                    color: AppColors.steamGrey,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.steamBlue.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.steamAccent,
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
