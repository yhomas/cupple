import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'debug_log.dart';

class DebugOverlay extends StatefulWidget {
  final Widget child;
  const DebugOverlay({super.key, required this.child});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _visible = false;
  OverlayEntry? _buttonOverlay;
  OverlayEntry? _logOverlay;

  @override
  void initState() {
    super.initState();
    DebugLog.addListener(_onLog);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertButtonOverlay();
    });
  }

  @override
  void dispose() {
    DebugLog.removeListener(_onLog);
    _buttonOverlay?.remove();
    _logOverlay?.remove();
    super.dispose();
  }

  void _onLog() {
    if (mounted) setState(() {});
  }

  void _insertButtonOverlay() {
    _buttonOverlay?.remove();
    _buttonOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        right: 8,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              DebugLog.add("DEBUG button tapped!");
              _toggleLogOverlay();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _visible ? Colors.yellow : Colors.black54,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(_visible ? 'DEBUG X' : 'DEBUG', style: TextStyle(color: _visible ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_buttonOverlay!);
  }

  void _toggleLogOverlay() {
    setState(() => _visible = !_visible);
    if (_visible) {
      _logOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300,
          child: Material(
            color: Colors.black87,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text('DEBUG LOG', style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.copy, color: Colors.white, size: 18), onPressed: () {
                      Clipboard.setData(ClipboardData(text: DebugLog.logs.join('\n')));
                    }, tooltip: 'Copy'),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.white, size: 18), onPressed: () {
                      DebugLog.clear();
                    }, tooltip: 'Clear'),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: () {
                      _toggleLogOverlay();
                    }),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: DebugLog.logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        DebugLog.logs[index],
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_logOverlay!);
    } else {
      _logOverlay?.remove();
      _logOverlay = null;
    }
    _buttonOverlay?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
