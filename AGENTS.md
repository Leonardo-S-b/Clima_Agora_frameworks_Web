# AGENTS.md - Clima Agora

## Objetivo
Manter documentação viva de contexto técnico, decisões e direção arquitetural do projeto para reduzir retrabalho e manter consistência entre frontend e backend.

## Contexto Técnico
- Frontend: Flutter (Material 3)
- Backend: Node.js + Express para IA
- APIs externas:
  - Open-Meteo (geocoding + forecast)
  - OpenRouteService (rota real, com fallback estimado sem chave)
- Estrutura principal:
  - lib/src/features/weather
  - lib/src/features/travel_planning
  - backend/src/server.js
- Persistência local: SharedPreferences
- Localização: Geolocator (com permissões Android)

## Decisões Vigentes
- Prioridade atual: consolidar API em servidor separado antes de refatoração pesada de UI.
- Refatoração grande de travel_planning (controller/service/helpers + decomposição de widgets) está adiada até estabilizar contratos da API.
- IA não fica no app: chamadas passam pelo backend em /travel/suggestions.
- Quando ORS_API_KEY não está configurada, o app usa estimativa local de distância/tempo.
- Deploy Docker de produção não deve usar fallback para localhost ou backend legado; `AI_BACKEND_URL` deve apontar para a URL pública atual do servidor.
- Backend público deve usar `CORS_ORIGIN` configurada e rate limit básico para proteger a chave da IA.

## Direção
1. Estabilizar e versionar contratos de API no servidor.
2. Depois refatorar travel_planning em camadas:
   - controller para orquestração de estado
   - service para regras de negócio/integração
   - helpers para funções puras (formatação/parse/debounce)
3. Reduzir classes grandes em widgets menores reutilizáveis.

## Atualização Contínua
- Atualizar este arquivo sempre que houver:
  - mudança de arquitetura
  - nova feature relevante
  - decisão técnica que impacte fluxo
  - correção de erro recorrente
- Validar sempre com o código atual antes de assumir que o contexto ainda é válido.

Última atualização: 23/05/2026
