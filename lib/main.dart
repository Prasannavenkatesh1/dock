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
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  int? _draggingIndex;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black38,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final isDragging = _draggingIndex == index;
          final isHoveredGap = _hoveredIndex != null &&
              _hoveredIndex == index &&
              _draggingIndex != null;

          return Draggable<int>(
            data: index,
            feedback: Transform.scale(
              scale: 1.15,
              child: widget.builder(_items[index]),
            ),
            onDragStarted: () => setState(() => _draggingIndex = index),
            onDragEnd: (_) => setState(() {
              _draggingIndex = null;
              _hoveredIndex = null;
            }),
            childWhenDragging: const SizedBox(),
            child: DragTarget<int>(
              onWillAcceptWithDetails: (details) {
                setState(() {
                  _hoveredIndex = index;
                });
                return true;
              },
              onLeave: (_) => setState(() {
                _hoveredIndex = null;
              }),
              onAcceptWithDetails: (details) {
                final fromIndex = details.data;
                setState(() {
                  final item = _items.removeAt(fromIndex);
                  _items.insert(index, item);
                  _hoveredIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  margin: EdgeInsets.symmetric(
                    horizontal: isHoveredGap ? 20 : 10,
                  ),
                  width: 48.0,
                  height: 48.0,
                  transform: isDragging
                      ? (Matrix4.identity()..scale(1.1))
                      : Matrix4.identity(),
                  child: widget.builder(_items[index]),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class DockItem extends StatefulWidget {
  final IconData icon;
  const DockItem({Key? key, required this.icon}) : super(key: key);

  @override
  _DockItemState createState() => _DockItemState();
}

class _DockItemState extends State<DockItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isHovered ? 60 : 48,
        height: _isHovered ? 60 : 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.primaries[widget.icon.hashCode % Colors.primaries.length],
          boxShadow: _isHovered
              ? [
            const BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ]
              : [],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: _isHovered ? 30 : 24,
          ),
        ),
      ),
    );
  }
}