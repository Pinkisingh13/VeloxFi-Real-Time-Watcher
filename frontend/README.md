# Crypto Swiper - Flutter Learning Project

A Flutter app where I learned to build Tinder-style swipe animations from scratch. This project helped me understand how Flutter animations work under the hood.

## What I Built

A cryptocurrency price viewer with swipeable cards. Users can swipe through different crypto coins (Bitcoin, Ethereum, etc.) just like swiping on Tinder.

## What I Learned

### 1. AnimationController

The foundation of Flutter animations. It controls the animation's duration and provides values from 0.0 to 1.0.

```dart
_animController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300),
);
```

**Key points:**
- `vsync: this` requires `SingleTickerProviderStateMixin`
- Always dispose the controller in `dispose()` method
- Use `forward()` to start and `reset()` to restart

### 2. Tween and CurvedAnimation

Tween defines the start and end values. CurvedAnimation adds easing effects.

```dart
final animation = Tween<Offset>(
  begin: _dragPosition,
  end: Offset.zero,
).animate(CurvedAnimation(
  parent: _animController,
  curve: Curves.elasticOut,  // Bouncy effect!
));
```

**Curves I experimented with:**
- `Curves.easeOut` - smooth deceleration
- `Curves.elasticOut` - spring/bounce effect
- `Curves.linear` - constant speed

### 3. GestureDetector for Drag Handling

Used pan gestures to track finger movement:

```dart
GestureDetector(
  onPanStart: _onPanStart,   // User starts dragging
  onPanUpdate: _onPanUpdate, // User is dragging
  onPanEnd: _onPanEnd,       // User releases
  child: ...
)
```

**What happens in each callback:**
- `onPanStart` - Set dragging state to true
- `onPanUpdate` - Update position with `details.delta`
- `onPanEnd` - Decide: animate away or bounce back

### 4. Transform Widgets

Used to move and rotate the card based on drag position:

```dart
Transform.translate(
  offset: _dragPosition,
  child: Transform.rotate(
    angle: _dragPosition.dx * 0.0003,  // Subtle rotation
    child: ...
  ),
)
```

**The rotation trick:** Multiply horizontal drag by a small number (0.0003) to get natural-looking tilt.

### 5. Card Stack Effect

Created depth illusion using `Transform.scale` and `Opacity`:

```dart
// Background card (smaller, faded)
Transform.scale(
  scale: 0.9,
  child: Opacity(
    opacity: 0.5,
    child: CryptoCard(...),
  ),
)
```

### 6. State Management with Provider

Used Provider package for managing app state:

```dart
// In provider
class HomeScreenProvider extends ChangeNotifier {
  List<DataModel> _data = [];
  
  Future<void> fetchData() async {
    _data = await ApiService.fetchData();
    notifyListeners();  // Rebuild UI
  }
}

// In widget
Consumer<HomeScreenProvider>(
  builder: (context, provider, _) {
    return ListView(...);
  },
)
```

### 7. Periodic Data Refresh

Used `Timer.periodic` to fetch fresh data every 15 minutes:

```dart
Timer.periodic(Duration(milliseconds: 900000), (timer) {
  fetchData();
});
```

## How The Swipe Animation Works

**Step 1:** User starts dragging
- `_isDragging = true`
- Show LIKE/NOPE labels based on direction

**Step 2:** User drags the card
- Update `_dragPosition` with finger movement
- Card follows finger + rotates slightly

**Step 3:** User releases
- Check if drag distance > 30% of screen width
- If yes → animate card off screen → load next card
- If no → animate card back to center with bounce

**Step 4:** Animation completes
- Reset animation controller
- Update current card index

## Project Structure

```
lib/
├── main.dart           # UI + Animation logic
├── provider.dart       # State management
├── api_base.dart       # API base URL
├── model/
│   └── data_model.dart # Crypto data model
└── service/
    └── api.dart        # API calls
```

## Key Files

| File | Purpose |
|------|---------|
| `main.dart` | Contains `SwipeableCard` widget with all animation logic |
| `provider.dart` | Manages crypto data and loading state |
| `api.dart` | Fetches data from backend API |

## How to Run

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

Make sure the backend server is running on `localhost:8000`

## Tech Stack

- Flutter 3.x
- Provider (state management)
- HTTP package (API calls)
- Dart Timer (periodic refresh)

## Animation Concepts Summary

| Concept | What it does |
|---------|--------------|
| `AnimationController` | Controls animation timing |
| `Tween<T>` | Defines start/end values |
| `CurvedAnimation` | Adds easing effects |
| `Transform.translate` | Moves widget |
| `Transform.rotate` | Rotates widget |
| `GestureDetector` | Handles touch input |

## What's Next

Things I want to explore:
- [ ] Add haptic feedback on swipe
- [ ] Implement undo last swipe
- [ ] Add more animation curves
- [ ] Try `AnimatedBuilder` instead of `addListener`

---

Built while learning Flutter animations 🚀
