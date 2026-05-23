# AI Backend (Gemini)

Backend simples para centralizar a chave da IA no servidor.

## Requisitos

- Node.js 18+

## Configuração

1. Copie `.env.example` para `.env`.
2. Preencha `GEMINI_API_KEY` com sua chave.
3. Em produção, preencha `CORS_ORIGIN` com a origem pública do frontend.

## Rodar local

```bash
npm install
npm run dev
```

Servidor local: `http://localhost:8787`

## Rodar com Docker

Na raiz do projeto:

```bash
docker compose up --build
```

O backend fica exposto em `http://localhost:8787` e usa `GEMINI_API_KEY` via variável de ambiente.

## Deploy no Render

Este backend está preparado para deploy via `render.yaml` na raiz do repositório.

1. No Render, crie via **Blueprint** apontando para este repositório.
2. No serviço `clima-agora-api`, configure:
   - `GEMINI_API_KEY` (obrigatória)
   - `CORS_ORIGIN` (obrigatória em produção)
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
