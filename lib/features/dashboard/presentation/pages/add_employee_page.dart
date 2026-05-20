import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../core/utils/uzbek_phone_input_formatter.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';
import '../../../../shared/widgets/brand/brand_primary_button.dart';
import '../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../shared/widgets/brand/brand_text_field.dart';
import '../models/workshop_mock_models.dart';
import '../providers/workshop_mock_providers.dart';

/// Owner uchun yangi xodim qo'shish sahifasi (modal route).
class AddEmployeePage extends ConsumerStatefulWidget {
  const AddEmployeePage({super.key});

  @override
  ConsumerState<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends ConsumerState<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  DateTime? _birthDate;
  String _role = 'worker';

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final s = S.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: s.pickBirthDate,
      cancelText: s.cancel,
      confirmText: s.confirmOk,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  Future<void> _submit() async {
    final s = S.of(context);
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.pickBirthDate)),
      );
      return;
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final employee = Employee(
      id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: UzbekPhoneInputFormatter.normalizeForSubmit(_phone.text),
      role: _role,
      birthDate: _birthDate,
    );

    ref.read(employeesProvider.notifier).add(employee);
    ref.read(attendanceProvider.notifier).addIfMissing(
          id: employee.id,
          name: employee.fullName,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.employeeAddedSnack(employee.fullName)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        const BrandDashboardBackdrop(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: scheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              s.newEmployee,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _HeaderHero(title: s.expandTeam, hint: s.expandTeamHint),
                  const SizedBox(height: 16),
                  _Section(
                    title: s.personalInfo,
                    child: Column(
                      children: [
                        BrandTextField(
                          controller: _firstName,
                          hintText: s.firstNameHint,
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().length < 2)
                                  ? s.firstNameRequired
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        BrandTextField(
                          controller: _lastName,
                          hintText: s.lastNameHint,
                          prefixIcon: Icons.badge_outlined,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().length < 2)
                                  ? s.lastNameRequired
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        _BirthDateField(
                          value: _birthDate,
                          label: _birthDate == null
                              ? s.birthDate
                              : _formatDate(_birthDate!),
                          onTap: _pickBirthDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: s.rolePosition,
                    child: Row(
                      children: [
                        Expanded(
                          child: _RoleChip(
                            icon: Icons.work_rounded,
                            label: s.roleTailor,
                            description: s.roleTailorHint,
                            selected: _role == 'worker',
                            onTap: () => setState(() => _role = 'worker'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RoleChip(
                            icon: Icons.supervisor_account_rounded,
                            label: s.roleManager,
                            description: s.roleManagerHint,
                            selected: _role == 'manager',
                            onTap: () => setState(() => _role = 'manager'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: s.loginInfo,
                    child: Column(
                      children: [
                        BrandTextField(
                          controller: _phone,
                          hintText: '+998 90 123 45 67',
                          prefixIcon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [UzbekPhoneInputFormatter()],
                          validator: (v) {
                            final digits = (v ?? '')
                                .replaceAll(RegExp(r'\D'), '');
                            if (digits.length != 12) {
                              return s.phoneIncomplete;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        BrandTextField(
                          controller: _password,
                          hintText: s.passwordLabel,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: scheme.onSurfaceVariant,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? s.passwordMin6
                              : null,
                        ),
                        const SizedBox(height: 12),
                        BrandTextField(
                          controller: _confirmPassword,
                          hintText: s.confirmPasswordHint,
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: scheme.onSurfaceVariant,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return s.confirmPasswordRequired;
                            }
                            if (v != _password.text) {
                              return s.passwordMismatch;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  BrandPrimaryButton(
                    label: s.addEmployeeAction,
                    icon: Icons.person_add_alt_1_rounded,
                    loading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.employeeFooterHint,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header hero card ────────────────────────────────────────────────────────

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.black, isDark ? 0.12 : 0.24)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.40),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section ─────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BrandSurface(
      solid: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ─── Birthdate selector ──────────────────────────────────────────────────────

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final DateTime? value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = value != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: isDark
                ? scheme.surfaceContainerHigh
                : Colors.white,
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cake_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: hasValue
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant.withValues(alpha: 0.65),
                    fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                color: scheme.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Role chip ───────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: isDark ? 0.25 : 0.14),
                    scheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                  ],
                )
              : null,
          color: selected
              ? null
              : (isDark
                  ? AppColors.darkCardHigh
                  : const Color(0xFFF4F7FC)),
          border: Border.all(
            color: selected
                ? scheme.primary
                : (isDark
                    ? AppColors.darkBorder
                    : const Color(0xFFE2E8F0)),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          scheme.primary,
                          Color.lerp(
                              scheme.primary, Colors.black, 0.18)!,
                        ],
                      )
                    : null,
                color: selected
                    ? null
                    : scheme.primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
