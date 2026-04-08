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

## Deploy no Render

Este backend está preparado para deploy via `render.yaml` na raiz do repositório.

1. No Render, crie via **Blueprint** apontando para este repositório.
2. No serviço `clima-agora-api`, configure:
  - `GEMINI_API_KEY` (obrigatória)
3. Após deploy, valide:
  - `GET /health`
  - `POST /travel/suggestions`

Exemplo de URL final:

```text
https://clima-agora-api.onrender.com
```

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
