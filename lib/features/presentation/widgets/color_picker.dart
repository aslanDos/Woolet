import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onChanged,
    this.itemSize = 32,
    this.spacing = 4,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onChanged;
  final double itemSize;
  final double spacing;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  static const _selectedScale = 1.2;

  late final ScrollController _controller;
  late int _selectedIndex;
  bool _isSettling = false;

  double get _itemSlotSize => widget.itemSize * _selectedScale;
  double get _itemExtent => _itemSlotSize + widget.spacing;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexOf(widget.selected);
    _controller = ScrollController(
      initialScrollOffset: _selectedIndex * _itemExtent,
    )..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = _indexOf(widget.selected);
    if (nextIndex == _selectedIndex) return;

    _selectedIndex = nextIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollTo(nextIndex);
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  int _indexOf(Color color) {
    final index = widget.colors.indexWhere(
      (item) => item.toARGB32() == color.toARGB32(),
    );
    return index < 0 ? 0 : index;
  }

  int _nearestIndex() {
    if (widget.colors.isEmpty) return 0;
    return (_controller.offset / _itemExtent).round().clamp(
      0,
      widget.colors.length - 1,
    );
  }

  void _onScroll() {
    if (widget.colors.isEmpty) return;
    final index = _nearestIndex();
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);
    HapticFeedback.selectionClick();
  }

  Future<void> _scrollTo(int index) async {
    if (!_controller.hasClients) return;

    final target = (index * _itemExtent).clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );
    if ((_controller.offset - target).abs() < 0.5) return;

    await _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _commit(int index) {
    if (widget.colors.isEmpty) return;
    final color = widget.colors[index];
    if (color.toARGB32() != widget.selected.toARGB32()) {
      widget.onChanged(color);
    }
  }

  Future<void> _settleAndCommit() async {
    if (_isSettling || widget.colors.isEmpty) return;
    _isSettling = true;

    final index = _nearestIndex();
    if (index != _selectedIndex) setState(() => _selectedIndex = index);

    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await _scrollTo(index);
    if (!mounted) return;

    _commit(index);
    _isSettling = false;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification && !_isSettling) {
      _settleAndCommit();
    }
    return false;
  }

  Future<void> _onColorTap(int index) async {
    if (_isSettling) return;
    _isSettling = true;

    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      HapticFeedback.selectionClick();
    }

    await _scrollTo(index);
    if (!mounted) return;

    _commit(index);
    _isSettling = false;
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.colors.isNotEmpty, 'ColorPicker.colors must not be empty.');
    if (widget.colors.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = (constraints.maxWidth - _itemSlotSize) / 2;

          return NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: widget.colors.length,
              separatorBuilder: (_, _) => SizedBox(width: widget.spacing),
              itemBuilder: (context, index) {
                final selected = index == _selectedIndex;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onColorTap(index),
                  child: SizedBox(
                    width: _itemSlotSize,
                    child: Center(
                      child: AnimatedSlide(
                        offset: selected ? const Offset(0, -0.2) : Offset.zero,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        child: AnimatedScale(
                          scale: selected ? _selectedScale : 1,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: widget.itemSize,
                            height: widget.itemSize,
                            decoration: BoxDecoration(
                              color: widget.colors[index],
                              borderRadius: BorderRadius.circular(7),
                              // border: selected
                              //     ? Border.all(
                              //         color: context.c.onSurface,
                              //         width: 1.5,
                              //       )
                              //     : null,
                            ),
                          ),
                        ),
                      ),
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
}
