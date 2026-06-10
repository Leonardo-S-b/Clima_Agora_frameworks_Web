import 'dotenv/config';

import cors from 'cors';
import express from 'express';
import rateLimit from 'express-rate-limit';

import trackingRouter from './routes/tracking.js';

const app = express();
const isProduction = process.env.NODE_ENV === 'production';
const port = Number(process.env.PORT || 8787);
const geminiApiKey = (process.env.GEMINI_API_KEY || '').trim();
const corsOrigins = (process.env.CORS_ORIGIN || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
const trustProxy = (process.env.TRUST_PROXY || '').trim();

if (isProduction && corsOrigins.length === 0) {
  throw new Error(
    'CORS_ORIGIN deve ser configurada em producao com a origem publica do frontend.',
  );
}

if (trustProxy) {
  app.set('trust proxy', trustProxy === 'true' ? 1 : trustProxy);
}

const corsOptions = {
  origin(origin, callback) {
    if (!origin || corsOrigins.length === 0 || corsOrigins.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error('Origin nao permitida por CORS.'));
  },
  methods: ['GET', 'POST', 'OPTIONS'],
};

const travelSuggestionsLimiter = rateLimit({
  windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS || 60_000),
  limit: Number(process.env.RATE_LIMIT_MAX || 30),
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    error: 'rate_limited',
    message: 'Muitas solicitacoes. Aguarde um instante e tente novamente.',
  },
});

app.use(cors(corsOptions));
app.use(express.json({ limit: '128kb' }));

app.use('/travel/route-tracking', trackingRouter);

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'clima-agora-ai-backend' });
});

app.post('/travel/suggestions', travelSuggestionsLimiter, async (req, res) => {
  if (!geminiApiKey) {
    return res.status(503).json({
      error: 'backend_not_configured',
      message: 'GEMINI_API_KEY nao configurada no servidor.',
    });
  }

  const prompt = String(req.body?.prompt || '').trim();
  if (!prompt) {
    return res.status(400).json({
      error: 'invalid_request',
      message: 'Campo prompt e obrigatorio.',
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
      message: 'Erro desconhecido.',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

app.listen(port, () => {
  console.log(`AI backend online na porta ${port}`);
});
