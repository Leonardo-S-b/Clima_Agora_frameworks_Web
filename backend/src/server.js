import 'dotenv/config';

import cors from 'cors';
import express from 'express';

const app = express();
const port = Number(process.env.PORT || 8787);
const geminiApiKey = (process.env.GEMINI_API_KEY || '').trim();

app.use(cors());
app.use(express.json({ limit: '128kb' }));

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'clima-agora-ai-backend' });
});

app.post('/travel/suggestions', async (req, res) => {
  if (!geminiApiKey) {
    return res.status(503).json({
      error: 'backend_not_configured',
      message: 'GEMINI_API_KEY não configurada no servidor.',
    });
  }

  const prompt = String(req.body?.prompt || '').trim();
  if (!prompt) {
    return res.status(400).json({
      error: 'invalid_request',
      message: 'Campo prompt é obrigatório.',
    });
  }

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              parts: [{ text: prompt }],
            },
          ],
        }),
      },
    );

    if (!response.ok) {
      const errorText = await response.text();
      return res.status(response.status).json({
        error: 'llm_upstream_error',
        message: 'Falha ao consultar Gemini.',
        details: errorText.slice(0, 400),
      });
    }

    const data = await response.json();
    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!text || typeof text !== 'string') {
      return res.status(502).json({
        error: 'empty_llm_response',
        message: 'Resposta vazia da IA.',
      });
    }

    return res.json({ text: text.trim() });
  } catch (error) {
    return res.status(500).json({
      error: 'internal_error',
      message: 'Erro interno ao gerar sugestões.',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

app.listen(port, () => {
  console.log(`AI backend online em http://localhost:${port}`);
});
