import 'package:flutter/material.dart';
import 'package:frontend/model/data_model.dart';
import 'package:frontend/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
      ],
      child: MaterialApp(
        title: 'Crypto Swiper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeScreenProvider>().fetchData();
    });
  }

  void _onCardSwiped() {
    final provider = context.read<HomeScreenProvider>();
    if (_currentIndex < provider.data.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Swiper', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: Consumer<HomeScreenProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.data.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.data.isEmpty) {
            return const Center(
              child: Text('No data', style: TextStyle(color: Colors.white)),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: _buildCardStack(provider.data),
                  ),
                ),
              ),
              _buildBottomButtons(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${_currentIndex + 1} / ${provider.data.length}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCardStack(List<DataModel> data) {
    List<Widget> cards = [];

    if (_currentIndex + 2 < data.length) {
      cards.add(
        Transform.scale(
          scale: 0.9,
          child: Opacity(
            opacity: 0.5,
            child: CryptoCard(crypto: data[_currentIndex + 2]),
          ),
        ),
      );
    }

    if (_currentIndex + 1 < data.length) {
      cards.add(
        Transform.scale(
          scale: 0.95,
          child: Opacity(
            opacity: 0.7,
            child: CryptoCard(crypto: data[_currentIndex + 1]),
          ),
        ),
      );
    }

    if (_currentIndex < data.length) {
      cards.add(
        SwipeableCard(
          key: ValueKey(_currentIndex),
          crypto: data[_currentIndex],
          onSwiped: _onCardSwiped,
        ),
      );
    }

    return cards;
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            icon: Icons.close,
            color: Colors.redAccent,
            onTap: _onCardSwiped,
          ),
          _buildCircleButton(
            icon: Icons.favorite,
            color: Colors.greenAccent,
            onTap: _onCardSwiped,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class SwipeableCard extends StatefulWidget {
  final DataModel crypto;
  final VoidCallback onSwiped;

  const SwipeableCard({
    super.key,
    required this.crypto,
    required this.onSwiped,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Offset _dragPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * 0.3;

    if (_dragPosition.dx.abs() > swipeThreshold) {
      _animateCardAway();
    } else {
      _animateCardBack();
    }
  }

  void _animateCardAway() {
    final screenWidth = MediaQuery.of(context).size.width;
    final direction = _dragPosition.dx > 0 ? 1.0 : -1.0;

    final animation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset(direction * screenWidth * 1.5, _dragPosition.dy),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    animation.addListener(() {
      setState(() => _dragPosition = animation.value);
    });

    _animController.forward().then((_) {
      widget.onSwiped();
    });
  }

  void _animateCardBack() {
    final animation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    ));

    animation.addListener(() {
      setState(() => _dragPosition = animation.value);
    });

    _animController.forward().then((_) {
      _animController.reset();
      setState(() {
        _dragPosition = Offset.zero;
        _isDragging = false;
      });
    });
  }

  double _getRotation() {
    return _dragPosition.dx * 0.0003;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragPosition,
        child: Transform.rotate(
          angle: _getRotation(),
          child: Stack(
            children: [
              CryptoCard(crypto: widget.crypto),
              if (_isDragging && _dragPosition.dx > 40)
                Positioned(
                  top: 30,
                  left: 30,
                  child: _buildSwipeLabel('LIKE', Colors.green),
                ),
              if (_isDragging && _dragPosition.dx < -40)
                Positioned(
                  top: 30,
                  right: 30,
                  child: _buildSwipeLabel('NOPE', Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeLabel(String text, Color color) {
    return Transform.rotate(
      angle: text == 'LIKE' ? -0.2 : 0.2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final DataModel crypto;

  const CryptoCard({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    final change = double.tryParse(crypto.changePercent24Hr) ?? 0;
    final isUp = change >= 0;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    crypto.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isUp ? Colors.green : Colors.red).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isUp ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      Text(
                        '${change.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isUp ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              crypto.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rank #${crypto.rank}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 25),
            const Text(
              'Current Price',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            Text(
              '\$${double.parse(crypto.priceUsd).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatRow('Market Cap', '\$${_formatBillion(crypto.marketCapUsd)}B'),
                    _buildStatRow('Volume 24h', '\$${_formatBillion(crypto.volumeUsd24Hr)}B'),
                    _buildStatRow('Supply', '${_formatMillion(crypto.supply)}M'),
                    _buildStatRow(
                      'Max Supply',
                      crypto.maxSupply.isEmpty || crypto.maxSupply == 'null'
                          ? 'Unlimited'
                          : '${_formatMillion(crypto.maxSupply)}M',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatBillion(String value) {
    final num = double.tryParse(value) ?? 0;
    return (num / 1e9).toStringAsFixed(2);
  }

  String _formatMillion(String value) {
    final num = double.tryParse(value) ?? 0;
    return (num / 1e6).toStringAsFixed(2);
  }
}
