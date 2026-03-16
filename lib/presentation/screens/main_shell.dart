import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../cubits/chat/chat_cubit.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ChatScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : AppTheme.divider,
            ),
          ),
        ),
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (_, state) => BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline_rounded),
                activeIcon: Icon(Icons.lightbulb_rounded),
                label: 'Suggestions',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Stack(children: [
                  const Icon(Icons.history_rounded),
                  if (state.messages.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ]),
                activeIcon: const Icon(Icons.history_rounded),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
