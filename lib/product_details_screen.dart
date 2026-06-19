import 'dart:developer';

import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  /// Screen position the reveal circle expands from (the tapped card).
  final Offset offset;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.offset,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  static const _slideDuration = Duration(milliseconds: 400);

  /// Drives the product-info panel sliding up after the circle reveal.
  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: _slideDuration,
  );

  late final Animation<Offset> _contentSlide =
      Tween<Offset>(begin: const Offset(0.0, 1.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.fastOutSlowIn),
      );

  /// The route's push animation drives the circle reveal, keeping it in sync
  /// with the [Hero] flight. Resolved lazily once dependencies are available.
  late final Animation<double> _circleReveal = CurvedAnimation(
    parent: ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
    curve: Curves.easeInOut,
  );

  late final Size _screenSize = MediaQuery.of(context).size;
  late final double _maxDiameter = _screenSize.longestSide * 2.6;
  bool isSlideForwarded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _circleReveal.addListener(() {
      log('circle reveal: ${_circleReveal.value}');
      log('isSlideForwarded $isSlideForwarded');
      if(_circleReveal.value > 0.7 && !isSlideForwarded) {
        _slideController.forward();
        isSlideForwarded = true;
      }
    });
  }



  @override
  void dispose() {
   
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [_buildRevealCircle(), _buildContent()]),
    );
  }

  /// Layer 1: the black circle that grows from [widget.offset] to fill the screen.
  Widget _buildRevealCircle() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _circleReveal,
        builder: (context, _) {
          final diameter = _circleReveal.value * _maxDiameter;
          // The inner Stack isolates this Positioned from the outer
          // Positioned.fill so they don't both write StackParentData
          // to the same render object.
          return Stack(
            children: [
              Positioned(
                left: widget.offset.dx - diameter / 2,
                top: widget.offset.dy - diameter / 2,
                child: Container(
                  width: diameter,
                  height: diameter,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Layers 2 & 3: header, hero image, and the sliding product info panel.
  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: Hero(
                tag: widget.product['id'],
                child: Center(
                  child: Image.asset(
                    widget.product['image'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SlideTransition(
              position: _contentSlide,
              child: _buildProductInfo(),
            ),
          ],
        ),
      ),
    );
  }

  /// Back button and the rotated BOSE wordmark.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        const RotatedBox(
          quarterTurns: 1,
          child: Text(
            'BOSE',
            style: TextStyle(
              fontFamily: 'Arvo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'LIMITED EDITION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildColorDot(Colors.white, isSelected: true),
            _buildColorDot(Colors.orange[200]!, isSelected: false),
            _buildColorDot(Colors.amber, isSelected: false),
          ],
        ),
        const SizedBox(height: 30),
        _buildBuyButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBuyButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            widget.product['price'],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: CircleAvatar(radius: 10, backgroundColor: color),
    );
  }
}
