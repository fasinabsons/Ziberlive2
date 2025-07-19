import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../../../../domain/entities/gamification.dart';

class AnimatedCommunityTree extends StatefulWidget {
  final TreeGrowthLevel level;
  final Season season;
  final AnimationController growthController;
  final AnimationController particleController;
  final VoidCallback? onTreeTap;

  const AnimatedCommunityTree({
    Key? key,
    required this.level,
    required this.season,
    required this.growthController,
    required this.particleController,
    this.onTreeTap,
  }) : super(key: key);

  @override
  State<AnimatedCommunityTree> createState() => _AnimatedCommunityTreeState();
}

class _AnimatedCommunityTreeState extends State<AnimatedCommunityTree>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late Animation<double> _swayAnimation;
  late Animation<double> _growthAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _swayController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _swayAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _swayController,
      curve: Curves.easeInOut,
    ));

    _growthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.growthController,
      curve: Curves.elasticOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.particleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTreeTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _swayAnimation,
          _growthAnimation,
          _particleAnimation,
        ]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _swayAnimation.value,
            child: Transform.scale(
              scale: _growthAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Particle effects
                  if (_particleAnimation.value > 0)
                    ..._buildParticleEffects(),
                  
                  // Main tree
                  CustomPaint(
                    size: Size(200, 300),
                    painter: TreePainter(
                      level: widget.level,
                      season: widget.season,
                      growthProgress: _growthAnimation.value,
                    ),
                  ),
                  
                  // Seasonal decorations
                  ..._buildSeasonalDecorations(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParticleEffects() {
    final particles = <Widget>[];
    final particleCount = 12;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * 3.14159) / particleCount;
      final distance = 50 + (30 * _particleAnimation.value);
      
      particles.add(
        Positioned(
          left: 100 + (distance * Math.cos(angle)) - 4,
          top: 150 + (distance * Math.sin(angle)) - 4,
          child: Opacity(
            opacity: 1 - _particleAnimation.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getSeasonalSparkleColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getSeasonalSparkleColor().withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return particles;
  }

  List<Widget> _buildSeasonalDecorations() {
    switch (widget.season) {
      case Season.spring:
        return _buildSpringDecorations();
      case Season.summer:
        return _buildSummerDecorations();
      case Season.autumn:
        return _buildAutumnDecorations();
      case Season.winter:
        return _buildWinterDecorations();
    }
  }

  List<Widget> _buildSpringDecorations() {
    return [
      // Flowers around the base
      Positioned(
        bottom: 20,
        left: 60,
        child: _buildFlower(Colors.pink, 12),
      ),
      Positioned(
        bottom: 25,
        right: 70,
        child: _buildFlower(Colors.yellow, 10),
      ),
      Positioned(
        bottom: 15,
        left: 120,
        child: _buildFlower(Colors.purple, 8),
      ),
    ];
  }

  List<Widget> _buildSummerDecorations() {
    return [
      // Butterflies
      Positioned(
        top: 80,
        right: 40,
        child: _buildButterfly(),
      ),
      // Sun rays effect
      Positioned(
        top: 20,
        right: 20,
        child: _buildSunRays(),
      ),
    ];
  }

  List<Widget> _buildAutumnDecorations() {
    return [
      // Falling leaves
      Positioned(
        top: 100,
        left: 30,
        child: _buildFallingLeaf(Colors.orange),
      ),
      Positioned(
        top: 120,
        right: 50,
        child: _buildFallingLeaf(Colors.red),
      ),
      Positioned(
        top: 140,
        left: 80,
        child: _buildFallingLeaf(Colors.brown),
      ),
    ];
  }

  List<Widget> _buildWinterDecorations() {
    return [
      // Snowflakes
      Positioned(
        top: 60,
        left: 40,
        child: _buildSnowflake(),
      ),
      Positioned(
        top: 90,
        right: 60,
        child: _buildSnowflake(),
      ),
      Positioned(
        top: 120,
        left: 100,
        child: _buildSnowflake(),
      ),
    ];
  }

  Widget _buildFlower(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildButterfly() {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_swayAnimation.value * 20, _swayAnimation.value * 10),
          child: Icon(
            Icons.flutter_dash,
            color: Colors.orange[300],
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildSunRays() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.yellow.withOpacity(0.6),
            Colors.yellow.withOpacity(0.0),
          ],
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFallingLeaf(Color color) {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _swayAnimation.value * 15,
            (_swayController.value * 20) % 20,
          ),
          child: Transform.rotate(
            angle: _swayAnimation.value * 2,
            child: Icon(
              Icons.eco,
              color: color,
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnowflake() {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _swayAnimation.value * 10,
            (_swayController.value * 15) % 15,
          ),
          child: Icon(
            Icons.ac_unit,
            color: Colors.white.withOpacity(0.8),
            size: 12,
          ),
        );
      },
    );
  }

  Color _getSeasonalSparkleColor() {
    switch (widget.season) {
      case Season.spring:
        return Colors.green[300]!;
      case Season.summer:
        return Colors.yellow[300]!;
      case Season.autumn:
        return Colors.orange[300]!;
      case Season.winter:
        return Colors.blue[300]!;
    }
  }
}

class TreePainter extends CustomPainter {
  final TreeGrowthLevel level;
  final Season season;
  final double growthProgress;

  TreePainter({
    required this.level,
    required this.season,
    required this.growthProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Draw trunk
    _drawTrunk(canvas, size, paint);
    
    // Draw branches based on growth level
    _drawBranches(canvas, size, paint);
    
    // Draw leaves/foliage
    _drawFoliage(canvas, size, paint);
    
    // Draw roots (visible for higher levels)
    if (level.index >= TreeGrowthLevel.matureTree.index) {
      _drawRoots(canvas, size, paint);
    }
  }

  void _drawTrunk(Canvas canvas, Size size, Paint paint) {
    final trunkWidth = _getTrunkWidth();
    final trunkHeight = _getTrunkHeight() * growthProgress;
    
    paint.color = _getTrunkColor();
    
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - trunkHeight / 2),
        width: trunkWidth,
        height: trunkHeight,
      ),
      Radius.circular(trunkWidth / 4),
    );
    
    canvas.drawRRect(trunkRect, paint);
    
    // Add trunk texture for mature trees
    if (level.index >= TreeGrowthLevel.youngTree.index) {
      _drawTrunkTexture(canvas, trunkRect, paint);
    }
  }

  void _drawBranches(Canvas canvas, Size size, Paint paint) {
    final branchCount = _getBranchCount();
    final branchLength = _getBranchLength() * growthProgress;
    
    paint.color = _getTrunkColor();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    final centerX = size.width / 2;
    final branchStartY = size.height - _getTrunkHeight() * growthProgress + 20;
    
    for (int i = 0; i < branchCount; i++) {
      final angle = (i * 2 * 3.14159) / branchCount;
      final endX = centerX + (branchLength * Math.cos(angle));
      final endY = branchStartY + (branchLength * Math.sin(angle));
      
      canvas.drawLine(
        Offset(centerX, branchStartY),
        Offset(endX, endY),
        paint,
      );
      
      // Draw sub-branches for higher levels
      if (level.index >= TreeGrowthLevel.matureTree.index) {
        _drawSubBranches(canvas, Offset(endX, endY), angle, paint);
      }
    }
  }

  void _drawSubBranches(Canvas canvas, Offset start, double baseAngle, Paint paint) {
    paint.strokeWidth = 1.5;
    final subBranchLength = 15.0;
    
    for (int i = 0; i < 3; i++) {
      final angle = baseAngle + (i - 1) * 0.5;
      final endX = start.dx + (subBranchLength * Math.cos(angle));
      final endY = start.dy + (subBranchLength * Math.sin(angle));
      
      canvas.drawLine(start, Offset(endX, endY), paint);
    }
  }

  void _drawFoliage(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = _getFoliageColor();
    
    final foliageRadius = _getFoliageRadius() * growthProgress;
    final centerX = size.width / 2;
    final centerY = size.height - _getTrunkHeight() * growthProgress - foliageRadius / 2;
    
    // Main foliage circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      foliageRadius,
      paint,
    );
    
    // Additional foliage clusters for higher levels
    if (level.index >= TreeGrowthLevel.youngTree.index) {
      _drawAdditionalFoliage(canvas, centerX, centerY, foliageRadius, paint);
    }
    
    // Mystical glow for highest level
    if (level == TreeGrowthLevel.mysticalTree) {
      _drawMysticalGlow(canvas, centerX, centerY, foliageRadius, paint);
    }
  }

  void _drawAdditionalFoliage(Canvas canvas, double centerX, double centerY, double mainRadius, Paint paint) {
    final smallRadius = mainRadius * 0.6;
    
    // Left cluster
    canvas.drawCircle(
      Offset(centerX - mainRadius * 0.7, centerY + mainRadius * 0.3),
      smallRadius,
      paint,
    );
    
    // Right cluster
    canvas.drawCircle(
      Offset(centerX + mainRadius * 0.7, centerY + mainRadius * 0.3),
      smallRadius,
      paint,
    );
    
    // Top cluster
    canvas.drawCircle(
      Offset(centerX, centerY - mainRadius * 0.5),
      smallRadius * 0.8,
      paint,
    );
  }

  void _drawMysticalGlow(Canvas canvas, double centerX, double centerY, double radius, Paint paint) {
    paint.shader = RadialGradient(
      colors: [
        Colors.purple.withOpacity(0.3),
        Colors.blue.withOpacity(0.2),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 1.5));
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * 1.5,
      paint,
    );
    
    paint.shader = null; // Reset shader
  }

  void _drawRoots(Canvas canvas, Size size, Paint paint) {
    paint.color = _getTrunkColor().withOpacity(0.7);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    
    final centerX = size.width / 2;
    final rootStartY = size.height;
    final rootLength = 30.0;
    
    // Draw 3 main roots
    for (int i = 0; i < 3; i++) {
      final angle = 3.14159 + (i - 1) * 0.5;
      final endX = centerX + (rootLength * Math.cos(angle));
      final endY = rootStartY + (rootLength * Math.sin(angle));
      
      canvas.drawLine(
        Offset(centerX, rootStartY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  void _drawTrunkTexture(Canvas canvas, RRect trunkRect, Paint paint) {
    paint.color = _getTrunkColor().withOpacity(0.3);
    paint.strokeWidth = 1;
    
    // Draw horizontal lines for bark texture
    for (double y = trunkRect.top + 10; y < trunkRect.bottom - 10; y += 8) {
      canvas.drawLine(
        Offset(trunkRect.left + 2, y),
        Offset(trunkRect.right - 2, y),
        paint,
      );
    }
  }

  double _getTrunkWidth() {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 8;
      case TreeGrowthLevel.sapling:
        return 12;
      case TreeGrowthLevel.youngTree:
        return 16;
      case TreeGrowthLevel.matureTree:
        return 20;
      case TreeGrowthLevel.ancientTree:
        return 24;
      case TreeGrowthLevel.mysticalTree:
        return 28;
    }
  }

  double _getTrunkHeight() {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 40;
      case TreeGrowthLevel.sapling:
        return 60;
      case TreeGrowthLevel.youngTree:
        return 80;
      case TreeGrowthLevel.matureTree:
        return 100;
      case TreeGrowthLevel.ancientTree:
        return 120;
      case TreeGrowthLevel.mysticalTree:
        return 140;
    }
  }

  int _getBranchCount() {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 0;
      case TreeGrowthLevel.sapling:
        return 3;
      case TreeGrowthLevel.youngTree:
        return 5;
      case TreeGrowthLevel.matureTree:
        return 7;
      case TreeGrowthLevel.ancientTree:
        return 9;
      case TreeGrowthLevel.mysticalTree:
        return 12;
    }
  }

  double _getBranchLength() {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 0;
      case TreeGrowthLevel.sapling:
        return 20;
      case TreeGrowthLevel.youngTree:
        return 30;
      case TreeGrowthLevel.matureTree:
        return 40;
      case TreeGrowthLevel.ancientTree:
        return 50;
      case TreeGrowthLevel.mysticalTree:
        return 60;
    }
  }

  double _getFoliageRadius() {
    switch (level) {
      case TreeGrowthLevel.seedling:
        return 15;
      case TreeGrowthLevel.sapling:
        return 25;
      case TreeGrowthLevel.youngTree:
        return 35;
      case TreeGrowthLevel.matureTree:
        return 45;
      case TreeGrowthLevel.ancientTree:
        return 55;
      case TreeGrowthLevel.mysticalTree:
        return 65;
    }
  }

  Color _getTrunkColor() {
    return Colors.brown[600]!;
  }

  Color _getFoliageColor() {
    switch (season) {
      case Season.spring:
        return Colors.green[400]!;
      case Season.summer:
        return Colors.green[600]!;
      case Season.autumn:
        return Colors.orange[400]!;
      case Season.winter:
        return Colors.green[800]!;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}