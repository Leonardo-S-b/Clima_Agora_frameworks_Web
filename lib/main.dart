import 'dart:async';

import 'package:flutter/material.dart';

import 'src/features/weather/data/weather_repository.dart';
import 'src/features/weather/domain/city.dart';
import 'src/features/weather/domain/current_weather.dart';
import 'src/features/weather/presentation/weather_ui_mapper.dart';

void main() {
	runApp(const MainApp());
}

class MainApp extends StatelessWidget {
	const MainApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Clima Agora',
			theme: ThemeData(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.blue,
					foregroundColor: Colors.white,
					elevation: 0,
				),
			),
			home: const HomePage(),
		);
	}
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
final _controller = TextEditingController();
Timer? _debounce;

final WeatherRepository _repo = WeatherRepository.create();

List<City> _suggestions = [];
  City? _selectedCity;
  CurrentWeather? _current;

  bool _loadingCities = false;
  bool _loadingWeather = false;
  String? _error;
  

  String _backgroundAsset = 'lib/assets/bg_cloudy.jpg';

@override
void dispose(){
  _debounce?.cancel();
  _controller.dispose();
  super.dispose();
}

void _onQueryChanged(String value){
  final query = value.trim();

  _debounce?.cancel();

  _debounce = Timer(const Duration(milliseconds: 250),() async{

    if (query.isEmpty){
    if (!mounted) return;
    setState((){
      _suggestions = [];
      _error = null;
      _loadingCities = false;
    });
    return;
    }

    if (!mounted) return;
    setState((){
      _loadingCities = true;
      _error = null;  
    });

    try{
      final results = await _repo.searchCities(query);
      if (!mounted) return;
      setState((){
        _suggestions = results;
        
      });
    } catch(e){
      if (!mounted) return;
      setState((){
        _error = "Erro ao buscar cidades";
      });
    } finally {
      if (mounted) {
        setState((){
          _loadingCities = false;
        });
      }
    }
});

  }

Future<void> _selectCity(City city) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedCity = city;
      _suggestions = [];
      _loadingWeather = true;
      _error = null;
    });

    try {
      final current = await _repo.getCurrentWeatherForCity(city);

      final kind = mapWeatherCodeToKind(current.weatherCode);
      final asset = backgroundAssetForKind(kind);

      if (!mounted) return;
      setState(() {
        _current = current;
        _backgroundAsset = asset;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar previsão';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingWeather = false;
        });
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    setState(() {
      _suggestions = [];
      _error = null;
      _loadingCities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Agora'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _backgroundAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
          Container(color: Colors.white.withOpacity(0.20)),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _controller,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar cidade',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (_loadingCities) const LinearProgressIndicator(minHeight: 2),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              if (_suggestions.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: const Color.fromARGB(255, 244, 244, 244).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final city = _suggestions[index];
                          return ListTile(
                            title: Text(city.label),
                            onTap: () => _selectCity(city),
                          );
                        },
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: _loadingWeather
                        ? const CircularProgressIndicator()
                        : Text(
                            _current == null || _selectedCity == null
                                ? 'Digite uma cidade para buscar'
                                : '${_selectedCity!.label}: ${_current!.temperatureC.toStringAsFixed(1)}°C',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


// class HomePage extends StatelessWidget {
// 	const HomePage({super.key});

// 	@override
// 	Widget build(BuildContext context) {
// 		return Scaffold(
// 			appBar: AppBar(
// 				title: const Text('Clima Agora'),
// 			),
// 			body: Column(
//        children: [
//         Padding(
//            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//            child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Digite o nome da cidade',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 suffixIcon: const Icon(Icons.search),
//               ),
//            )
//         )
//        ],
// 			),
// 		);
// 	}





// }


