import 'package:finguard/features/profile/data/model/profile_model.dart';
import 'package:finguard/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileViewmodel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewmodel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Stack(
            children: [
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.profile == null
                  ? _buildLoadError(vm)
                  : _buildBody(vm),
              if (vm.isSigningOut)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError(ProfileViewmodel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 44, color: Colors.grey),
            const SizedBox(height: 10),
            Text(vm.error ?? "Failed to load profile"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadProfile,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProfileViewmodel vm) {
    final profile = vm.profile!;

    return RefreshIndicator(
      onRefresh: vm.loadProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _buildHeader(profile),
          const SizedBox(height: 20),
          if (!profile.isPro && vm.subscriptionEnabled) _buildUpgradeCard(vm),
          _sectionCard(
            title: "Preferences",
            children: [
              _tile(
                icon: Icons.currency_exchange_rounded,
                label: "Currency",
                value: profile.preferredCurrency,
              ),
              _tile(
                icon: Icons.language_rounded,
                label: "Language",
                value: profile.preferredLanguage.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: "Account",
            children: [
              _checkUpdateButton(vm),
              const SizedBox(height: 12),
              _logoutButton(vm),
            ],
          ),
          const SizedBox(height: 30),
          _buildAppVersion(vm),
        ],
      ),
    );
  }

  Widget _logoutButton(ProfileViewmodel vm) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: vm.isSigningOut ? null : () => _confirmAndSignOut(vm),
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFD64545)),
        label: const Text(
          "Sign out",
          style: TextStyle(
            color: Color(0xFFD64545),
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF2B8B8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _checkUpdateButton(ProfileViewmodel vm) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: vm.isCheckingUpdate ? null : () => _checkForUpdates(vm),
        icon: const Icon(Icons.system_update_rounded),
        label: Text(
          vm.isCheckingUpdate ? "Checking..." : "Check for updates",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _checkForUpdates(ProfileViewmodel vm) async {
    try {
      final result = await vm.checkForUpdates();
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update check is not supported here.")),
        );
        return;
      }

      if (result.maintenanceMode) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Maintenance"),
            content: Text(
              result.message ??
                  "Service is currently under maintenance. Please try again later.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      if (!result.hasUpdate) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Up to date"),
            content: Text(
              "You are already using the latest version (${result.currentVersion}).",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            result.forceUpdate ? "Update required" : "Update available",
          ),
          content: Text(
            "Current: ${result.currentVersion}\nLatest: ${result.latestVersion ?? '-'}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Later"),
            ),
            ElevatedButton(
              onPressed: () async {
                final raw = result.storeUrl;
                if (raw != null && raw.trim().isNotEmpty) {
                  final uri = Uri.tryParse(raw.trim());
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Update now"),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to check for updates.")),
      );
    }
  }

  Future<void> _confirmAndSignOut(ProfileViewmodel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Sign out?"),
          content: const Text("You will need to sign in again to continue."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Sign out"),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final success = await vm.signOut();
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to sign out")));
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _buildHeader(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E5CE6), Color(0xFF7A78EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E5CE6).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              profile.name?.substring(0, 1) ?? "U",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email ?? "",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          _planBadge(profile.plan),
        ],
      ),
    );
  }

  Widget _planBadge(String plan) {
    final isPro = plan == "PRO";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPro
            ? Colors.amber.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        plan,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(ProfileViewmodel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF56AB2F).withValues(alpha: 0.35),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Unlock Finguard Pro",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            "Advanced risk forecasting\nAI financial insights\nUnlimited trend history",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isSubscribing
                  ? null
                  : () async {
                      try {
                        await vm.subscribeToPro();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Subscription activated successfully.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56AB2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(vm.isSubscribing ? "Processing..." : "Upgrade Now"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF5E5CE6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF5E5CE6)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAppVersion(ProfileViewmodel vm) {
  final version = vm.appVersion;
  if (version == null) {
    return const SizedBox.shrink();
  }
  return Column(
    children: [
      const Divider(height: 40),
      Text(
        "Finguard",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "Version $version",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
}
