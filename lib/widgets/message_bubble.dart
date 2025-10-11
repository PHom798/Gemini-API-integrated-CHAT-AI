import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _typingController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isHovered = false;
  bool _showCopyFeedback = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Configure animations
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 1.0 : -1.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_particleController);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start continuous animations
    _glowController.repeat(reverse: true);
    _particleController.repeat();
    _pulseController.repeat(reverse: true);

    if (widget.message.isLoading) {
      _typingController.repeat(reverse: true);
    }
  }

  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _slideController.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _typingController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildEnhancedAvatar() {
    final isUser = widget.message.isUser;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _particleAnimation]),
      builder: (context, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isUser
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.8),
                Colors.purple.withOpacity(0.8),
                Colors.pink.withOpacity(0.6),
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyan.withOpacity(0.8),
                Colors.blue.withOpacity(0.8),
                Colors.green.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isUser ? Colors.blue : Colors.cyan)
                    .withOpacity(_glowAnimation.value * 0.6),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated background pattern
                    CustomPaint(
                      size: const Size(48, 48),
                      painter: AvatarParticlePainter(
                        _particleAnimation.value,
                        isUser,
                      ),
                    ),

                    // Main icon
                    Icon(
                      isUser ? Icons.person_rounded : Icons.auto_awesome,
                      size: 24,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumMessageBubble() {
    final isUser = widget.message.isUser;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..scale(_isHovered ? 1.02 : 1.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minHeight: 60,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24).copyWith(
                  bottomRight: isUser ? const Radius.circular(8) : null,
                  bottomLeft: !isUser ? const Radius.circular(8) : null,
                ),
                gradient: isUser
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.purple.withOpacity(0.7),
                    Colors.pink.withOpacity(0.6),
                  ],
                )
                    : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.10),
                    Colors.cyan.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.white.withOpacity(0.3)
                      : Colors.cyan.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? Colors.purple : Colors.cyan)
                        .withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24).copyWith(
                  bottomRight: isUser ? const Radius.circular(8) : null,
                  bottomLeft: !isUser ? const Radius.circular(8) : null,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.message.isLoading)
                          _buildEnhancedLoadingIndicator()
                        else
                          _buildMessageContent(),

                        const SizedBox(height: 12),

                        _buildMessageFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent() {
    final isUser = widget.message.isUser;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SelectableText(
            widget.message.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingIndicator() {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sophisticated loading animation
            SizedBox(
              width: 40,
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  final delay = index * 0.3;
                  final animValue = (_typingAnimation.value + delay) % 1.0;
                  final scale = 0.5 + 0.5 * math.sin(animValue * 2 * math.pi);

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyan.withOpacity(scale),
                            Colors.blue.withOpacity(scale * 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(scale * 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(width: 16),

            // Enhanced typing text with shimmer
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.cyan.withOpacity(0.8),
                    Colors.blue.withOpacity(0.8),
                    Colors.white.withOpacity(0.5),
                  ],
                  stops: [
                    (_typingAnimation.value - 0.3).clamp(0.0, 1.0),
                    (_typingAnimation.value - 0.1).clamp(0.0, 1.0),
                    (_typingAnimation.value + 0.1).clamp(0.0, 1.0),
                    (_typingAnimation.value + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'AI is thinking...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageFooter() {
    final isUser = widget.message.isUser;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timestamp with enhanced styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Text(
            DateFormat('HH:mm').format(widget.message.timestamp),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),

        if (!widget.message.isLoading && !widget.message.isUser) ...[
          const SizedBox(width: 12),
          _buildEnhancedCopyButton(),
        ],
      ],
    );
  }

  Widget _buildEnhancedCopyButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _copyToClipboard(),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _showCopyFeedback
                  ? LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.3),
                  Colors.cyan.withOpacity(0.2),
                ],
              )
                  : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: _showCopyFeedback
                    ? Colors.green.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _showCopyFeedback ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(_showCopyFeedback),
                size: 16,
                color: _showCopyFeedback
                    ? Colors.green.shade300
                    : Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));
    HapticFeedback.lightImpact();

    setState(() => _showCopyFeedback = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showCopyFeedback = false);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.8),
                  Colors.cyan.withOpacity(0.6),
                ],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Message copied to clipboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) ...[
                    _buildEnhancedAvatar(),
                    const SizedBox(width: 16),
                  ],

                  Flexible(child: _buildPremiumMessageBubble()),

                  if (isUser) ...[
                    const SizedBox(width: 16),
                    _buildEnhancedAvatar(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AvatarParticlePainter extends CustomPainter {
  final double animation;
  final bool isUser;

  AvatarParticlePainter(this.animation, this.isUser);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + animation;
      final particleRadius = radius * 0.6;
      final x = center.dx + math.cos(angle) * particleRadius;
      final y = center.dy + math.sin(angle) * particleRadius;

      final paint = Paint()
        ..color = (isUser
            ? [Colors.blue, Colors.purple, Colors.pink]
            : [Colors.cyan, Colors.blue, Colors.green])[i % 3]
            .withOpacity(0.3)
        ..strokeWidth = 1;

      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}