import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/api_key_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_particleController);

    _slideController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  void _showApiKeyDialog(ChatProvider chatProvider) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiKeyDialog(
        currentApiKey: chatProvider.apiKey,
        onApiKeySet: (apiKey) {
          chatProvider.setApiKey(apiKey);
        },
      ),
    );
  }

  void _showOptionsMenu(ChatProvider chatProvider) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGlassBottomSheet(chatProvider),
    );
  }

  Widget _buildGlassBottomSheet(ChatProvider chatProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                _buildGlassMenuItem(
                  icon: Icons.key_rounded,
                  title: 'Change API Key',
                  onTap: () {
                    Navigator.pop(context);
                    _showApiKeyDialog(chatProvider);
                  },
                ),
                const SizedBox(height: 12),
                _buildGlassMenuItem(
                  icon: Icons.clear_all_rounded,
                  title: 'Clear Chat',
                  onTap: () {
                    Navigator.pop(context);
                    _showClearChatDialog(chatProvider);
                  },
                ),
                const SizedBox(height: 12),
                _buildGlassMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        title: 'Clear Chat',
        content: 'Are you sure you want to clear all messages? This action cannot be undone.',
        actions: [
          _buildGlassButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          _buildGlassButton(
            text: 'Clear',
            onPressed: () {
              chatProvider.clearChat();
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        title: 'About',
        content: 'Gemini Chat App\n\n'
            'A real-time chat application powered by Google\'s Gemini AI. '
            'Ask anything and get intelligent responses.\n\n'
            'Your API key and messages are stored locally on your device.',
        actions: [
          _buildGlassButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Show API key dialog if not set
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!chatProvider.isApiKeySet) {
            _showApiKeyDialog(chatProvider);
          }
        });

        // Auto-scroll to bottom when new messages arrive
        if (chatProvider.messages.isNotEmpty) {
          _scrollToBottom();
        }

        return Scaffold(
          resizeToAvoidBottomInset: true, // Important for keyboard handling
          extendBodyBehindAppBar: true,
          appBar: _buildGlassAppBar(),
          body: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0D0D0D),
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ],
                    stops: [
                      0.0,
                      0.3 + 0.1 * math.sin(_backgroundAnimation.value),
                      0.6 + 0.1 * math.cos(_backgroundAnimation.value * 0.7),
                      1.0,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    _buildParticleField(),
                    _buildMainContent(chatProvider),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyan.withOpacity(_pulseAnimation.value * 0.3),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.cyan,
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Gemini AI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () => _showOptionsMenu(
              Provider.of<ChatProvider>(context, listen: false),
            ),
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticleField() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_backgroundAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(ChatProvider chatProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Column(
          children: [
            // Remove this line that was causing the black space:
            // const SizedBox(height: kToolbarHeight + 16),

            // Error message with enhanced styling
            if (chatProvider.error != null)
              _buildErrorContainer(chatProvider),

            // Messages list - Ensure it takes available space
            Expanded(
              child: chatProvider.messages.isEmpty
                  ? _buildEnhancedEmptyState()
                  : _buildMessagesList(chatProvider),
            ),

            // Chat input - Fixed positioning
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: ChatInput(
                    onSendMessage: chatProvider.sendMessage,
                    isLoading: chatProvider.isLoading,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContainer(ChatProvider chatProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.red.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade300,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              chatProvider.error!,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: chatProvider.clearError,
            icon: Icon(
              Icons.close_rounded,
              color: Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child: MessageBubble(
            message: chatProvider.messages[index],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedEmptyState() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Main animated centerpiece
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _floatingAnimation, _particleAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulsing ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.cyan.withOpacity(_pulseAnimation.value * 0.2),
                              Colors.blue.withOpacity(_pulseAnimation.value * 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Middle ring with rotation
                      Transform.rotate(
                        angle: _particleAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.cyan.withOpacity(0.3),
                              width: 2,
                            ),
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                Colors.cyan.withOpacity(0.5),
                                Colors.blue.withOpacity(0.5),
                                Colors.purple.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Inner glowing core
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyan.withOpacity(_pulseAnimation.value),
                              Colors.blue.withOpacity(_pulseAnimation.value * 0.7),
                              Colors.purple.withOpacity(_pulseAnimation.value * 0.5),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(_pulseAnimation.value * 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.white.withOpacity(_pulseAnimation.value),
                        ),
                      ),

                      // Floating particles
                      ..._buildFloatingParticles(),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Enhanced title with shimmer effect
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.cyan,
                        Colors.blue,
                        Colors.purple,
                        Colors.pink,
                      ],
                      stops: [
                        (_backgroundAnimation.value / (2 * math.pi)) % 1,
                        ((_backgroundAnimation.value / (2 * math.pi)) + 0.3) % 1,
                        ((_backgroundAnimation.value / (2 * math.pi)) + 0.6) % 1,
                        ((_backgroundAnimation.value / (2 * math.pi)) + 0.9) % 1,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Welcome to the Future',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Subtitle with typewriter effect
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Text(
                  'Ask me anything! ✨',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8 + _pulseAnimation.value * 0.2),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Text(
              'I\'m powered by advanced AI technology and ready to help with anything you need.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
                height: 1.6,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 40),

            // Enhanced suggestion chips with better animations
            _buildEnhancedSuggestionChips(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(6, (index) {
      return AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          final angle = (index * math.pi / 3) + _particleAnimation.value;
          final radius = 60 + math.sin(_particleAnimation.value + index) * 10;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          return Transform.translate(
            offset: Offset(x, y),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: [
                  Colors.cyan,
                  Colors.blue,
                  Colors.purple,
                  Colors.pink,
                  Colors.orange,
                  Colors.green,
                ][index].withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: [
                      Colors.cyan,
                      Colors.blue,
                      Colors.purple,
                      Colors.pink,
                      Colors.orange,
                      Colors.green,
                    ][index].withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEnhancedSuggestionChips() {
    final suggestions = [
      {'text': 'Explain quantum computing', 'icon': Icons.science},
      {'text': 'Write a creative story', 'icon': Icons.auto_stories},
      {'text': 'Plan my perfect day', 'icon': Icons.schedule},
      {'text': 'Code a function', 'icon': Icons.code},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: suggestions.asMap().entries.map((entry) {
        final index = entry.key;
        final suggestion = entry.value;

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + (_pulseAnimation.value * 0.05),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      suggestion['icon'] as IconData,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggestion['text'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i * 0.1 + animationValue * 0.1)) % size.width;
      final y = (size.height * (i * 0.05 + animationValue * 0.05)) % size.height;
      final radius = 1 + math.sin(animationValue + i) * 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}