import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class S {
  const S._(this.locale, this._messages);

  final Locale locale;
  final Map<String, String> _messages;

  static const supportedLocales = [
    Locale('uz'),
    Locale('en'),
    Locale('ru'),
  ];

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static S of(BuildContext context) {
    final s = Localizations.of<S>(context, S);
    assert(s != null, 'No S localizations found in context.');
    return s!;
  }

  static Future<S> load(Locale locale) async {
    final languageCode = _supportedLanguageCode(locale.languageCode);
    final data = await rootBundle.loadString('lib/l10n/app_$languageCode.arb');
    final raw = json.decode(data) as Map<String, dynamic>;
    final messages = <String, String>{
      for (final entry in raw.entries)
        if (!entry.key.startsWith('@') && entry.value is String)
          entry.key: entry.value as String,
    };
    return S._(Locale(languageCode), messages);
  }

  static String _supportedLanguageCode(String languageCode) {
    return switch (languageCode) {
      'en' => 'en',
      'ru' => 'ru',
      _ => 'uz',
    };
  }

  String _t(String key) => _messages[key] ?? key;

  String _f(String key, Map<String, Object> values) {
    var text = _t(key);
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return text;
  }

  String get appName => _t('appName');
  String get appTagline => _t('appTagline');
  String get welcomeTitle => _t('welcomeTitle');
  String get welcomeSubtitle => _t('welcomeSubtitle');
  String get phoneLabel => _t('phoneLabel');
  String get passwordLabel => _t('passwordLabel');
  String get passwordHint => _t('passwordHint');
  String get signIn => _t('signIn');
  String get phoneValidation => _t('phoneValidation');
  String get passwordRequired => _t('passwordRequired');
  String get passwordMinLength => _t('passwordMinLength');
  String get invalidCredentials => _t('invalidCredentials');
  String get genericError => _t('genericError');

  String get roleOwner => _t('roleOwner');
  String get roleManager => _t('roleManager');
  String get roleWorker => _t('roleWorker');
  String get home => _t('home');
  String get homePage => _t('homePage');
  String get attendance => _t('attendance');
  String get tasks => _t('tasks');
  String get task => _t('task');
  String get myTasks => _t('myTasks');
  String get warehouse => _t('warehouse');
  String get profile => _t('profile');

  String get ownerHomeSubtitle => _t('ownerHomeSubtitle');
  String get managerHomeSubtitle => _t('managerHomeSubtitle');
  String get workerHomeSubtitle => _t('workerHomeSubtitle');
  String get hello => _t('hello');
  String helloName(String name) => _f('helloName', {'name': name});
  String get recentTasks => _t('recentTasks');
  String get all => _t('all');
  String get teamStatus => _t('teamStatus');
  String get fullList => _t('fullList');
  String get noAssignedTasks => _t('noAssignedTasks');
  String get noTasksYet => _t('noTasksYet');
  String get todayMetrics => _t('todayMetrics');
  String get todayAtWork => _t('todayAtWork');
  String get activeRecords => _t('activeRecords');
  String get active => _t('active');
  String get team => _t('team');
  String get workersList => _t('workersList');
  String get demo => _t('demo');
  String get quickActions => _t('quickActions');
  String get mark => _t('mark');
  String get createNew => _t('createNew');
  String get distribute => _t('distribute');
  String get todayStatus => _t('todayStatus');
  String get atWork => _t('atWork');
  String get notAtWork => _t('notAtWork');
  String entryTime(String time) => _f('entryTime', {'time': time});
  String get noTime => _t('noTime');
  String get notArrivedYet => _t('notArrivedYet');
  String get inList => _t('inList');
  String get goToList => _t('goToList');
  String atWorkWithTime(String time) => _f('atWorkWithTime', {'time': time});
  String get absent => _t('absent');

  String get attendanceWorkerHint => _t('attendanceWorkerHint');
  String get attendanceManagerHint => _t('attendanceManagerHint');
  String get attendanceOwnerHint => _t('attendanceOwnerHint');
  String todayAtWorkSummary(int present, int total) {
    return _f('todayAtWorkSummary', {'present': present, 'total': total});
  }

  String get newTask => _t('newTask');
  String get taskInputHint => _t('taskInputHint');
  String get assignTo => _t('assignTo');
  String get assignTask => _t('assignTask');
  String get yourTasks => _t('yourTasks');
  String get seedTaskDresses => _t('seedTaskDresses');
  String get seedTaskQc => _t('seedTaskQc');

  String get deleteConfirmTitle => _t('deleteConfirmTitle');
  String deleteWarehouseItemMessage(String name) {
    return _f('deleteWarehouseItemMessage', {'name': name});
  }

  String get cancel => _t('cancel');
  String get delete => _t('delete');
  String get totalPieces => _t('totalPieces');
  String get productTypes => _t('productTypes');
  String get category => _t('category');
  String get allCategories => _t('allCategories');
  String get addProduct => _t('addProduct');
  String get low => _t('low');
  String get filteredEmptyTitle => _t('filteredEmptyTitle');
  String get warehouseEmptyTitle => _t('warehouseEmptyTitle');
  String get filteredEmptyHint => _t('filteredEmptyHint');
  String get warehouseEmptyHint => _t('warehouseEmptyHint');
  String get newProduct => _t('newProduct');
  String get productNameHint => _t('productNameHint');
  String get nameRequired => _t('nameRequired');
  String get quantityHint => _t('quantityHint');
  String get numberRequired => _t('numberRequired');
  String get unitHint => _t('unitHint');
  String get save => _t('save');
  String get categoryClothing => _t('categoryClothing');
  String get categoryMaterial => _t('categoryMaterial');
  String get categoryAccessory => _t('categoryAccessory');
  String get categoryOther => _t('categoryOther');
  String get productPants => _t('productPants');
  String get productDress => _t('productDress');
  String get productSleeve => _t('productSleeve');
  String get productSkirt => _t('productSkirt');
  String get productJacket => _t('productJacket');
  String get productBag => _t('productBag');
  String get productBelt => _t('productBelt');
  String get productBlueFabric => _t('productBlueFabric');
  String get productWhiteThread => _t('productWhiteThread');
  String get productButton => _t('productButton');
  String get unitPiece => _t('unitPiece');
  String get unitMeter => _t('unitMeter');
  String get unitItem => _t('unitItem');

  String get userFallback => _t('userFallback');
  String get no => _t('no');
  String get settings => _t('settings');
  String get security => _t('security');
  String get passwordLoginHistory => _t('passwordLoginHistory');
  String get notifications => _t('notifications');
  String get pushEmail => _t('pushEmail');
  String get language => _t('language');
  String get theme => _t('theme');
  String get help => _t('help');
  String get faqGuide => _t('faqGuide');
  String get aboutApp => _t('aboutApp');
  String get appVersion => _t('appVersion');
  String get signOut => _t('signOut');
  String get chooseLanguage => _t('chooseLanguage');
  String get chooseLanguageHint => _t('chooseLanguageHint');
  String get languageUzbek => _t('languageUzbek');
  String get languageEnglish => _t('languageEnglish');
  String get languageRussian => _t('languageRussian');
  String get languageUzbekHint => _t('languageUzbekHint');
  String get languageEnglishHint => _t('languageEnglishHint');
  String get languageRussianHint => _t('languageRussianHint');
  String get chooseTheme => _t('chooseTheme');
  String get chooseThemeHint => _t('chooseThemeHint');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get themeSystem => _t('themeSystem');
  String get themeLightHint => _t('themeLightHint');
  String get themeDarkHint => _t('themeDarkHint');
  String get themeSystemHint => _t('themeSystemHint');

  String get addEmployeeTooltip => _t('addEmployeeTooltip');
  String get newEmployee => _t('newEmployee');
  String get expandTeam => _t('expandTeam');
  String get expandTeamHint => _t('expandTeamHint');
  String get personalInfo => _t('personalInfo');
  String get firstNameHint => _t('firstNameHint');
  String get lastNameHint => _t('lastNameHint');
  String get firstNameRequired => _t('firstNameRequired');
  String get lastNameRequired => _t('lastNameRequired');
  String get birthDate => _t('birthDate');
  String get pickBirthDate => _t('pickBirthDate');
  String get rolePosition => _t('rolePosition');
  String get roleTailor => _t('roleTailor');
  String get roleTailorHint => _t('roleTailorHint');
  String get roleManagerHint => _t('roleManagerHint');
  String get loginInfo => _t('loginInfo');
  String get phoneIncomplete => _t('phoneIncomplete');
  String get passwordMin6 => _t('passwordMin6');
  String get confirmPasswordHint => _t('confirmPasswordHint');
  String get confirmPasswordRequired => _t('confirmPasswordRequired');
  String get passwordMismatch => _t('passwordMismatch');
  String get addEmployeeAction => _t('addEmployeeAction');
  String get employeeFooterHint => _t('employeeFooterHint');
  String employeeAddedSnack(String name) =>
      _f('employeeAddedSnack', {'name': name});
  String workersCount(int count) => _f('workersCount', {'count': count});
  String get workersEmpty => _t('workersEmpty');
  String get workersEmptyHint => _t('workersEmptyHint');
  String metricsPercent(int percent) =>
      _f('metricsPercent', {'percent': percent});
  String get hubSectionTitle => _t('hubSectionTitle');
  String get openAttendance => _t('openAttendance');
  String get openTasks => _t('openTasks');
  String get openTeamList => _t('openTeamList');
  String get workerUpdateStatus => _t('workerUpdateStatus');
  String get workerViewTasks => _t('workerViewTasks');
  String attendanceRatio(int present, int total) =>
      _f('attendanceRatio', {'present': present, 'total': total});
  String get confirmOk => _t('confirmOk');
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) {
    return S.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(_SDelegate old) => false;
}
