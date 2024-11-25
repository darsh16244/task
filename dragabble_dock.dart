import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Draggable Dock')),
        body: const Dock(
          items: [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
          ],
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;

  /// Index of the item being dragged.
  int? _draggingIndex;

  /// Position of the dragged item.
  Offset? _draggingPosition;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items); // Make the list mutable
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, (index) {
                return _buildDraggableItem(index);
              }),
            ),
          ),
        ),
        if (_draggingIndex != null && _draggingPosition != null)
          Positioned(
            left: _draggingPosition!.dx,
            top: _draggingPosition!.dy,
            child: _buildDockItem(
              _items[_draggingIndex!],
              isDragging: true,
            ),
          ),
      ],
    );
  }

  Widget _buildDraggableItem(int index) {
    return GestureDetector(
      onLongPressStart: (details) {
        setState(() {
          _draggingIndex = index;
          _draggingPosition = details.globalPosition;
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _draggingPosition = details.globalPosition;
        });
      },
      onLongPressEnd: (details) {
        if (_draggingIndex != null && _draggingPosition != null) {
          _reorderItems(_draggingPosition!);
        }
        setState(() {
          _draggingIndex = null;
          _draggingPosition = null;
        });
      },
      child: AnimatedOpacity(
        opacity: _draggingIndex == index ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: _buildDockItem(_items[index]),
      ),
    );
  }

  void _reorderItems(Offset dropPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    final double itemWidth = box.size.width / _items.length;
    final int newIndex = ((dropPosition.dx - offset.dx) / itemWidth).clamp(0, _items.length - 1).toInt();

    if (newIndex != _draggingIndex) {
      final draggedItem = _items.removeAt(_draggingIndex!);
      _items.insert(newIndex, draggedItem);
    }
  }

  Widget _buildDockItem(IconData icon, {bool isDragging = false}) {
    return GestureDetector(
      child: Container(
        constraints: const BoxConstraints(minWidth: 48),
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDragging
              ? Colors.primaries[icon.hashCode % Colors.primaries.length].withOpacity(0.5)
              : Colors.primaries[icon.hashCode % Colors.primaries.length],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: isDragging ? 40 : 24,
          ),
        ),
      ),
    );
  }
}
