import 'package:flutter/material.dart';
import 'team_name_screen.dart';
import 'score_screen.dart';
import '../theme/app_theme.dart';

class TeamSelectionScreen extends StatefulWidget {
  final bool enableDisqualification;

  TeamSelectionScreen({required this.enableDisqualification});

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  int? _selectedTeamCount;

  void _navigateToNextScreen(BuildContext context) {
    if (_selectedTeamCount == null) return;

    if (_selectedTeamCount == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            teamNames: ['Player 1'],
            enableDisqualification: widget.enableDisqualification,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamNameScreen(
            teamCount: _selectedTeamCount!,
            enableDisqualification: widget.enableDisqualification,
          ),
        ),
      );
    }
  }

  Widget _buildRadioOption(int teamCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryButton.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade100),
        ),
        child: RadioListTile<int>(
          value: teamCount,
          groupValue: _selectedTeamCount,
          onChanged: (value) {
            setState(() {
              _selectedTeamCount = value;
            });
          },
          title: Text('$teamCount チーム', style: AppTheme.label),
          activeColor: AppTheme.accent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('チーム数を選択', style: AppTheme.heading.copyWith(fontSize: 20)),
        leading: BackButton(),
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('チーム数を選択', style: AppTheme.heading.copyWith(fontSize: 20)),
            SizedBox(height: 20),
            _buildRadioOption(2),
            _buildRadioOption(3),
            _buildRadioOption(4),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedTeamCount != null
                    ? () => _navigateToNextScreen(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryButton,
                  shape: StadiumBorder(),
                  elevation: 0,
                ),
                child: Text('次へ', style: AppTheme.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}