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
  late final List<T> _items = widget.items.toList();
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
          final isHoveredGap = _hoveredIndex == index && _draggingIndex != null;

          return Draggable<int>(
            data: index,
            feedback: Transform.scale(
              scale: 1.0,
              child: widget.builder(_items[index]),
            ),
            onDragStarted: () => setState(() {
              _draggingIndex = index;
            }),
            onDragEnd: (_) => setState(() {
              _draggingIndex = null;
              _hoveredIndex = null;
            }),
            childWhenDragging: const SizedBox(),
            child: DragTarget<int>(
              onWillAccept: (data) {
                setState(() {
                  _hoveredIndex = index;
                });
                return true;
              },
              onLeave: (_) => setState(() {
                _hoveredIndex = null;
              }),
              onAccept: (fromIndex) {
                setState(() {
                  final item = _items.removeAt(fromIndex);
                  _items.insert(index, item);
                  _hoveredIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(
                    horizontal: isHoveredGap ? 16 : 8, // Adjust margin for hover
                  ),
                  width: isDragging ? 60 : 48, // Highlight the dragged item
                  height: isDragging ? 60 : 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.primaries[
                    _items[index].hashCode % Colors.primaries.length],
                    boxShadow: isHoveredGap
                        ? [
                      const BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                        : [],
                  ),
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
