# AI Backend (Gemini)

Backend simples para centralizar a chave da IA no servidor.

## Requisitos

- Node.js 18+

## Configuração

1. Copie `.env.example` para `.env`.
2. Preencha `GEMINI_API_KEY` com sua chave.

## Rodar local

```bash
npm install
npm run dev
```

Servidor local: `http://localhost:8787`

## Endpoints

- `GET /health`
- `POST /travel/suggestions`

Body esperado:

```json
{
  "prompt": "texto do prompt"
}
```

Resposta:

```json
{
  "text": "sugestao gerada"
}
```
