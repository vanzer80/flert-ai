import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _settingsItems.length,
        separatorBuilder: (context, index) {
          // Add section dividers
          if (index == 4 || index == 6) {
            return const SizedBox(height: 24);
          }
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          final item = _settingsItems[index];
          
          if (item.isSection) {
            return _buildSectionHeader(item.title);
          }
          
          if (item.isReferral) {
            return _buildReferralCard(context, item);
          }
          
          return _buildSettingsItem(context, item);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, SettingsItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: item.iconColor ?? AppColors.textPrimary,
          size: 24,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: item.isLogout ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        trailing: item.hasArrow
            ? const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              )
            : null,
        onTap: () => _handleItemTap(context, item),
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, SettingsItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE7E7), Color(0xFFFFF0F0)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.icon,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.subtitle ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Referral Tracker
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.referralTracker,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.0, // 0% progress
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.inviteMoreFriends,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(BuildContext context, SettingsItem item) {
    switch (item.type) {
      case SettingsItemType.contactUs:
        _showContactDialog(context);
        break;
      case SettingsItemType.helpGrow:
        _showHelpGrowDialog(context);
        break;
      case SettingsItemType.textSupport:
        _showTextSupportDialog(context);
        break;
      case SettingsItemType.language:
        _showLanguageDialog(context);
        break;
      case SettingsItemType.upgradePro:
        _showUpgradeDialog(context);
        break;
      case SettingsItemType.referrals:
        _showReferralsDialog(context);
        break;
      case SettingsItemType.logout:
        _showLogoutDialog(context);
        break;
      case null:
        // Handle null case - do nothing
        break;
    }
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.contactUs),
        content: const Text('Entre em contato conosco através do email: contato@flertaai.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showHelpGrowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.helpUsGrow),
        content: const Text('Avalie nosso app na loja e compartilhe com seus amigos!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showTextSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.getTextSupport),
        content: const Text('Suporte via WhatsApp: +55 11 99999-9999'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma'),
        content: const Text('Português (Brasil) - Selecionado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.upgradeToPro),
        content: const Text('Desbloqueie análises ilimitadas e tons premium!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium screen
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  void _showReferralsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.referralsAndRewards),
        content: const Text('Convide amigos e ganhe recompensas incríveis!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout realizado com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  static final List<SettingsItem> _settingsItems = [
    SettingsItem(
      icon: Icons.email,
      title: AppStrings.contactUs,
      type: SettingsItemType.contactUs,
    ),
    SettingsItem(
      icon: Icons.star,
      title: AppStrings.helpUsGrow,
      type: SettingsItemType.helpGrow,
    ),
    SettingsItem(
      icon: Icons.chat,
      title: AppStrings.getTextSupport,
      type: SettingsItemType.textSupport,
    ),
    SettingsItem(
      icon: Icons.language,
      title: AppStrings.language,
      type: SettingsItemType.language,
    ),
    SettingsItem(
      icon: Icons.workspace_premium,
      title: AppStrings.upgradeToPro,
      type: SettingsItemType.upgradePro,
      iconColor: AppColors.premiumGold,
    ),
    SettingsItem(
      title: AppStrings.referralsAndRewards,
      isSection: true,
    ),
    SettingsItem(
      icon: Icons.favorite,
      title: AppStrings.give40Get40,
      subtitle: AppStrings.inviteFriends,
      type: SettingsItemType.referrals,
      isReferral: true,
    ),
    SettingsItem(
      icon: Icons.logout,
      title: AppStrings.logout,
      type: SettingsItemType.logout,
      isLogout: true,
      hasArrow: false,
    ),
  ];
}

class SettingsItem {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final SettingsItemType? type;
  final Color? iconColor;
  final bool hasArrow;
  final bool isSection;
  final bool isReferral;
  final bool isLogout;

  SettingsItem({
    this.icon,
    required this.title,
    this.subtitle,
    this.type,
    this.iconColor,
    this.hasArrow = true,
    this.isSection = false,
    this.isReferral = false,
    this.isLogout = false,
  });
}

enum SettingsItemType {
  contactUs,
  helpGrow,
  textSupport,
  language,
  upgradePro,
  referrals,
  logout,
}
