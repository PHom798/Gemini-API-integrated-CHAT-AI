import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _isFocused = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _sendButtonController;
  late AnimationController _loadingController;
  late AnimationController _focusController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _sendButtonScale;
  late Animation<double> _loadingRotation;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListener();
  }

  void _initializeAnimations() {
    // Pulse animation for the border glow
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer effect for placeholder text
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Send button scale animation
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Loading spinner rotation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Focus animation
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create animations
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _sendButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));

    _loadingRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_loadingController);

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.2),
      end: Colors.cyan.withOpacity(0.8),
    ).animate(_focusController);

    // Start loading animation if initially loading
    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_focusNode.hasFocus) {
        _focusController.forward();
        HapticFeedback.lightImpact();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loading state changes
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _sendButtonController.dispose();
    _loadingController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty && !widget.isLoading) {
      final message = _controller.text.trim();
      _controller.clear();
      setState(() {
        _isComposing = false;
      });

      // Trigger send button animation
      _sendButtonController.forward().then((_) {
        _sendButtonController.reverse();
      });

      // Haptic feedback
      HapticFeedback.mediumImpact();

      widget.onSendMessage(message);
    }
  }

  Widget _buildShimmerPlaceholder() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.7),
                Colors.cyan.withOpacity(0.5),
                Colors.white.withOpacity(0.3),
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value - 0.1,
                _shimmerAnimation.value + 0.1,
                _shimmerAnimation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: Text(
            widget.isLoading ? 'AI is thinking...' : 'Ask me anything...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTextField() {
    return AnimatedBuilder(
      animation: Listenable.merge([_focusAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1 + _focusAnimation.value * 0.05),
                Colors.white.withOpacity(0.05 + _focusAnimation.value * 0.03),
              ],
            ),
            border: Border.all(
              color: _borderColorAnimation.value ?? Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: Colors.cyan.withOpacity(_pulseAnimation.value * 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 + _focusAnimation.value * 5,
                sigmaY: 10 + _focusAnimation.value * 5,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: '', // We'll use custom shimmer placeholder
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    counterText: '',
                  ),
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSendButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_sendButtonScale, _pulseAnimation]),
      builder: (context, child) {
        final isActive = _isComposing && !widget.isLoading;

        return Transform.scale(
          scale: _sendButtonScale.value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.cyan.withOpacity(0.8),
                  Colors.blue.withOpacity(0.8),
                  Colors.purple.withOpacity(0.6),
                ],
              )
                  : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: isActive
                    ? Colors.cyan.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: Colors.cyan.withOpacity(_pulseAnimation.value * 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isActive ? _handleSubmit : null,
                    onTapDown: isActive ? (_) => _sendButtonController.forward() : null,
                    onTapUp: isActive ? (_) => _sendButtonController.reverse() : null,
                    onTapCancel: isActive ? () => _sendButtonController.reverse() : null,
                    child: Container(
                      width: 56,
                      height: 56,
                      child: widget.isLoading
                          ? _buildLoadingIndicator()
                          : Icon(
                        Icons.send_rounded,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        size: 24,
                      ),
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

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _loadingRotation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Transform.rotate(
              angle: _loadingRotation.value,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.cyan.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Inner rotating element
            Transform.rotate(
              angle: -_loadingRotation.value * 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Colors.cyan,
                      Colors.blue,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Center dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Enhanced text field
          Expanded(
            child: Stack(
              children: [
                _buildEnhancedTextField(),

                // Custom placeholder with shimmer effect
                if (_controller.text.isEmpty)
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IgnorePointer(
                        child: _buildShimmerPlaceholder(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Enhanced send button
          _buildEnhancedSendButton(),
        ],
      ),
    );
  }
}