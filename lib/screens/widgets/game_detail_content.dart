import 'package:flutter/material.dart';
import 'package:game_explorer/core/model/game_model.dart';
import 'package:game_explorer/core/constants/sizes.dart';
import 'package:game_explorer/core/constants/gaps.dart';
import 'package:game_explorer/core/constants/colors.dart';

class GameDetailContent extends StatelessWidget {
  final GameModel game;
  final ScrollController scrollController;
  final Color Function(String) getRatingColor;

  const GameDetailContent({
    super.key,
    required this.game,
    required this.scrollController,
    required this.getRatingColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '상세 정보',
              style: TextStyle(
                fontSize: Sizes.size20,
                fontWeight: FontWeight.bold,
                color: AppColors.steamWhite,
              ),
            ),
            Gaps.v16,
            const Divider(color: AppColors.steamGrey, height: 1),
            Gaps.v16,
            _buildInfoSection('게임 설명', game.shortDescription),
            Gaps.v20,
            const Divider(color: AppColors.steamGrey, height: 1),
            Gaps.v16,
            _buildInfoRow('장르', game.genres.join(', ')),
            Gaps.v12,
            _buildInfoRow('가격', game.price),
            Gaps.v12,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '평가: ',
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.steamGrey,
                  ),
                ),
                Expanded(
                  child: Text(
                    game.rating,
                    style: TextStyle(
                      fontSize: Sizes.size14,
                      color: getRatingColor(game.rating),
                    ),
                  ),
                ),
              ],
            ),
            if (game.developers.isNotEmpty) ...[
              Gaps.v12,
              _buildInfoRow('개발사', game.developers.join(', ')),
            ],
            if (game.publishers.isNotEmpty) ...[
              Gaps.v12,
              _buildInfoRow('배급사', game.publishers.join(', ')),
            ],
            if (game.platforms.isNotEmpty) ...[
              Gaps.v12,
              _buildPlatformRow(game.platforms),
            ],
            if (game.releaseDate.isNotEmpty) ...[
              Gaps.v12,
              _buildInfoRow('출시일', game.releaseDate),
            ],
            if (game.ageRating.isNotEmpty) ...[
              Gaps.v12,
              _buildInfoRow('연령 등급', game.ageRating),
            ],
            if (game.multiplayerInfo.isNotEmpty) ...[
              Gaps.v12,
              _buildInfoRow('플레이 모드', game.multiplayerInfo),
            ],
            Gaps.v20,
            if (game.screenshots.isNotEmpty) ...[
              const Divider(color: AppColors.steamGrey, height: 1),
              Gaps.v16,
              const Text(
                '스크린샷',
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.steamWhite,
                ),
              ),
              Gaps.v12,
              _buildScreenshotsSection(game.screenshots),
              Gaps.v20,
            ],
            Gaps.v32,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: Sizes.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.steamWhite,
          ),
        ),
        Gaps.v8,
        Text(
          content,
          style: const TextStyle(
            fontSize: Sizes.size14,
            color: AppColors.steamWhite,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: Sizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.steamGrey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: Sizes.size14,
              color: AppColors.steamWhite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformRow(List<String> platforms) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '플랫폼: ',
          style: TextStyle(
            fontSize: Sizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.steamGrey,
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: platforms.map((platform) {
              IconData icon;
              switch (platform.toLowerCase()) {
                case 'windows':
                  icon = Icons.window;
                  break;
                case 'mac':
                  icon = Icons.apple;
                  break;
                case 'linux':
                  icon = Icons.developer_board;
                  break;
                default:
                  icon = Icons.devices;
              }
              return Icon(
                icon,
                size: Sizes.size20,
                color: AppColors.steamWhite,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotsSection(List<String> screenshots) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: screenshots.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.size12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.size12),
              child: Image.network(
                screenshots[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.steamBlue,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.steamGrey,
                        size: Sizes.size32,
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
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
