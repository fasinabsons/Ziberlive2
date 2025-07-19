import 'package:flutter/material.dart';
import '../../../../domain/entities/gamification.dart';
import 'dart:math' as Math;

class SeasonalDecorations extends StatefulWidget {
  final Season season;
  final AnimationController animationController;

  const SeasonalDecorations({
    Key? key,
    required this.season,
    required this.animationController,
  }) : super(key: key);

  @override
  State<SeasonalDecorations> createState() => _SeasonalDecorationsState();
}

class _SeasonalDecorationsState extends State<SeasonalDecorations>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late List<AnimationController> _particleControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Create multiple particle controllers for different effects
    _particleControllers = List.generate(5, (index) {
      return AnimationController(
        duration: Duration(seconds: 3 + index),
        vsync: this,
      )..repeat();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    for (final controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background atmospheric effects
        _buildAtmosphericEffects(),
        
        // Seasonal particles
        ..._buildSeasonalParticles(),
        
        // Ground decorations
        _buildGroundDecorations(),
      ],
    );
  }

  Widget _buildAtmosphericEffects() {
    switch (widget.season) {
      case Season.spring:
        return _buildSpringAtmosphere();
      case Season.summer:
        return _buildSummerAtmosphere();
      case Season.autumn:
        return _buildAutumnAtmosphere();
      case Season.winter:
        return _buildWinterAtmosphere();
    }
  }

  Widget _buildSpringAtmosphere() {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.3, -0.5),
              radius: 1.5,
              colors: [
                Colors.yellow.withOpacity(0.1 * widget.animationController.value),
                Colors.green.withOpacity(0.05 * widget.animationController.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummerAtmosphere() {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.4, -0.6),
              radius: 1.2,
              colors: [
                Colors.orange.withOpacity(0.15 * widget.animationController.value),
                Colors.yellow.withOpacity(0.08 * widget.animationController.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAutumnAtmosphere() {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.withOpacity(0.1 * widget.animationController.value),
                Colors.brown.withOpacity(0.05 * widget.animationController.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWinterAtmosphere() {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withOpacity(0.08 * widget.animationController.value),
                Colors.white.withOpacity(0.05 * widget.animationController.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSeasonalParticles() {
    switch (widget.season) {
      case Season.spring:
        return _buildSpringParticles();
      case Season.summer:
        return _buildSummerParticles();
      case Season.autumn:
        return _buildAutumnParticles();
      case Season.winter:
        return _buildWinterParticles();
    }
  }

  List<Widget> _buildSpringParticles() {
    final particles = <Widget>[];
    
    // Floating pollen particles
    for (int i = 0; i < 8; i++) {
      particles.add(
        AnimatedBuilder(
          animation: _particleControllers[i % _particleControllers.length],
          builder: (context, child) {
            final controller = _particleControllers[i % _particleControllers.length];
            final offset = Offset(
              50 + (i * 40) + (Math.sin(controller.value * 2 * Math.pi) * 20),
              100 + (i * 30) + (Math.cos(controller.value * 2 * Math.pi) * 15),
            );
            
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Opacity(
                opacity: 0.6 + (0.4 * Math.sin(controller.value * Math.pi)),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.yellow[300],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return particles;
  }

  List<Widget> _buildSummerParticles() {
    final particles = <Widget>[];
    
    // Floating light particles (fireflies effect)
    for (int i = 0; i < 6; i++) {
      particles.add(
        AnimatedBuilder(
          animation: _particleControllers[i % _particleControllers.length],
          builder: (context, child) {
            final controller = _particleControllers[i % _particleControllers.length];
            final offset = Offset(
              30 + (i * 50) + (Math.sin(controller.value * 2 * Math.pi + i) * 25),
              80 + (i * 40) + (Math.cos(controller.value * 2 * Math.pi + i) * 20),
            );
            
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + (0.7 * Math.sin(_floatingController.value * Math.pi)),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.orange[200],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }
    
    return particles;
  }

  List<Widget> _buildAutumnParticles() {
    final particles = <Widget>[];
    final leafColors = [Colors.orange, Colors.red, Colors.brown, Colors.yellow];
    
    // Falling leaves
    for (int i = 0; i < 10; i++) {
      particles.add(
        AnimatedBuilder(
          animation: _particleControllers[i % _particleControllers.length],
          builder: (context, child) {
            final controller = _particleControllers[i % _particleControllers.length];
            final fallProgress = controller.value;
            final swayAmount = Math.sin(fallProgress * 4 * Math.pi) * 30;
            
            final offset = Offset(
              20 + (i * 35) + swayAmount,
              -20 + (fallProgress * 400), // Fall from top to bottom
            );
            
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Transform.rotate(
                angle: fallProgress * 4 * Math.pi,
                child: Icon(
                  Icons.eco,
                  color: leafColors[i % leafColors.length],
                  size: 12 + (i % 3) * 2,
                ),
              ),
            );
          },
        ),
      );
    }
    
    return particles;
  }

  List<Widget> _buildWinterParticles() {
    final particles = <Widget>[];
    
    // Falling snowflakes
    for (int i = 0; i < 12; i++) {
      particles.add(
        AnimatedBuilder(
          animation: _particleControllers[i % _particleControllers.length],
          builder: (context, child) {
            final controller = _particleControllers[i % _particleControllers.length];
            final fallProgress = controller.value;
            final swayAmount = Math.sin(fallProgress * 3 * Math.pi) * 20;
            
            final offset = Offset(
              10 + (i * 30) + swayAmount,
              -30 + (fallProgress * 450), // Fall from top to bottom
            );
            
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * Math.pi,
                    child: Icon(
                      Icons.ac_unit,
                      color: Colors.white.withOpacity(0.8),
                      size: 8 + (i % 4) * 2,
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }
    
    return particles;
  }

  Widget _buildGroundDecorations() {
    switch (widget.season) {
      case Season.spring:
        return _buildSpringGround();
      case Season.summer:
        return _buildSummerGround();
      case Season.autumn:
        return _buildAutumnGround();
      case Season.winter:
        return _buildWinterGround();
    }
  }

  Widget _buildSpringGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 60,
      child: AnimatedBuilder(
        animation: widget.animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.withOpacity(0.1 * widget.animationController.value),
                  Colors.green.withOpacity(0.2 * widget.animationController.value),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFlower(Colors.pink, 8),
                _buildFlower(Colors.yellow, 6),
                _buildFlower(Colors.purple, 7),
                _buildFlower(Colors.white, 5),
                _buildFlower(Colors.red, 6),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummerGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.withOpacity(0.15),
              Colors.green.withOpacity(0.25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutumnGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.withOpacity(0.1),
              Colors.brown.withOpacity(0.2),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.eco, color: Colors.orange[300], size: 12),
            Icon(Icons.eco, color: Colors.red[300], size: 10),
            Icon(Icons.eco, color: Colors.brown[300], size: 14),
            Icon(Icons.eco, color: Colors.yellow[600], size: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildWinterGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 30,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlower(Color color, double size) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, Math.sin(_floatingController.value * Math.pi) * 2),
          child: Container(
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
          ),
        );
      },
    );
  }
}