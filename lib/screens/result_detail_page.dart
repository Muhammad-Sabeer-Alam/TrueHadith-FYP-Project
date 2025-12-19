import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/hadith_models.dart';
import '../utils/apps_colors.dart';

class ResultDetailPage extends StatefulWidget {
  final int userId;
  final HadithDetail detail;
  final bool initiallyBookmarked;
  final int? bookmarkId;

  const ResultDetailPage({
    super.key,
    required this.userId,
    required this.detail,
    this.initiallyBookmarked = false,
    this.bookmarkId,
  });

  @override
  State<ResultDetailPage> createState() => _ResultDetailPageState();
}

class _ResultDetailPageState extends State<ResultDetailPage> {
  late bool _isBookmarked;
  // ignore: unused_field
  int? _bookmarkId;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initiallyBookmarked;
    _bookmarkId = widget.bookmarkId;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: _isBookmarked ? AppColors.info : AppColors.textLight,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${d.bookName} : ${d.hadithNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chapter #${d.chapterNumber} • ${d.chapterName}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                d.grade,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getHadithColor(d.grade),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Narrator: ${d.narrator}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Arabic'),
              const SizedBox(height: 4),
              Text(
                d.arabicText,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('English'),
              const SizedBox(height: 4),
              Text(
                d.englishText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Urdu'),
              const SizedBox(height: 4),
              Text(
                d.urduText,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              if (d.bookmarkedAt != null)
                Text(
                  'Bookmarked on ${DateFormat('d MMMM, h:mm a').format(d.bookmarkedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // TODO: call backend API
    // If _isBookmarked == true -> create bookmark with userId + hadithId
    // Else -> delete bookmark using _bookmarkId
  }
}


