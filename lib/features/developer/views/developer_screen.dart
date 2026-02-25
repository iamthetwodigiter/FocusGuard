import 'package:flutter/material.dart';
import 'package:focusguard/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Developer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Image / Avatar Placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'thetwodigiter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Flutter Developer',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDim.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            _buildAboutCard(),
            const SizedBox(height: 24),
            _buildPortfolioCard(),
            const SizedBox(height: 40),
            const Text(
              'Connect with me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  Icons.language_rounded,
                  'Website',
                  () => _launchUrl('https://www.thetwodigiter.app'),
                ),
                const SizedBox(width: 20),
                _buildSocialIcon(
                  Icons.code_rounded,
                  'GitHub',
                  () => _launchUrl('https://github.com/iamthetwodigiter'),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              '© 2026 FocusGuard by thetwodigiter',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textDim.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'I am a passionate software developer focused on creating elegant solutions for complex problems. FocusGuard is part of my effort to build tools that help people improve their daily lives.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDim,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.accentSecondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accent,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Explore My Portfolio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Discover more of my open-source projects and work here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textDim),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              textStyle: TextStyle(color: AppColors.text),
              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _launchUrl('https://www.thetwodigiter.app'),
            child: const Text(
              'thetwodigiter.app',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: AppColors.text, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textDim,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
