import 'package:flutter/material.dart';

import 'src/features/weather/presentation/weather_home_page.dart';

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
				appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
			),
			home: const WeatherHomePage(),
		);
	}
}


