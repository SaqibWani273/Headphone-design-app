import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Helvetica', // Or your preferred clean sans-serif font
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: const ProductGridScreen(),
    );
  }
}

class ProductGridScreen extends StatefulWidget {
  const ProductGridScreen({super.key});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen>
    with TickerProviderStateMixin {
  late final _slideTransitionController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 500),
  )..forward();
  late final _slideTransition1 =
      Tween<Offset>(begin: Offset(-1.1, 0.0), end: Offset(0.0, 0.0)).animate(
        CurvedAnimation(
          parent: _slideTransitionController,
          curve: Curves.easeIn,
        ),
      );
  late final _slideTransition2 =
      Tween<Offset>(begin: Offset(1.3, 0.0), end: Offset(0.0, 0.0)).animate(
        CurvedAnimation(
          parent: _slideTransitionController,
          curve: Curves.easeIn,
        ),
      );
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'image': 'assets/images/headphone_pink.png',
        'title': 'QuietComfort 35\nwireless\nheadphones II',
        'price': '\$449.99',
        'isAvailable': true,
      },
      {
        'image': 'assets/images/headphone_black2.png',
        'title': 'SoundLink®\naroundear wireless\nheadphones',
        'price': '\$269.99',
        'isAvailable': true,
      },
      {
        'image': 'assets/images/black_blue_headphone.png',
        'title': 'Bose on-ear\nwireless\nheadphones',
        'price': '\$209.99',
        'isAvailable': true,
      },
      {
        'image': 'assets/images/headphone3.png',
        'title': 'Bose Noise\nCancelling\nHeadphones 700',
        'price': 'Coming Soon',
        'isAvailable': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 233),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Custom Navigation/Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Title and Side Brand Rotated Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SlideTransition(
                    position: _slideTransition1,
                    child: Text(
                      'Wireless\nHeadphones',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight
                            .w700, // Flutter will automatically find the Bold variant from the variable file
                        color: Colors.black,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Rotated BOSE Logo Text
                  SlideTransition(
                    position: _slideTransition2,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        'BOSE',
                        style: TextStyle(
                          fontFamily: 'Arvo',
                          fontSize:
                              26, // Scaled up slightly to match visual weight
                          fontWeight:
                              FontWeight.values[8], // Extreme heavy weight
                          fontStyle: FontStyle
                              .italic, // Crucial for the Bose slanted identity
                          letterSpacing: 2, // Moderate spacing
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Product Grid Layout
              Expanded(
                child: GridView.builder(
                  itemCount: products.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        0.62, // Form factor adjustment for standard cards
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product, index: index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final int index;
  const ProductCard({super.key, required this.product, required this.index});

  final Map<String, dynamic> product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.index % 2 == 0 ? 1.5 : -1.5, 0.0),

      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.fastOutSlowIn));
    _rotateAnimation = Tween<double>(
      begin: widget.index % 2 == 0 ? 0.1 : -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
        _slideController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: RotationTransition(
        turns: _rotateAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Wrapper
              Expanded(
                child: Center(
                  child: Image.asset(
                    widget.product['image'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Product Title
              Text(
                widget.product['title'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              // Pricing / Status Banner
              Text(
                widget.product['price'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.product['isAvailable']
                      ? Colors.grey[400]
                      : Colors.red[300], // Muted red for "Coming Soon"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
