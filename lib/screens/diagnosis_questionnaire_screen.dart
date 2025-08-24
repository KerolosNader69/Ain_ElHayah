import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/ai_chat_service.dart';

class DiagnosisQuestionnaireScreen extends StatefulWidget {
  const DiagnosisQuestionnaireScreen({super.key});

  @override
  State<DiagnosisQuestionnaireScreen> createState() => _DiagnosisQuestionnaireScreenState();
}

class _DiagnosisQuestionnaireScreenState extends State<DiagnosisQuestionnaireScreen> {
  int _step = 0;
  String _forWhom = 'self';
  String _gender = 'male';
  int _ageYears = 0;
  int _ageMonths = 0;
  int _ageDays = 0;
  String _recentInjury = 'unknown';
  String _smoking10Years = 'unknown';
  String _allergyFamily = 'unknown';
  String _obesity = 'unknown';
  String _diabetes = 'unknown';
  String _hypertension = 'unknown';
  String _headacheType = '';
  String _headacheSeverity = '';
  final TextEditingController _otherSymptoms = TextEditingController();
  final TextEditingController _country = TextEditingController();
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _structured;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appProvider = Provider.of<AppProvider>(context);
    AIChatService.setPreferredLanguageCode(appProvider.locale.languageCode);
  }

  @override
  void dispose() {
    _otherSymptoms.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode.startsWith('ar');
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(isArabic ? 'استبيان التشخيص' : 'Diagnosis Questionnaire'),
        backgroundColor: Colors.transparent,
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _onNext,
        onStepCancel: _onBack,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(onPressed: details.onStepContinue, child: Text(isArabic ? 'التالي' : 'Next')),
              const SizedBox(width: 8),
              if (_step > 0)
                TextButton(onPressed: details.onStepCancel, child: Text(isArabic ? 'رجوع' : 'Back')),
            ],
          );
        },
        steps: [
          Step(
            title: Text(isArabic ? 'لمن الفحص؟' : 'Who is this for?'),
            isActive: _step >= 0,
            content: Column(
              children: [
                _choice(isArabic ? 'لنفسي' : 'Myself', 'self', _forWhom, (v) => setState(() => _forWhom = v)),
                _choice(isArabic ? 'شخص آخر' : 'Someone else', 'other', _forWhom, (v) => setState(() => _forWhom = v)),
              ],
            ),
          ),
          Step(
            title: Text(isArabic ? 'النوع' : 'Gender'),
            isActive: _step >= 1,
            content: Column(
              children: [
                _choice(isArabic ? 'ذكر' : 'Male', 'male', _gender, (v) => setState(() => _gender = v)),
                _choice(isArabic ? 'أنثى' : 'Female', 'female', _gender, (v) => setState(() => _gender = v)),
              ],
            ),
          ),
          Step(
            title: Text(isArabic ? 'العمر' : 'Age'),
            isActive: _step >= 2,
            content: Row(
              children: [
                Expanded(child: _numField(isArabic ? 'سنوات' : 'Years', (v) => _ageYears = int.tryParse(v) ?? 0)),
                const SizedBox(width: 8),
                Expanded(child: _numField(isArabic ? 'أشهر' : 'Months', (v) => _ageMonths = int.tryParse(v) ?? 0)),
                const SizedBox(width: 8),
                Expanded(child: _numField(isArabic ? 'أيام' : 'Days', (v) => _ageDays = int.tryParse(v) ?? 0)),
              ],
            ),
          ),
          _ynStep(isArabic ? 'هل تعرضت لإصابة مؤخراً؟' : 'Recent injury?', (v) => _recentInjury = v, _recentInjury),
          _ynStep(isArabic ? 'تدخين 10 سنوات أو أكثر' : 'Smoking ≥10 years', (v) => _smoking10Years = v, _smoking10Years),
          _ynStep(isArabic ? 'تاريخ عائلي للحساسية؟' : 'Family history of allergy?', (v) => _allergyFamily = v, _allergyFamily),
          _ynStep(isArabic ? 'زيادة الوزن أو بدانة؟' : 'Overweight/obesity?', (v) => _obesity = v, _obesity),
          _ynStep(isArabic ? 'مصاب بالسكري؟' : 'Diabetes?', (v) => _diabetes = v, _diabetes),
          _ynStep(isArabic ? 'ارتفاع ضغط الدم؟' : 'Hypertension?', (v) => _hypertension = v, _hypertension),
          Step(
            title: Text(isArabic ? 'الصداع' : 'Headache'),
            isActive: _step >= 9,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _headacheType.isEmpty ? null : _headacheType,
                  items: [
                    'Migraine','Tension','Cluster','Sinus','Eye strain','Other'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(isArabic ? _trHeadacheAr(e) : e))).toList(),
                  onChanged: (v) => setState(() => _headacheType = v ?? ''),
                  decoration: InputDecoration(labelText: isArabic ? 'نوع الصداع' : 'Type'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _headacheSeverity.isEmpty ? null : _headacheSeverity,
                  items: ['Mild','Moderate','Severe'].map((e) => DropdownMenuItem(value: e, child: Text(isArabic ? _trSeverityAr(e) : e))).toList(),
                  onChanged: (v) => setState(() => _headacheSeverity = v ?? ''),
                  decoration: InputDecoration(labelText: isArabic ? 'الشدة' : 'Severity'),
                ),
              ],
            ),
          ),
          Step(
            title: Text(isArabic ? 'أعراض أخرى' : 'Other symptoms'),
            isActive: _step >= 10,
            content: TextField(
              controller: _otherSymptoms,
              maxLines: 3,
              decoration: InputDecoration(hintText: isArabic ? 'اكتب أي أعراض للعين...' : 'Describe eye symptoms...'),
            ),
          ),
          Step(
            title: Text(isArabic ? 'البلد' : 'Country'),
            isActive: _step >= 11,
            content: TextField(
              controller: _country,
              decoration: InputDecoration(hintText: isArabic ? 'الدولة التي تعيش فيها' : 'Your country'),
            ),
          ),
          Step(
            title: Text(isArabic ? 'التحليل' : 'Analysis'),
            isActive: _step >= 12,
            content: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_structured != null
                    ? _buildStructuredResult(isArabic)
                    : (_result == null
                        ? Text(isArabic ? 'اضغط "التالي" لبدء التحليل' : 'Press Next to analyze')
                        : SingleChildScrollView(child: Text(_result!)))),
          ),
        ],
      ),
    );
  }

  Step _ynStep(String title, Function(String) onChanged, String current) {
    final isArabic = Localizations.localeOf(context).languageCode.startsWith('ar');
    return Step(
      title: Text(title),
      isActive: true,
      content: Column(
        children: [
          _choice(isArabic ? 'نعم' : 'Yes', 'yes', current, (v) => setState(() => onChanged(v))),
          _choice(isArabic ? 'لا' : 'No', 'no', current, (v) => setState(() => onChanged(v))),
          _choice(isArabic ? 'لا أعلم' : "I don't know", 'unknown', current, (v) => setState(() => onChanged(v))),
        ],
      ),
    );
  }

  Widget _choice(String label, String value, String group, Function(String) onChanged) {
    return RadioListTile<String>(
      value: value,
      groupValue: group,
      onChanged: (v) => onChanged(v!),
      title: Text(label),
    );
  }

  Widget _numField(String label, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  void _onNext() async {
    if (_step < 12) {
      setState(() => _step += 1);
      return;
    }

    // Analyze via AI
    setState(() { _loading = true; _result = null; _structured = null; });

    final isArabic = Localizations.localeOf(context).languageCode.startsWith('ar');
    final prompt = isArabic ? _buildPromptAr() : _buildPromptEn();

    // Attempt structured agent first
    final answers = {
      'for_whom': _forWhom,
      'gender': _gender,
      'age': {'years': _ageYears, 'months': _ageMonths, 'days': _ageDays},
      'recent_injury': _recentInjury,
      'smoking_10y': _smoking10Years,
      'family_allergy': _allergyFamily,
      'obesity': _obesity,
      'diabetes': _diabetes,
      'hypertension': _hypertension,
      'headache': {'type': _headacheType, 'severity': _headacheSeverity},
      'other_symptoms': _otherSymptoms.text,
      'country': _country.text,
      'locale': isArabic ? 'ar' : 'en',
    };

    final structured = await AIChatService.analyzeQuestionnaireStructured(answers: answers);
    if (!structured.containsKey('error') && structured['conditions'] is List) {
      setState(() { _loading = false; _structured = structured; });
      return;
    }

    // Fallback to plain text
    final text = await AIChatService.analyzeQuestionnaire(prompt);
    setState(() { _loading = false; _result = text; });
  }

  void _onBack() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  String _buildPromptEn() {
    return '''You are an ophthalmology assistant. Read the following questionnaire answers and provide a concise probable-diagnosis list (bulleted with probabilities) and brief next steps. Keep it focused on eye conditions only.

For whom: ${_forWhom}
Gender: ${_gender}
Age: ${_ageYears}y ${_ageMonths}m ${_ageDays}d
Recent injury: ${_recentInjury}
Smoking >=10y: ${_smoking10Years}
Family allergy: ${_allergyFamily}
Overweight/obesity: ${_obesity}
Diabetes: ${_diabetes}
Hypertension: ${_hypertension}
Headache type: ${_headacheType}; severity: ${_headacheSeverity}
Other eye symptoms: ${_otherSymptoms.text}
Country: ${_country.text}

End with: "It is very important to visit an ophthalmologist for accurate diagnosis."''';
  }

  String _buildPromptAr() {
    return '''أنت مساعد مختص بطب العيون. اقرأ إجابات الاستبيان التالية وقدّم قائمة مختصرة بالأمراض المحتملة (بنقاط مع نسب تقديرية) وخطوات تالية موجزة، وركّز على أمراض العين فقط.

لمن الفحص: ${_forWhom == 'self' ? 'لنفسي' : 'شخص آخر'}
النوع: ${_gender == 'male' ? 'ذكر' : 'أنثى'}
العمر: ${_ageYears} سنة ${_ageMonths} شهر ${_ageDays} يوم
إصابة حديثاً: ${_translateYN(_recentInjury)}
تدخين 10 سنوات أو أكثر: ${_translateYN(_smoking10Years)}
تاريخ عائلي للحساسية: ${_translateYN(_allergyFamily)}
زيادة وزن/بدانة: ${_translateYN(_obesity)}
السكري: ${_translateYN(_diabetes)}
ارتفاع ضغط الدم: ${_translateYN(_hypertension)}
نوع الصداع: ${_trHeadacheAr(_headacheType)}؛ الشدة: ${_trSeverityAr(_headacheSeverity)}
أعراض أخرى للعين: ${_otherSymptoms.text}
البلد: ${_country.text}

اختم بـ: "⚠️ من المهم جدًا زيارة طبيب عيون للتشخيص الدقيق."''';
  }

  String _translateYN(String v) {
    switch (v) {
      case 'yes': return 'نعم';
      case 'no': return 'لا';
      default: return 'لا أعلم';
    }
  }

  String _trHeadacheAr(String v) {
    switch (v) {
      case 'Migraine': return 'شقيقة';
      case 'Tension': return 'توترية';
      case 'Cluster': return 'عنقودية';
      case 'Sinus': return 'جيوبية';
      case 'Eye strain': return 'إجهاد بصري';
      case 'Other': return 'أخرى';
      default: return '';
    }
  }

  String _trSeverityAr(String v) {
    switch (v) {
      case 'Mild': return 'خفيف';
      case 'Moderate': return 'متوسط';
      case 'Severe': return 'شديد';
      default: return '';
    }
  }

  Widget _buildStructuredResult(bool isArabic) {
    final conditions = (_structured?['conditions'] as List?) ?? [];
    final recommendations = (_structured?['recommendations'] as List?) ?? [];
    final redFlags = (_structured?['red_flags'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isArabic ? 'الأمراض المحتملة' : 'Probable conditions', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...conditions.map((c) {
          final name = c['name']?.toString() ?? '';
          final prob = (c['probability'] is num) ? (c['probability'] as num).toDouble() : 0.0;
          final rationale = c['rationale']?.toString() ?? '';
          final pct = (prob * 100).clamp(0, 100).toStringAsFixed(1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('- $name • $pct%${rationale.isNotEmpty ? ' — $rationale' : ''}'),
          );
        }),
        const SizedBox(height: 12),
        if (recommendations.isNotEmpty) ...[
          Text(isArabic ? 'توصيات' : 'Recommendations', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...recommendations.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('- ${r.toString()}'),
              )),
        ],
        const SizedBox(height: 12),
        if (redFlags.isNotEmpty) ...[
          Text(isArabic ? 'علامات خطر' : 'Red flags', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...redFlags.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('- ${r.toString()}'),
              )),
        ],
        const SizedBox(height: 12),
        Text(isArabic
            ? '⚠️ من المهم جدًا زيارة طبيب عيون للتشخيص الدقيق.'
            : '⚠️ It is very important to visit an ophthalmologist for accurate diagnosis.'),
      ],
    );
  }
}


