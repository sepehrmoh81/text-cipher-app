import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cipher_engine.dart';

void main() {
  runApp(const PersianCipherApp());
}

class PersianCipherApp extends StatefulWidget {
  const PersianCipherApp({super.key});

  @override
  State<PersianCipherApp> createState() => _PersianCipherAppState();
}

class _PersianCipherAppState extends State<PersianCipherApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    if(platformBrightness == Brightness.light) _themeMode = ThemeMode.light;

    return MaterialApp(
      title: 'Text Cipher',
      theme: ThemeData(
        fontFamily: 'GoogleSans',
        fontFamilyFallback: ['VazirmatnUI'],
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'GoogleSans',
            fontFamilyFallback: ['VazirmatnUI'],
          ),
          bodyMedium: TextStyle(
            fontFamily: 'GoogleSans',
            fontFamilyFallback: ['VazirmatnUI'],
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: 'GoogleSans',
        fontFamilyFallback: ['VazirmatnUI'],
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'GoogleSans',
            fontFamilyFallback: ['VazirmatnUI'],
          ),
          bodyMedium: TextStyle(
            fontFamily: 'GoogleSans',
            fontFamilyFallback: ['VazirmatnUI'],
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: CipherHomePage(onThemeToggle: _toggleTheme, themeMode: _themeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CipherHomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const CipherHomePage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<CipherHomePage> createState() => _CipherHomePageState();
}

class _CipherHomePageState extends State<CipherHomePage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  bool _isEnglishToPersian = true;
  bool _isRealtimeMode = true;
  bool _showControlButtons = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_isRealtimeMode) {
      _processText();
    }
    setState(() {
      _showControlButtons = _inputController.text.isNotEmpty;
    });
  }

  void _processText() {
    final input = _inputController.text;
    final output = _isEnglishToPersian
        ? CipherEngine.encodeToPersian(input)
        : CipherEngine.decodeFromPersian(input);
    _outputController.text = output;
  }

  void _swapDirection() {
    setState(() {
      _isEnglishToPersian = !_isEnglishToPersian;
      final temp = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = temp;
    });
  }

  void _clearAll() {
    _inputController.clear();
    _outputController.clear();
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persian Text Cipher'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 550 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mode Controls Card
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.flash_on, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Real-time Mode'),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: _isRealtimeMode,
                                      onChanged: (value) {
                                        setState(() {
                                          _isRealtimeMode = value;
                                          if (value) _processText();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Text Field
                        TextField(
                          controller: _inputController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: _isEnglishToPersian ? 'English Text' : 'Persian Text',
                            hintText: _isEnglishToPersian
                                ? 'Enter English text to encode...'
                                : 'Enter Persian text to decode...',
                            border: const OutlineInputBorder(),
                            suffixIcon: _showControlButtons
                                ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _inputController.clear(),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filledTonal(
                              icon: const Icon(Icons.swap_vert),
                              onPressed: _swapDirection,
                              tooltip: 'Swap direction',
                            ),
                            const SizedBox(width: 12),
                            if (!_isRealtimeMode)
                              FilledButton.icon(
                                onPressed: _processText,
                                icon: const Icon(Icons.transform),
                                label: Text(_isEnglishToPersian ? 'Encode' : 'Decode'),
                              ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _clearAll,
                              tooltip: 'Clear all',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Direction Indicator
                        Center(
                          child: Chip(
                            avatar: const Icon(Icons.arrow_forward, size: 18),
                            label: Text(
                              _isEnglishToPersian ? 'English → Persian' : 'Persian → English',
                              strutStyle: const StrutStyle(
                                forceStrutHeight: true,
                                height: 1.5,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Output Text Field
                        TextField(
                          controller: _outputController,
                          maxLines: 6,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: _isEnglishToPersian ? 'Persian Output' : 'English Output',
                            border: const OutlineInputBorder(),
                            suffixIcon: _showControlButtons
                                ? IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyOutput,
                              tooltip: 'Copy to clipboard',
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Credits
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Made with ❤️ and ☕, by ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final uri = Uri.parse('https://github.com/sepehrmoh81');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  'S',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                ' and ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final uri = Uri.parse('https://github.com/sepehrmoh81');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  'P',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}