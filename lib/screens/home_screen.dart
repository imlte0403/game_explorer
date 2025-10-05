import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:game_explorer/providers/games_provider.dart';
import 'package:game_explorer/core/model/game_model.dart';
import 'package:game_explorer/screens/game_card.dart';
import 'package:game_explorer/core/constants/colors.dart';
import 'package:game_explorer/core/constants/animation_constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 상태 관리 변수
  late final PageController _cardController;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> _scrollNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _cardController = PageController(
      viewportFraction: AnimationConstants.viewportFraction,
    );

    _cardController.addListener(() {
      if (_cardController.hasClients && _cardController.page != null) {
        final page = _cardController.page!;
        final currentPage = page.round();

        if (_currentIndexNotifier.value != currentPage) {
          _currentIndexNotifier.value = currentPage;
        }

        _scrollNotifier.value = page;
      }
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _currentIndexNotifier.dispose();
    _scrollNotifier.dispose();
    super.dispose();
  }

  void _onCardTap(GameModel game) {
    context.push('/detail/${game.appId}', extra: game);
  }

  void _onPageSwipe(int index) {
    final gamesAsync = ref.read(featuredGamesProvider);
    gamesAsync.whenData((games) {
      if (index < games.length) {
        if (index > _currentIndexNotifier.value) {
          ref
              .read(wishlistProvider.notifier)
              .addToWishlist(games[_currentIndexNotifier.value].appId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(featuredGamesProvider);

    return Scaffold(
      backgroundColor: AppColors.steamDarkBlue,
      extendBodyBehindAppBar: true,
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(child: Text('No games available'));
          }

          return Stack(
            children: [
              // 배경 이미지
              ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(currentIndex),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            games[currentIndex].backgroundImage,
                          ),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 카드 PageView
              Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollNotifier,
                      builder: (context, scrollValue, _) {
                        return PageView.builder(
                          key: const PageStorageKey('game_cards_page_view'),
                          controller: _cardController,
                          itemCount: games.length,
                          onPageChanged: _onPageSwipe,
                          itemBuilder: (context, index) {
                            final value = scrollValue - index;
                            final clamped = value.clamp(-1.0, 1.0);
                            final scale =
                                1 -
                                (clamped.abs() *
                                    AnimationConstants.pageScaleFactor);
                            final translateY =
                                clamped.abs() *
                                AnimationConstants.pageTranslateY;
                            final parallax = -clamped;

                            return Transform.scale(
                              scale: scale,
                              child: Transform.translate(
                                offset: Offset(0, translateY),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AnimationConstants
                                          .cardHorizontalPadding,
                                      vertical: AnimationConstants
                                          .cardVerticalPadding,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _onCardTap(games[index]),
                                      child: GameCard(
                                        game: games[index],
                                        scrollProgress: parallax,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.steamAccent),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
