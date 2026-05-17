import 'package:flutter/material.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/uzbek_phone_input_formatter.dart';
import '../../data/mock/mock_accounts.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
    this.errorText,
  });

  final Future<void> Function({
    required String phone,
    required String password,
  }) onSubmit;

  final bool isSubmitting;
  final String? errorText;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  static const double _pillRadius = 999;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: UzbekPhoneInputFormatter.visiblePrefix,
    );
    _phoneController.selection = TextSelection.collapsed(
      offset: _phoneController.text.length,
    );
  }

  InputDecoration _pillDecoration(BuildContext context, {String? hint}) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
        fontSize: 14,
      ),
      filled: true,
      isDense: true,
      fillColor: scheme.surface.withValues(alpha: 0.92),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide(
          color: scheme.outline.withValues(alpha: 0.55),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide(color: scheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.85)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_pillRadius),
        borderSide: BorderSide(color: scheme.error, width: 1.6),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final normalized = UzbekPhoneInputFormatter.normalizeForSubmit(value ?? '');
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 12 || !digits.startsWith('998')) {
      return 'To\'liq telefon: +998 XX XXX XX XX';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Parolni kiriting';
    if (value.length < 6) return 'Parol kamida 6 ta belgi bo\'lishi kerak';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final phone = UzbekPhoneInputFormatter.normalizeForSubmit(_phoneController.text);
    await widget.onSubmit(
      phone: phone,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = textTheme.labelLarge?.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.88),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    );

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Telefon raqam', style: labelStyle),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                UzbekPhoneInputFormatter(),
              ],
              validator: _validatePhone,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.25,
              ),
              decoration: _pillDecoration(
                context,
                hint: UzbekPhoneInputFormatter.formatFromStoreKey(
                  MockAccounts.ownerPhone,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Parol', style: labelStyle),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: _validatePassword,
              onFieldSubmitted: (_) => _submit(),
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.25,
              ),
              decoration: _pillDecoration(context),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: scheme.outline, width: 1.6),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return scheme.primary;
                      }
                      return scheme.surface.withValues(alpha: 0.95);
                    }),
                    checkColor: scheme.onPrimary,
                    onChanged: widget.isSubmitting
                        ? null
                        : (v) => setState(() => _rememberMe = v ?? false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.isSubmitting
                        ? null
                        : () => setState(() => _rememberMe = !_rememberMe),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Meni eslab qol',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.errorText != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: scheme.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.errorText!,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    Color.lerp(scheme.primary, scheme.secondary, 0.42)!,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.42),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isSubmitting ? null : _submit,
                  borderRadius: BorderRadius.circular(18),
                  splashColor: Colors.white.withValues(alpha: 0.18),
                  highlightColor: Colors.white.withValues(alpha: 0.08),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: Center(
                      child: widget.isSubmitting
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: scheme.onPrimary,
                              ),
                            )
                          : Text(
                              'Kirish',
                              style: textTheme.titleMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.65),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Sinov akkauntlari',
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Egasi · ${UzbekPhoneInputFormatter.formatFromStoreKey(MockAccounts.ownerPhone)}\n'
                    'Menejer · ${UzbekPhoneInputFormatter.formatFromStoreKey(MockAccounts.managerPhone)}\n'
                    'Ishchi · ${UzbekPhoneInputFormatter.formatFromStoreKey(MockAccounts.workerPhone)}\n'
                    'Parol: owner123 · manager123 · worker123',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.55,
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
}
