import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final authState = ref.watch(authStateProvider);
    final controllerState = ref.watch(authControllerProvider);
    final supabaseState = ref.watch(supabaseBootstrapProvider);
    final currentUser = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(strings.account)),
      body: DashboardPageScaffold(
        bottomPadding: 40,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.profile,
            title: strings.account,
            subtitle: strings.accountSubtitle,
          ),
          const SizedBox(height: 24),
          if (!supabaseState.isConfigured)
            DashboardSurfaceCard(
              radius: 28,
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.supabaseUnavailable,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    supabaseState.errorMessage ??
                        strings.supabaseUnavailableHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else if (currentUser != null)
            _SignedInCard(
              email: currentUser.email ?? strings.signedInNoEmail,
              onRetrySync: controllerState.isSubmitting
                  ? null
                  : () async {
                      await ref
                          .read(syncControllerProvider.notifier)
                          .synchronize();
                    },
              onSignOut: controllerState.isSubmitting
                  ? null
                  : () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                    },
            )
          else
            DashboardSurfaceCard(
              radius: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text(strings.signIn),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text(strings.createAccount),
                      ),
                    ],
                    selected: {_isSignUp},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _isSignUp = selection.first;
                      });
                      ref.read(authControllerProvider.notifier).clearMessages();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const ValueKey('account-email-field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: InputDecoration(
                      labelText: strings.email,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const ValueKey('account-password-field'),
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: strings.password,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey('submit-account-auth'),
                      onPressed: controllerState.isSubmitting ? null : _submit,
                      child: Text(
                        controllerState.isSubmitting
                            ? strings.workingState
                            : (_isSignUp
                                  ? strings.createAccount
                                  : strings.signIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (controllerState.errorMessage != null)
            _MessageCard(message: controllerState.errorMessage!, isError: true),
          if (controllerState.infoMessage != null)
            _MessageCard(message: controllerState.infoMessage!, isError: false),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ref
          .read(authControllerProvider.notifier)
          .setValidationError('Email and password are required.');
      return;
    }

    final notifier = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      await notifier.signUp(email: email, password: password);
    } else {
      await notifier.signIn(email: email, password: password);
    }
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({
    required this.email,
    required this.onRetrySync,
    required this.onSignOut,
  });

  final String email;
  final VoidCallback? onRetrySync;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DashboardSurfaceCard(
      radius: 28,
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            email,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cloud sync is ready for this account once the next tasks are implemented.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            key: const ValueKey('retry-sync-button'),
            onPressed: onRetrySync,
            child: const Text('Retry Sync'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            key: const ValueKey('sign-out-button'),
            onPressed: onSignOut,
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError ? colorScheme.error : colorScheme.primary;
    return DashboardSurfaceCard(
      radius: 24,
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}
