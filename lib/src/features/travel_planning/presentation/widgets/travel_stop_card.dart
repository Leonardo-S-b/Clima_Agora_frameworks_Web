import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../weather/presentation/weather_ui_mapper.dart';
import '../../domain/travel_stop.dart';
import '../../data/gemini_activity_api.dart';

class TravelStopCard extends StatelessWidget {
  final int index;
  final TravelStop stop;
  final GeminiActivityApi aiApi;

  const TravelStopCard({
    super.key,
    required this.index,
    required this.stop,
    required this.aiApi,
  });

  @override
  Widget build(BuildContext context) {
    final cityWeatherLabel = weatherLabelForCode(stop.weather.weatherCode);
    final routeWeatherLabel = stop.fromPrevious.routeWeather == null
        ? 'Sem leitura do trajeto'
        : weatherLabelForCode(stop.fromPrevious.routeWeather!.weatherCode);

    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stop.city.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Clima da cidade: $cityWeatherLabel · ${stop.weather.temperatureC.toStringAsFixed(0)}°',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No caminho: $routeWeatherLabel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Trecho: ${stop.fromPrevious.distanceKm.toStringAsFixed(1)} km · ${_formatDuration(stop.fromPrevious.duration)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openAiSuggestion(context, cityWeatherLabel),
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Sugestão IA'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAiSuggestion(
    BuildContext context,
    String weatherLabel,
  ) async {
    final daytime = stop.weather.isDay ? 'dia' : 'noite';
    final prompt = aiApi.buildPrompt(
      cityLabel: stop.city.label,
      weatherLabel: weatherLabel,
      daytimeLabel: daytime,
    );

    showDialog<void>(
      context: context,
      barrierColor: const Color(0xCC0B1220),
      builder: (dialogContext) {
        return _AiSuggestionDialog(
          cityName: stop.city.name,
          prompt: prompt,
          aiApi: aiApi,
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '${duration.inMinutes} min';
    }

    return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
  }
}

class _AiSuggestionDialog extends StatefulWidget {
  final String cityName;
  final String prompt;
  final GeminiActivityApi aiApi;

  const _AiSuggestionDialog({
    required this.cityName,
    required this.prompt,
    required this.aiApi,
  });

  @override
  State<_AiSuggestionDialog> createState() => _AiSuggestionDialogState();
}

class _AiSuggestionDialogState extends State<_AiSuggestionDialog> {
  late final Future<String> _suggestionFuture;

  @override
  void initState() {
    super.initState();
    _suggestionFuture = widget.aiApi.suggest(prompt: widget.prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: FutureBuilder<String>(
        future: _suggestionFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState != ConnectionState.done;
          final hasError = snapshot.hasError;
          final rawText = hasError
              ? 'Não foi possível gerar sugestões agora.'
              : (snapshot.data ?? '');
          final items = _parseSuggestionItems(rawText);

          return AnimatedSwitcher(
                duration: 260.ms,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _AiSuggestionSurface(
                  key: ValueKey<String>(isLoading ? 'loading' : rawText),
                  cityName: widget.cityName,
                  isLoading: isLoading,
                  hasError: hasError,
                  items: items,
                  rawText: rawText,
                  onClose: () => Navigator.of(context).pop(),
                ),
              )
              .animate()
              .fadeIn(duration: 220.ms)
              .scale(
                begin: const Offset(0.98, 0.98),
                end: const Offset(1, 1),
                curve: Curves.easeOutCubic,
                duration: 240.ms,
              );
        },
      ),
    );
  }

  List<String> _parseSuggestionItems(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'^[•\-\d\.\)\s]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.length >= 2) {
      return lines;
    }

    final paragraphs = rawText
        .split(RegExp(r'\n{2,}'))
        .map((chunk) => chunk.trim())
        .where((chunk) => chunk.isNotEmpty)
        .toList(growable: false);

    if (paragraphs.isNotEmpty) {
      return paragraphs;
    }

    return rawText.isEmpty ? <String>[] : <String>[rawText.trim()];
  }
}

class _AiSuggestionSurface extends StatelessWidget {
  final String cityName;
  final bool isLoading;
  final bool hasError;
  final List<String> items;
  final String rawText;
  final VoidCallback onClose;

  const _AiSuggestionSurface({
    super.key,
    required this.cityName,
    required this.isLoading,
    required this.hasError,
    required this.items,
    required this.rawText,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF162235), Color(0xFF0F1726)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 28,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'O que fazer em $cityName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isLoading
                                  ? 'Gerando ideias...'
                                  : 'Sugestões com IA',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: 240.ms,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: isLoading
                        ? const _AiLoadingState(key: ValueKey('loading'))
                        : hasError
                        ? _AiErrorState(
                            key: const ValueKey('error'),
                            message: rawText,
                          )
                        : _AiResultState(
                            key: ValueKey('result-${rawText.hashCode}'),
                            items: items,
                            rawText: rawText,
                          ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _AiLoadingState extends StatelessWidget {
  const _AiLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(0.94, 0.94),
              end: const Offset(1, 1),
              duration: 700.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 14),
        Text(
              'Gerando sugestão...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .fade(
              begin: 0.55,
              end: 1,
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

class _AiErrorState extends StatelessWidget {
  final String message;

  const _AiErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 13,
          height: 1.35,
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.05, end: 0);
  }
}

class _AiResultState extends StatelessWidget {
  final List<String> items;
  final String rawText;

  const _AiResultState({super.key, required this.items, required this.rawText});

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.isEmpty ? <String>[rawText] : items;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sugestões rápidas',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...visibleItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == visibleItems.length - 1 ? 0 : 8,
              ),
              child: _AiSuggestionLine(index: index, text: item),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.04, end: 0);
  }
}

class _AiSuggestionLine extends StatelessWidget {
  final int index;
  final String text;

  const _AiSuggestionLine({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: 120 * index);

    return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        )
        .animate(delay: delay)
        .fadeIn(duration: 240.ms)
        .slideX(
          begin: 0.06,
          end: 0,
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
