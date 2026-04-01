# Clima Agora (Flutter) — MVP

Aplicativo meteorológico simples em Flutter que busca cidades (Open‑Meteo Geocoding) e exibe a temperatura atual (Open‑Meteo Forecast), com imagem de fundo condizente com o clima.

## Funcionalidades

- Busca de cidades com sugestões (autocomplete)
- Seleção de cidade e exibição de temperatura atual
- Background dinâmico por condição do tempo (sol, nublado, chuva, neve)
- UI leve (foco em boa performance)

## Interview

### GIFs do app

![Clima Agora - GIF 1](lib/assets/ClimaAgora.gif)

![Clima Agora - GIF 2](lib/assets/ClimaAgora2.gif)

### Prints do app

![Clima Agora - Print 1](lib/assets/ClimaAgora.png)

![Clima Agora - Print 2](lib/assets/ClimaAgora2.png)

![Clima Agora - Print 3](lib/assets/ClimaAgora3.png)

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

## Atualização do README

Nesta atualização, a documentação foi ajustada para refletir as mudanças de **interface e experiência de uso** do app.

### O que mudou na interface

- Tela principal com visual imersivo usando imagem de fundo em tela cheia
- Sobreposição com gradiente para melhorar legibilidade dos componentes
- Barra superior transparente com navegação por abas: **Hoje** e **Previsão**
- Campo de busca em estilo card com efeito translúcido (glass)
- Lista de sugestões de cidades em card dedicado, com seleção por toque
- Feedback visual durante busca de cidades com `LinearProgressIndicator`
- Tratamento visual de erro para falha de busca/carregamento
- Background dinâmico atualizado conforme condição climática da cidade selecionada

### Comportamentos de UX implementados

- Busca com debounce (250 ms) para reduzir chamadas excessivas de API
- Limpeza rápida da busca pelo ícone de fechar (`X`)
- Fechamento do teclado ao selecionar cidade
- Atualização de estado com carregamento e erro sem travar a UI

### Arquivos principais da interface

- `lib/main.dart`
- `lib/src/features/weather/presentation/weather_home_page.dart`
- `lib/src/features/weather/presentation/weather_ui_mapper.dart`

## Próximos passos (ideias)

- Persistir última cidade selecionada
- Exibir também sensação térmica, vento e umidade
- Adicionar testes unitários para mapeamento de `weather_code`

---

Feito como MVP para estudo de arquitetura moderna em Flutter.
