import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TopicFeedScreen extends StatefulWidget {
  final Function(Topic) onSelectTopic;

  const TopicFeedScreen({
    super.key,
    required this.onSelectTopic,
  });

  @override
  State<TopicFeedScreen> createState() => _TopicFeedScreenState();
}

class _TopicFeedScreenState extends State<TopicFeedScreen> {
  TopicLevel? _selectedLevel;
  final TextEditingController _searchController = TextEditingController();
  List<Topic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getTopics(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        level: _selectedLevel?.name,
      );
      final list = result['topics'] as List? ?? [];
      setState(() {
        _topics = list.map((json) => Topic.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải topics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Chọn Topic luyện tập',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chọn một chủ đề để bắt đầu luyện nói',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 24),

        // Search and Filters
        Row(
          children: [
            // Search
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _loadTopics(),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm topic...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.gray400),
                          onPressed: () {
                            _searchController.clear();
                            _loadTopics();
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Level Filters
            _LevelChip(
              label: 'Tất cả',
              isSelected: _selectedLevel == null,
              onTap: () {
                setState(() => _selectedLevel = null);
                _loadTopics();
              },
            ),
            const SizedBox(width: 8),
            _LevelChip(
              label: 'Beginner',
              color: AppColors.beginnerColor,
              isSelected: _selectedLevel == TopicLevel.beginner,
              onTap: () {
                setState(() => _selectedLevel = TopicLevel.beginner);
                _loadTopics();
              },
            ),
            const SizedBox(width: 8),
            _LevelChip(
              label: 'Intermediate',
              color: AppColors.intermediateColor,
              isSelected: _selectedLevel == TopicLevel.intermediate,
              onTap: () {
                setState(() => _selectedLevel = TopicLevel.intermediate);
                _loadTopics();
              },
            ),
            const SizedBox(width: 8),
            _LevelChip(
              label: 'Advanced',
              color: AppColors.advancedColor,
              isSelected: _selectedLevel == TopicLevel.advanced,
              onTap: () {
                setState(() => _selectedLevel = TopicLevel.advanced);
                _loadTopics();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Topics Grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _topics.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy topic nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.gray500,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        return _TopicCard(
                          topic: topic,
                          onTap: () => widget.onSelectTopic(topic),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.gray900)
              : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.gray900)
                : AppColors.gray300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.onTap,
  });

  Color get _levelColor {
    switch (topic.level) {
      case TopicLevel.beginner:
        return AppColors.beginnerColor;
      case TopicLevel.intermediate:
        return AppColors.intermediateColor;
      case TopicLevel.advanced:
        return AppColors.advancedColor;
    }
  }

  Color get _levelBgColor {
    switch (topic.level) {
      case TopicLevel.beginner:
        return AppColors.beginnerBg;
      case TopicLevel.intermediate:
        return AppColors.intermediateBg;
      case TopicLevel.advanced:
        return AppColors.advancedBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Level
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _levelBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      topic.level.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _levelColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                topic.prompt,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: topic.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tag,
                                size: 12,
                                color: AppColors.gray600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const Spacer(),

              const Divider(),
              const SizedBox(height: 8),

              // Footer
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    topic.duration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${topic.questions.length} câu hỏi',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Bắt đầu luyện tập',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
