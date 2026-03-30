# 🌦️ Clima Agora (Flutter)



<div align="center">

<img src="https://media.giphy.com/media/l0HlPwMAzh13pcZ20/giphy.gif" width="300"/>


### 📱 Aplicativo meteorológico leve, rápido e moderno

<img src="https://skillicons.dev/icons?i=flutter,dart" />

</div>

---

## 🚀 Sobre o projeto

O **Clima Agora** é um aplicativo desenvolvido em Flutter com foco em **simplicidade, performance e boa arquitetura**.

A aplicação permite buscar cidades em tempo real e visualizar a temperatura atual, com uma interface dinâmica que se adapta às condições climáticas.

> 💡 Projeto criado como MVP para estudo de arquitetura moderna em Flutter.

---

## ✨ Funcionalidades

🔍 Busca de cidades com autocomplete
🌡️ Exibição da temperatura atual
🌆 Background dinâmico baseado no clima
⚡ Interface leve e rápida

---

## 🛠️ Tecnologias utilizadas

<div align="center">

<img src="https://skillicons.dev/icons?i=flutter,dart" />

</div>

### 💡 Stack

* **Flutter (Material 3)** → Desenvolvimento da interface
* **Dart** → Linguagem principal
* **HTTP (`http`)** → Consumo de APIs externas
* **Open-Meteo API** → Dados climáticos em tempo real (sem necessidade de chave)

---

## 🧠 Arquitetura

O projeto segue uma abordagem **Feature-Based + Clean Architecture**, com separação clara de responsabilidades:

```
lib/
 ┣ main.dart
 ┗ src/
    ┗ features/
       ┗ weather/
          ┣ data/
          ┣ domain/
          ┗ presentation/
```

### 📌 Camadas

* **data** → Consumo de APIs e repositórios
* **domain** → Modelos e regras de negócio
* **presentation** → Interface e lógica de exibição

---

## 🌐 APIs utilizadas

* 🔎 Geocoding → Busca de cidades
* 🌡️ Forecast → Dados climáticos atuais

---

## 🎨 Assets

As imagens de fundo são alteradas dinamicamente conforme o clima:

* ☀️ Ensolarado → `bg_sunny.jpg`
* ☁️ Nublado → `bg_cloudy.jpg`
* 🌧️ Chuva → `bg_rain.jpg`
* ❄️ Neve → `bg_snow.jpg`

---

## ⚙️ Como executar

```bash
# Instalar dependências
flutter pub get

# Rodar o projeto
flutter run
```

---

## 🧩 Como funciona

* Busca de cidades via **Open-Meteo Geocoding API**
* Clima atual via **Open-Meteo Forecast API**
* Conversão de `weather_code` para UI feita em:

  ```
  weather_ui_mapper.dart
  ```

---

## 📈 Boas práticas aplicadas

✔️ Separação por camadas
✔️ Debounce na busca (melhora performance)
✔️ Repositório centralizado
✔️ Código organizado e escalável

---

## 🚧 Próximos passos

🔐 Persistir última cidade
🌬️ Adicionar vento, umidade e sensação térmica
🧪 Implementar testes unitários
📱 Melhorias na UI/UX

---

## 👨‍💻 Autor

**Leonardo Souza Bezerra**

🚀 Desenvolvedor focado em backend e arquitetura
📚 Sempre evoluindo com projetos práticos

---

<div align="center">

⭐ Se curtiu o projeto, deixa uma estrela!

</div>
