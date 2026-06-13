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

  @override
  void initState() {
    super.initState();
    DebugLog.addListener(_onLog);
  }

  @override
  void dispose() {
    DebugLog.removeListener(_onLog);
    super.dispose();
  }

  void _onLog() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible)
          Positioned(
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
                        setState(() => _visible = false);
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
        Positioned(
          bottom: 80,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                DebugLog.add("DEBUG button tapped!");
                setState(() => _visible = !_visible);
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
      ],
    );
  }
}
