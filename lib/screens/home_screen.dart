import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/apps_colors.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;
  final DateTime createdAt;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabWidthAnimation;
  late Animation<double> _textOpacityAnimation;
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Width animation for smooth expansion
    _fabWidthAnimation = Tween<double>(begin: 56.0, end: 160.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Text fade animation (delayed start)
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Auto-expand FAB after initial delay (like WhatsApp Meta animation)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _fabAnimationController.forward();
        setState(() => _showText = true);
        // Auto-collapse after 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            _fabAnimationController.reverse();
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) setState(() => _showText = false);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFabTap() {
    if (_fabAnimationController.value > 0.5) {
      // If expanded, navigate to chatbot
      Navigator.pushNamed(context, '/chatbot');
    } else {
      // Expand the FAB smoothly
      _fabAnimationController.forward();
      setState(() => _showText = true);
      // Auto-collapse after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _fabAnimationController.reverse();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => _showText = false);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: HomeDrawer(
        userId: widget.userId,
        username: widget.username,
        createdAt: widget.createdAt,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: AppColors.textPrimary,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: AppColors.primary,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/bookmarks',
                arguments: widget.userId,
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: AnimatedBuilder(
          animation: _fabAnimationController,
          builder: (context, child) {
            return GestureDetector(
              onTap: _onFabTap,
              child: Container(
                height: 56,
                width: _fabWidthAnimation.value,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (_showText) ...[
                      const SizedBox(width: 8),
                      Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: const Text(
                          'Ask Chatbot',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'True',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: 'Hadith',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Search bar with + and mic
              _buildSearchBar(context),

              const SizedBox(height: 24),

              Text(
                'Search hadiths by text, voice, image, or audio.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => _showInputOptionsSheet(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by text, voice, image…',
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                final query = value.trim();
                if (query.isNotEmpty) {
                  _submitQuery(query);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none),
            color: AppColors.primary,
            onPressed: () async {
              final result = await Navigator.pushNamed<String>(
                context,
                '/voice_input',
              );
              if (result != null && result.trim().isNotEmpty) {
                setState(() {
                  _searchController.text = result.trim();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showInputOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose input type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Open Camera',
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.pushNamed<String>(
                      context,
                      '/crop_image',
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      _searchController.text = result.trim();
                    }
                  },
                  icon: Icons.camera_alt_outlined,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Upload Image',
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.pushNamed<String>(
                      context,
                      '/crop_image',
                      arguments: {'source': 'gallery'},
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      _searchController.text = result.trim();
                    }
                  },
                  icon: Icons.photo_library_outlined,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Upload MP3 / WAV File',
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.pushNamed<String>(
                      context,
                      '/audio_trimming',
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      _searchController.text = result.trim();
                    }
                  },
                  icon: Icons.audiotrack_outlined,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitQuery(String query) {
    Navigator.pushNamed(
      context,
      '/results',
      arguments: {
        'userId': widget.userId,
        'query': query,
      },
    );
  }
}

class HomeDrawer extends StatelessWidget {
  final int userId;
  final String username;
  final DateTime createdAt;

  const HomeDrawer({
    super.key,
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  String _memberSinceText() {
    final formatter = DateFormat('MMMM yyyy');
    return 'Member since ${formatter.format(createdAt)}';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: add upload / update / delete profile photo logic
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _memberSinceText(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.history,
              label: 'History',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/history',
                  arguments: userId,
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                text: 'Logout',
                onPressed: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
                backgroundColor: AppColors.error,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
