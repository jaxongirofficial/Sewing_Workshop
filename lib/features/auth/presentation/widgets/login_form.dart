import 'package:flutter/material.dart';

import '../../../../core/utils/uzbek_phone_input_formatter.dart';
import '../../../../shared/widgets/brand/brand_primary_button.dart';
import '../../../../shared/widgets/brand/brand_text_field.dart';

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
  bool _obscure = true;

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
    final phone =
        UzbekPhoneInputFormatter.normalizeForSubmit(_phoneController.text);
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
      color: scheme.onSurface.withValues(alpha: 0.85),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
    );

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Telefon raqam', style: labelStyle),
            const SizedBox(height: 10),
            BrandTextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [UzbekPhoneInputFormatter()],
              validator: _validatePhone,
              prefixIcon: Icons.phone_iphone_rounded,
              hintText: '+998 90 123 45 67',
            ),
            const SizedBox(height: 18),
            Text('Parol', style: labelStyle),
            const SizedBox(height: 10),
            BrandTextField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: _validatePassword,
              onFieldSubmitted: (_) => _submit(),
              prefixIcon: Icons.lock_outline_rounded,
              hintText: 'Parolingiz',
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (widget.errorText != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: scheme.error,
                    ),
                    const SizedBox(width: 10),
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
            const SizedBox(height: 22),
            BrandPrimaryButton(
              label: 'Kirish',
              icon: Icons.arrow_forward_rounded,
              loading: widget.isSubmitting,
              onPressed: widget.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
