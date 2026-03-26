# Clima Agora (Flutter) — MVP

Aplicativo meteorológico simples em Flutter que busca cidades (Open‑Meteo Geocoding) e exibe a temperatura atual (Open‑Meteo Forecast), com imagem de fundo condizente com o clima.

## Funcionalidades

- Busca de cidades com sugestões (autocomplete)
- Seleção de cidade e exibição de temperatura atual
- Background dinâmico por condição do tempo (sol, nublado, chuva, neve)
- UI leve (foco em boa performance)

## Stack

- Flutter (Material 3)
- HTTP: pacote `http`
- API: Open‑Meteo (sem chave)

## Requisitos

- Flutter SDK instalado
- Conexão com a internet (para consumir as APIs)

## Como rodar

Na raiz do projeto (onde está o `pubspec.yaml`):

1) Instalar dependências

```bash
flutter pub get
```

2) Rodar o app

```bash
flutter run
```

## Assets (imagens de fundo)

As imagens estão em `lib/assets/` e são registradas no `pubspec.yaml`.

Arquivos esperados:

- `lib/assets/bg_sunny.jpg`
- `lib/assets/bg_cloudy.jpg`
- `lib/assets/bg_rain.jpg`
- `lib/assets/bg_snow.jpg`

## Estrutura de pastas (Feature‑First)

O projeto segue um estilo **Feature‑Based** com camadas internas (data/domain/presentation):

```
lib/
	main.dart
	src/
		features/
			weather/
				data/
					open_meteo_forecast_api.dart
					open_meteo_geocoding_api.dart
					weather_repository.dart
				domain/
					city.dart
					current_weather.dart
				presentation/
					weather_ui_mapper.dart
```

## Como funciona (alto nível)

- A busca de cidades usa: `geocoding-api.open-meteo.com/v1/search`
- A leitura do clima atual usa: `api.open-meteo.com/v1/forecast` com `current=temperature_2m,weather_code,is_day`
- O mapeamento do `weather_code` para o tipo de clima e imagem de fundo fica em `weather_ui_mapper.dart`

## Qualidade / Boas práticas

- Separação por camadas para facilitar manutenção e testes
- Debounce na busca para evitar excesso de requisições
- Repositório como ponto único de acesso aos dados

## Próximos passos (ideias)

- Persistir última cidade selecionada
- Exibir também sensação térmica, vento e umidade
- Adicionar testes unitários para mapeamento de `weather_code`

---

Feito como MVP para estudo de arquitetura moderna em Flutter.
