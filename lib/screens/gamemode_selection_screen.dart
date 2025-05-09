import 'package:flutter/material.dart';
import 'game_history_screen.dart';
import 'score_screen.dart';
import 'team_selection_screen.dart';
import '../theme/app_theme.dart';

class GameModeSelectionScreen extends StatefulWidget {
  @override
  _GameModeSelectionScreenState createState() =>
      _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  bool _enableDisqualification = true;
  bool _isFabExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      _isFabExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('何人で遊ぶ？', style: AppTheme.heading),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameModeButton(
                  label: '一人で',
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoreScreen(
                          teamNames: ['Player 1'],
                          enableDisqualification: _enableDisqualification,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 57),
                _buildGameModeButton(
                  label: '複数人で',
                  icon: Icons.groups,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamSelectionScreen(
                          enableDisqualification: _enableDisqualification,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildGameModeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 109,
          height: 109,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: AppTheme.secondaryButton,
            ),
            child: Center(
              child: Icon(icon, size: 90, color: AppTheme.textDark),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: AppTheme.label),
      ],
    );
  }

  Widget _buildFabMenu() {
    return Stack(
      children: [
        if (_isFabExpanded) ...[
          Positioned(
            bottom: 100,
            right: 16,
            child: ScaleTransition(
              scale: _animationController,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _enableDisqualification = !_enableDisqualification;
                  });
                  _toggleFab();
                },
                label: Text(
                  _enableDisqualification ? '失格モードを無効' : '失格モードを有効',
                  style: TextStyle(color: AppTheme.textDark),
                ),
                icon: Icon(Icons.toggle_on, color: AppTheme.textDark),
                backgroundColor: AppTheme.secondaryButton.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 170,
            right: 16,
            child: ScaleTransition(
              scale: _animationController,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameHistoryScreen(),
                    ),
                  );
                },
                label: Text(
                  'ゲーム履歴を見る',
                  style: TextStyle(color: AppTheme.textDark),
                ),
                icon: Icon(Icons.history, color: AppTheme.textDark),
                backgroundColor: AppTheme.secondaryButton.withOpacity(0.5),
              ),
            ),
          ),
        ],
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleFab,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
              color: AppTheme.textDark,
            ),
            backgroundColor: AppTheme.secondaryButton.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
