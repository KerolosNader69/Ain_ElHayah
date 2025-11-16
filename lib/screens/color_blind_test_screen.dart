import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class ColorBlindTestScreen extends StatefulWidget {
  const ColorBlindTestScreen({super.key});

  @override
  State<ColorBlindTestScreen> createState() => _ColorBlindTestScreenState();
}

class _ColorBlindTestScreenState extends State<ColorBlindTestScreen> {
  int _currentTestIndex = 0;
  int _correctAnswers = 0;
  bool _testCompleted = false;
  List<String> _userAnswers = [];
  List<ColorBlindTest> _currentTests = [];
  List<List<String>> _shuffledOptions = []; // Store shuffled options for each question
  final int _totalTestsPerSession = 12; // زيادة عدد الأسئلة
  
  // مجموعة شاملة من الاختبارات المختلفة
  final List<ColorBlindTest> _allTests = [
    // اختبارات الأحمر-الأخضر (الأكثر شيوعاً)
    ColorBlindTest(
      number: '12',
      correctAnswer: '12',
      options: ['12', '21', '17', 'لا أرى رقماً'],
      colors: [Color(0xFFE74C3C), Color(0xFF27AE60)],
      type: ColorBlindType.redGreen,
      description: 'اختبار الأحمر-الأخضر الأساسي',
      difficulty: 1,
    ),
    ColorBlindTest(
      number: '8',
      correctAnswer: '8',
      options: ['8', '3', '6', 'لا أرى رقماً'],
      colors: [Color(0xFFE74C3C), Color(0xFF2ECC71)],
      type: ColorBlindType.redGreen,
      description: 'تمييز الأحمر والأخضر',
      difficulty: 2,
    ),
    ColorBlindTest(
      number: '74',
      correctAnswer: '74',
      options: ['74', '21', '71', 'لا أرى رقماً'],
      colors: [Color(0xFFDC143C), Color(0xFF228B22)],
      type: ColorBlindType.redGreen,
      description: 'اختبار متقدم للأحمر-الأخضر',
      difficulty: 3,
    ),
    ColorBlindTest(
      number: '42',
      correctAnswer: '42',
      options: ['42', '24', '49', 'لا أرى رقماً'],
      colors: [Color(0xFFCD5C5C), Color(0xFF32CD32)],
      type: ColorBlindType.redGreen,
      description: 'تدرجات الأحمر والأخضر',
      difficulty: 2,
    ),
    ColorBlindTest(
      number: '5',
      correctAnswer: '5',
      options: ['5', '2', '6', 'لا أرى رقماً'],
      colors: [Color(0xFFB22222), Color(0xFF006400)],
      type: ColorBlindType.redGreen,
      description: 'الأحمر الداكن والأخضر الداكن',
      difficulty: 4,
    ),
    ColorBlindTest(
      number: '29',
      correctAnswer: '29',
      options: ['29', '92', '39', 'لا أرى رقماً'],
      colors: [Color(0xFFFF6347), Color(0xFF3CB371)],
      type: ColorBlindType.redGreen,
      description: 'درجات فاتحة من الأحمر والأخضر',
      difficulty: 3,
    ),
    ColorBlindTest(
      number: '16',
      correctAnswer: '16',
      options: ['16', '61', '18', 'لا أرى رقماً'],
      colors: [Color(0xFFFF4500), Color(0xFF7CFC00)],
      type: ColorBlindType.redGreen,
      description: 'البرتقالي والأخضر الفاتح',
      difficulty: 2,
    ),
    
    // اختبارات الأزرق-الأصفر (أقل شيوعاً)
    ColorBlindTest(
      number: '35',
      correctAnswer: '35',
      options: ['35', '53', '38', 'لا أرى رقماً'],
      colors: [Color(0xFF4169E1), Color(0xFFFFD700)],
      type: ColorBlindType.blueYellow,
      description: 'اختبار الأزرق-الأصفر الأساسي',
      difficulty: 2,
    ),
    ColorBlindTest(
      number: '96',
      correctAnswer: '96',
      options: ['96', '69', '86', 'لا أرى رقماً'],
      colors: [Color(0xFF0000FF), Color(0xFFFFFF00)],
      type: ColorBlindType.blueYellow,
      description: 'الأزرق الصافي والأصفر الصافي',
      difficulty: 1,
    ),
    ColorBlindTest(
      number: '45',
      correctAnswer: '45',
      options: ['45', '54', '48', 'لا أرى رقماً'],
      colors: [Color(0xFF191970), Color(0xFFFFA500)],
      type: ColorBlindType.blueYellow,
      description: 'الأزرق الداكن والبرتقالي',
      difficulty: 3,
    ),
    ColorBlindTest(
      number: '73',
      correctAnswer: '73',
      options: ['73', '37', '78', 'لا أرى رقماً'],
      colors: [Color(0xFF6495ED), Color(0xFFFFE4B5)],
      type: ColorBlindType.blueYellow,
      description: 'درجات فاتحة من الأزرق والأصفر',
      difficulty: 4,
    ),
    
    // اختبارات متقدمة ومختلطة
    ColorBlindTest(
      number: '57',
      correctAnswer: '57',
      options: ['57', '75', '51', 'لا أرى رقماً'],
      colors: [Color(0xFF8B008B), Color(0xFF00CED1)],
      type: ColorBlindType.advanced,
      description: 'البنفسجي والتركوازي',
      difficulty: 3,
    ),
    ColorBlindTest(
      number: '83',
      correctAnswer: '83',
      options: ['83', '38', '88', 'لا أرى رقماً'],
      colors: [Color(0xFFFF69B4), Color(0xFF98FB98)],
      type: ColorBlindType.redGreen,
      description: 'الوردي والأخضر الفاتح',
      difficulty: 4,
    ),
    ColorBlindTest(
      number: '26',
      correctAnswer: '26',
      options: ['26', '62', '28', 'لا أرى رقماً'],
      colors: [Color(0xFF800080), Color(0xFF90EE90)],
      type: ColorBlindType.advanced,
      description: 'البنفسجي والأخضر الفاتح',
      difficulty: 5,
    ),
    ColorBlindTest(
      number: '15',
      correctAnswer: '15',
      options: ['15', '51', '18', 'لا أرى رقماً'],
      colors: [Color(0xFFDDA0DD), Color(0xFF98FB98)],
      type: ColorBlindType.advanced,
      description: 'درجات الباستيل المتقاربة',
      difficulty: 5,
    ),
    ColorBlindTest(
      number: '64',
      correctAnswer: '64',
      options: ['64', '46', '84', 'لا أرى رقماً'],
      colors: [Color(0xFFDC143C), Color(0xFF8FBC8F)],
      type: ColorBlindType.redGreen,
      description: 'الأحمر القرمزي والأخضر الرمادي',
      difficulty: 4,
    ),
    
    // اختبارات إضافية للتنويع
    ColorBlindTest(
      number: '91',
      correctAnswer: '91',
      options: ['91', '19', '81', 'لا أرى رقماً'],
      colors: [Color(0xFFFF1493), Color(0xFF00FF7F)],
      type: ColorBlindType.redGreen,
      description: 'الوردي الداكن والأخضر الربيعي',
      difficulty: 3,
    ),
    ColorBlindTest(
      number: '37',
      correctAnswer: '37',
      options: ['37', '73', '31', 'لا أرى رقماً'],
      colors: [Color(0xFF8B0000), Color(0xFF228B22)],
      type: ColorBlindType.redGreen,
      description: 'الأحمر الداكن جداً والأخضر الغابات',
      difficulty: 5,
    ),
    ColorBlindTest(
      number: '68',
      correctAnswer: '68',
      options: ['68', '86', '63', 'لا أرى رقماً'],
      colors: [Color(0xFF4682B4), Color(0xFFF0E68C)],
      type: ColorBlindType.blueYellow,
      description: 'الأزرق الفولاذي والخاكي',
      difficulty: 4,
    ),
    ColorBlindTest(
      number: '14',
      correctAnswer: '14',
      options: ['14', '41', '19', 'لا أرى رقماً'],
      colors: [Color(0xFF20B2AA), Color(0xFFFFB6C1)],
      type: ColorBlindType.advanced,
      description: 'الأزرق المخضر والوردي الفاتح',
      difficulty: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _generateRandomTests();
  }

  void _generateRandomTests() {
    // Use current time as seed to ensure different randomization each time
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    _currentTests.clear();
    _shuffledOptions.clear();
    
    // اختيار اختبارات عشوائية متنوعة
    final availableTests = List<ColorBlindTest>.from(_allTests);
    availableTests.shuffle(random);
    
    // ضمان تنوع صعوبة الأسئلة
    final easyTests = availableTests.where((t) => t.difficulty <= 2).toList();
    final mediumTests = availableTests.where((t) => t.difficulty == 3 || t.difficulty == 4).toList();
    final hardTests = availableTests.where((t) => t.difficulty >= 4).toList();
    
    // توزيع متوازن: 4 سهل، 5 متوسط، 3 صعب
    _currentTests.addAll(easyTests.take(4));
    _currentTests.addAll(mediumTests.take(5));
    _currentTests.addAll(hardTests.take(3));
    
    // خلط الترتيب النهائي
    _currentTests.shuffle(random);
    
    // التأكد من وجود 12 اختبار بالضبط
    if (_currentTests.length > _totalTestsPerSession) {
      _currentTests = _currentTests.take(_totalTestsPerSession).toList();
    }
    
    // خلط خيارات الإجابة لكل سؤال
    for (final test in _currentTests) {
      final shuffledOptions = List<String>.from(test.options);
      shuffledOptions.shuffle(random);
      _shuffledOptions.add(shuffledOptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            collapsedHeight: 72,
            expandedHeight: 72,
            flexibleSpace: const SizedBox.expand(child: AppHeader()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (!_testCompleted) ...[
                    _buildTestHeader(context, l10n),
                    const SizedBox(height: 32),
                    _buildProgressBar(context),
                    const SizedBox(height: 32),
                    _buildCurrentTest(context, l10n),
                  ] else ...[
                    _buildResults(context, l10n),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final currentTest = _currentTests[_currentTestIndex];
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'اختبار عمى الألوان المتقدم',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'فحص شامل للقدرة على تمييز الألوان',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'اختبار مُحسّن بأسئلة متغيرة ومستويات صعوبة مختلفة',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.getTextColor(context, isDescription: true),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.getSurfaceDecoration(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'السؤال ${_currentTestIndex + 1} من $_totalTestsPerSession',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(currentTest.difficulty).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDifficultyColor(currentTest.difficulty),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getDifficultyText(currentTest.difficulty),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getDifficultyColor(currentTest.difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentTest.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextColor(context, isDescription: true),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = (_currentTestIndex / _totalTestsPerSession);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.getSurfaceDecoration(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.getBorderColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTest(BuildContext context, AppLocalizations l10n) {
    final currentTest = _currentTests[_currentTestIndex];
    final theme = Theme.of(context);

    return Container(
      decoration: AppTheme.getSurfaceDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // عرض دائرة الألوان (محاكاة اختبار إيشيهارا المحسّن)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: AdvancedColorBlindTestPainter(
                  number: currentTest.number,
                  colors: currentTest.colors,
                  difficulty: currentTest.difficulty,
                  seed: _currentTestIndex + DateTime.now().millisecond,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'ما الرقم الذي تراه في الدائرة؟',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // خيارات الإجابة محسّنة
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: _shuffledOptions[_currentTestIndex].length,
              itemBuilder: (context, index) {
                final option = _shuffledOptions[_currentTestIndex][index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _selectAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getMutedBackgroundColor(context),
                      foregroundColor: AppTheme.getTextColor(context),
                      side: BorderSide(
                        color: AppTheme.getBorderColor(context),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // نصائح للمساعدة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'انظر للدائرة من مسافة مناسبة وحاول التركيز على وسط الدائرة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
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

  Widget _buildResults(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final percentage = (_correctAnswers / _totalTestsPerSession * 100).round();
    
    String resultMessage;
    Color resultColor;
    IconData resultIcon;
    String resultDetails;
    
    if (percentage >= 90) {
      resultMessage = 'ممتاز! رؤية الألوان طبيعية تماماً';
      resultColor = Colors.green;
      resultIcon = Icons.check_circle;
      resultDetails = 'لديك قدرة ممتازة على تمييز الألوان المختلفة. رؤيتك للألوان طبيعية بشكل كامل.';
    } else if (percentage >= 75) {
      resultMessage = 'جيد جداً! رؤية الألوان شبه طبيعية';
      resultColor = Colors.lightGreen;
      resultIcon = Icons.check_circle_outline;
      resultDetails = 'لديك قدرة جيدة جداً على تمييز الألوان مع احتمال وجود صعوبة بسيطة في بعض الدرجات المتقاربة.';
    } else if (percentage >= 60) {
      resultMessage = 'جيد، قد يكون هناك ضعف بسيط في تمييز بعض الألوان';
      resultColor = Colors.orange;
      resultIcon = Icons.warning;
      resultDetails = 'تظهر النتائج احتمال وجود صعوبة خفيفة في تمييز بعض الألوان، خاصة في الدرجات المتقاربة.';
    } else if (percentage >= 40) {
      resultMessage = 'قد تعاني من ضعف متوسط في تمييز الألوان';
      resultColor = Colors.deepOrange;
      resultIcon = Icons.error_outline;
      resultDetails = 'النتائج تشير إلى وجود صعوبة متوسطة في تمييز بعض الألوان. ننصح بزيارة طبيب العيون.';
    } else {
      resultMessage = 'قد تعاني من عمى الألوان، ننصح بزيارة طبيب العيون';
      resultColor = Colors.red;
      resultIcon = Icons.error;
      resultDetails = 'النتائج تشير إلى احتمال وجود عمى ألوان. من المهم جداً استشارة طبيب عيون مختص للتشخيص الدقيق.';
    }

    return Container(
      decoration: AppTheme.getSurfaceDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              resultIcon,
              size: 80,
              color: resultColor,
            ),
            const SizedBox(height: 24),
            
            Text(
              'نتائج اختبار عمى الألوان المتقدم',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // نتيجة مفصلة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    resultColor.withOpacity(0.1),
                    resultColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: resultColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_correctAnswers من $_totalTestsPerSession إجابات صحيحة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    resultMessage,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // تفاصيل النتيجة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getMutedBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Text(
                resultDetails,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // إحصائيات مفصلة
            _buildDetailedStats(context),
            
            const SizedBox(height: 24),
            
            // تنبيه طبي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ تنبيه طبي مهم',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هذا الاختبار المحسّن للإرشاد فقط وليس تشخيصاً طبياً نهائياً. للحصول على تشخيص دقيق وشامل، يرجى استشارة طبيب عيون مختص الذي سيستخدم اختبارات أكثر تفصيلاً ودقة.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getTextColor(context, isDescription: true),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _restartTest,
                    icon: const Icon(Icons.refresh),
                    label: const Text('اختبار جديد'),
                    style: AppTheme.getSecondaryButtonStyle(context).copyWith(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home),
                    label: const Text('العودة للرئيسية'),
                    style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    final theme = Theme.of(context);
    
    // حساب إحصائيات مفصلة
    int redGreenCorrect = 0;
    int blueYellowCorrect = 0;
    int advancedCorrect = 0;
    int redGreenTotal = 0;
    int blueYellowTotal = 0;
    int advancedTotal = 0;
    
    for (int i = 0; i < _currentTests.length; i++) {
      final test = _currentTests[i];
      final isCorrect = i < _userAnswers.length && _userAnswers[i] == test.correctAnswer;
      
      switch (test.type) {
        case ColorBlindType.redGreen:
          redGreenTotal++;
          if (isCorrect) redGreenCorrect++;
          break;
        case ColorBlindType.blueYellow:
          blueYellowTotal++;
          if (isCorrect) blueYellowCorrect++;
          break;
        case ColorBlindType.advanced:
          advancedTotal++;
          if (isCorrect) advancedCorrect++;
          break;
        case ColorBlindType.complete:
          break;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getMutedBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفصيل النتائج حسب نوع الاختبار:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (redGreenTotal > 0) ...[
            _buildStatRow(
              '🔴🟢 الأحمر-الأخضر',
              redGreenCorrect,
              redGreenTotal,
              context,
            ),
            const SizedBox(height: 8),
          ],
          if (blueYellowTotal > 0) ...[
            _buildStatRow(
              '🔵🟡 الأزرق-الأصفر',
              blueYellowCorrect,
              blueYellowTotal,
              context,
            ),
            const SizedBox(height: 8),
          ],
          if (advancedTotal > 0) ...[
            _buildStatRow(
              '🎨 الاختبارات المتقدمة',
              advancedCorrect,
              advancedTotal,
              context,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int correct, int total, BuildContext context) {
    final percentage = total > 0 ? (correct / total * 100).round() : 0;
    final color = percentage >= 70 ? Colors.green : (percentage >= 50 ? Colors.orange : Colors.red);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            '$correct/$total ($percentage%)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
      case 2:
        return Colors.green;
      case 3:
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
      case 2:
        return 'سهل';
      case 3:
      case 4:
        return 'متوسط';
      case 5:
        return 'صعب';
      default:
        return 'عادي';
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers.add(answer);
      
      if (answer == _currentTests[_currentTestIndex].correctAnswer) {
        _correctAnswers++;
      }
      
      if (_currentTestIndex < _currentTests.length - 1) {
        _currentTestIndex++;
      } else {
        _testCompleted = true;
      }
    });
  }

  void _restartTest() {
    setState(() {
      _currentTestIndex = 0;
      _correctAnswers = 0;
      _testCompleted = false;
      _userAnswers.clear();
      _shuffledOptions.clear();
      _generateRandomTests(); // إنتاج مجموعة جديدة من الاختبارات مع خيارات مخلوطة
    });
  }
}

enum ColorBlindType {
  redGreen,
  blueYellow,
  complete,
  advanced,
}

class ColorBlindTest {
  final String number;
  final String correctAnswer;
  final List<String> options;
  final List<Color> colors;
  final ColorBlindType type;
  final String description;
  final int difficulty; // 1-5 scale

  ColorBlindTest({
    required this.number,
    required this.correctAnswer,
    required this.options,
    required this.colors,
    required this.type,
    required this.description,
    required this.difficulty,
  });
}

class AdvancedColorBlindTestPainter extends CustomPainter {
  final String number;
  final List<Color> colors;
  final int difficulty;
  final int seed;

  AdvancedColorBlindTestPainter({
    required this.number,
    required this.colors,
    required this.difficulty,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final random = math.Random(seed);

    // زيادة عدد النقاط حسب الصعوبة
    final dotsCount = 300 + (difficulty * 100);
    final minDotSize = difficulty > 3 ? 2.0 : 3.0;
    final maxDotSize = difficulty > 3 ? 6.0 : 8.0;

    // رسم النقاط الخلفية بكثافة أعلى
    for (int i = 0; i < dotsCount; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = random.nextDouble() * (radius - 20);
      final dotRadius = random.nextDouble() * (maxDotSize - minDotSize) + minDotSize;
      
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      // اختيار لون عشوائي من المجموعة مع تنويع أكبر
      Color dotColor;
      if (random.nextDouble() < 0.7) {
        // 70% من النقاط تكون من الألوان الأساسية
        dotColor = colors[random.nextInt(colors.length)];
      } else {
        // 30% من النقاط تكون من درجات متدرجة
        final baseColor = colors[random.nextInt(colors.length)];
        final factor = 0.7 + (random.nextDouble() * 0.6); // 0.7 to 1.3
        dotColor = Color.lerp(baseColor, Colors.grey, 1 - factor) ?? baseColor;
      }
      
      final opacity = difficulty > 3 ? 0.5 + random.nextDouble() * 0.3 : 0.6 + random.nextDouble() * 0.4;
      final paint = Paint()..color = dotColor.withOpacity(opacity);
      
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }

    // رسم الرقم بتباين أقل في المستويات الصعبة
    final numberOpacity = difficulty > 3 ? 0.7 : 0.9;
    final numberColor = colors.length > 1 ? colors[1] : colors[0];
    
    // إضافة تأثير الظل للرقم
    final shadowPainter = TextPainter(
      text: TextSpan(
        text: number,
        style: TextStyle(
          fontSize: 100 + (difficulty * 5),
          fontWeight: FontWeight.w900,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    shadowPainter.layout();
    shadowPainter.paint(
      canvas,
      Offset(
        center.dx - shadowPainter.width / 2 + 2,
        center.dy - shadowPainter.height / 2 + 2,
      ),
    );

    // رسم الرقم الأساسي
    final textPainter = TextPainter(
      text: TextSpan(
        text: number,
        style: TextStyle(
          fontSize: 100 + (difficulty * 5),
          fontWeight: FontWeight.w900,
          color: numberColor.withOpacity(numberOpacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // إضافة نقاط إضافية حول الرقم للمستويات الصعبة
    if (difficulty >= 4) {
      for (int i = 0; i < 50; i++) {
        final angle = random.nextDouble() * 2 * math.pi;
        final distance = 80 + random.nextDouble() * 60;
        final dotRadius = random.nextDouble() * 3 + 2;
        
        final x = center.dx + distance * math.cos(angle);
        final y = center.dy + distance * math.sin(angle);
        
        final paint = Paint()
          ..color = numberColor.withOpacity(0.3 + random.nextDouble() * 0.4);
        
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}