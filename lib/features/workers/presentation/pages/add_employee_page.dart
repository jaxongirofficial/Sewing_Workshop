import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/uzbek_phone_input_formatter.dart';
import '../../../../l10n/s.dart';
import '../../../../shared/widgets/brand/brand_dashboard_backdrop.dart';
import '../../../../shared/widgets/brand/brand_primary_button.dart';
import '../../../../shared/widgets/brand/brand_text_field.dart';
import '../../../workshop/models/workshop_mock_models.dart';
import '../../../workshop/presentation/providers/workshop_mock_providers.dart';
import '../widgets/add_employee_birth_date_field.dart';
import '../widgets/add_employee_header_hero.dart';
import '../widgets/add_employee_role_chip.dart';
import '../widgets/add_employee_section.dart';

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
                  AddEmployeeHeaderHero(
                    title: s.expandTeam,
                    hint: s.expandTeamHint,
                  ),
                  const SizedBox(height: 16),
                  AddEmployeeSection(
                    title: s.personalInfo,
                    child: Column(
                      children: [
                        BrandTextField(
                          controller: _firstName,
                          hintText: s.firstNameHint,
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().length < 2)
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
                          validator: (v) => (v == null || v.trim().length < 2)
                              ? s.lastNameRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AddEmployeeBirthDateField(
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
                  AddEmployeeSection(
                    title: s.rolePosition,
                    child: Row(
                      children: [
                        Expanded(
                          child: AddEmployeeRoleChip(
                            icon: Icons.work_rounded,
                            label: s.roleTailor,
                            description: s.roleTailorHint,
                            selected: _role == 'worker',
                            onTap: () => setState(() => _role = 'worker'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AddEmployeeRoleChip(
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
                  AddEmployeeSection(
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
                            final digits =
                                (v ?? '').replaceAll(RegExp(r'\D'), '');
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
