# PRD: Real-Time Route Tracking com Previsão Climática

**Data**: Junho 2026  
**Versão**: 1.0  
**Status**: Planejamento  

---

## 1. Executive Summary

O Clima Agora será expandido para oferecer uma experiência imersiva de planejamento de viagens com acompanhamento **em tempo real** do trajeto do usuário. A feature combinará:
- **Flutter Map (OpenStreetMap)** para renderização de mapa interativo
- **Localização do usuário** em tempo real (GPS)
- **Previsão climática por ponto do trajeto** (balões/ícones animados)
- **Sugestões de atividades** ajustadas ao clima local em cada segmento

**Objetivo**: Transformar a experiência de viagem de planejamento estático para dinâmico e imersivo, aumentando o engajamento e a relevância das sugestões.

---

## 2. Problema & Oportunidade

### Problema
- Usuários planejam atividades sem visibilidade do clima **durante o trajeto**
- Clima muda significativamente em trajetos longos ou entre altitudes diferentes
- Sugestões atuais não consideram condições em tempo real

### Oportunidade
- Oferecer previsão climática granular por trecho de rota
- Gerar sugestões contextualizadas dinamicamente
- Aumentar confiabilidade das recomendações
- Criar diferencial competitivo vs. outros apps de viagem

---

## 3. Visão do Produto

> *"Um app que não apenas sugere atividades, mas guia o usuário em tempo real, mostrando clima e sugestões atualizadas a cada quilômetro do trajeto."*

### Proposta de Valor
| Benefício | Descrição |
|-----------|-----------|
| **Precisão** | Clima real para cada ponto do trajeto, não estimativa geral |
| **Segurança** | Alertas para mudanças climáticas inesperadas (chuva, vento) |
| **Engajamento** | Atividades sugeridas dinamicamente conforme avança |
| **Imersão** | Visualização interativa e animada de clima sobre mapa |

---

## 4. Personas & User Stories

### Persona 1: Turista em Viagem Road Trip
**Ana, 32, planejadora de viagens**
- Faz trajetos de 300+ km entre cidades
- Quer saber clima em tempo real em cada trecho
- Busca atividades seguras conforme clima muda

**User Story**:
```
Como turista em road trip,
Quero ver clima em tempo real ao longo da rota,
Para ajustar minhas atividades conforme o trajeto progride
e não ser surpreendida por mudanças climáticas.
```

**Critério de Aceite**:
- ✅ Mapa exibe rota com pontos intermediários
- ✅ Cada ponto mostra ícone de clima (chuva, sol, nuvem, vento)
- ✅ Ao toque, exibe previsão detalhada (temp, umidade, chance chuva)
- ✅ Sugestões atualizadas a cada 50km ou mudança climática

### Persona 2: Montanhista/Aventureiro
**Carlos, 45, aventureiro**
- Faz trilhas com mudanças de altitude
- Clima muda drasticamente em poucas horas
- Precisa alertas de risco (tempestade, neve)

**User Story**:
```
Como montanhista,
Quero receber alertas de clima perigoso ao longo da trilha,
Para decidir se continuo ou arrumo acampamento antes.
```

**Critério de Aceite**:
- ✅ Alerta visual/áudio para mudanças climáticas severas
- ✅ Indicador de risco por segmento (verde, amarelo, vermelho)
- ✅ Recomendação de parada preventiva se clima piorar

### Persona 3: Viajante Local Explorador
**Marina, 28, explorador urbano**
- Faz trajetos curtos entre pontos de interesse (5-20km)
- Quer experiência visual e interativa
- Aprecia recomendações contextualizadas

**User Story**:
```
Como explorador urbano,
Quero ver sugestões de atividades ajustadas ao clima de cada bairro,
Para descobrir experiências únicas conforme caminho.
```

**Critério de Aceite**:
- ✅ Mapa exibe atividades sugeridas por bairro
- ✅ Filtros por tipo de atividade (indoor/outdoor)
- ✅ Atualização em tempo real conforme posição muda

---

## 5. Requisitos Funcionais

### RF-1: Visualização de Rota com Flutter Map
- [ ] Integrar Flutter Map (OSM) para renderização
- [ ] Renderizar rota entre ponto A e ponto B
- [ ] Suportar múltiplos modos: dirigindo, caminhando, bicicleta
- [ ] Permitir ajuste de rota (alternativas)
- [ ] Zoom/pan interativo

### RF-2: Tracking de Localização em Tempo Real
- [ ] Ativar GPS do dispositivo
- [ ] Atualizar posição do usuário a cada 10-30 segundos
- [ ] Calcular progresso na rota (% concluído, tempo restante)
- [ ] Detectar quando usuário sai da rota
- [ ] Histórico de posições dos últimos 30 minutos

### RF-3: Previsão Climática por Ponto da Rota
- [ ] Calcular 5-10 pontos intermediários na rota
- [ ] Chamar API de clima para cada ponto
- [ ] Renderizar ícone visual de clima em cada ponto
- [ ] Atualizar previsão a cada 5 minutos
- [ ] Cache de previsões localmente

### RF-4: Balões/Ícones de Clima Animados
- [ ] Renderizar balões sobre mapa com ícones (sol, chuva, nuvem, vento)
- [ ] Animar transição entre balões
- [ ] Ao toque, exibir detalhe (temp, umidade, % chuva, velocidade vento)
- [ ] Mudar cor/tamanho conforme intensidade climática
- [ ] Suportar animação de chuva/neve sobre mapa

### RF-5: Sugestões de Atividades Contextualizadas
- [ ] Gerar sugestões baseadas em clima + localização + horário
- [ ] Atualizar sugestões a cada mudança significativa de clima
- [ ] Mostrar atividades recomendadas vs. não recomendadas
- [ ] Ícone de "risco" se clima inadequado para atividade

### RF-6: Alertas de Risco Climático
- [ ] Detectar mudanças severas (chuva forte, vento, queda temp)
- [ ] Exibir alerta visual (banner, notificação)
- [ ] Sugerir parada segura (hotel, café, abrigo)
- [ ] Opcionalmente, áudio de alerta

### RF-7: Timeline de Trajeto
- [ ] Mostrar timeline com:
  - Horário estimado em cada ponto
  - Clima previsto
  - Atividades sugeridas
  - Pontos de interesse/parada
- [ ] Permitir clicar em ponto e ir para mapa/detalhe

### RF-8: Histórico & Replay
- [ ] Gravar trajeto completo (posição, tempo, clima, atividades)
- [ ] Permitir "replay" do trajeto (play/pause/velocidade)
- [ ] Exportar trajeto como PDF/imagem
- [ ] Compartilhar com amigos

---

## 6. Requisitos Não-Funcionais

| Requisito | Descrição |
|-----------|-----------|
| **Performance** | Mapa renderiza <500ms, posição atualizada <2s |
| **Precisão GPS** | ±5m (urbano), ±20m (rural) |
| **Previsão Climática** | Atualiza a cada 5 min, latência <1s |
| **Offline** | Mapa/clima em cache por 1 hora |
| **Bateria** | GPS + tracking + mapa consome <10% bateria/hora |
| **Escalabilidade** | Suporta 100k usuários simultâneos |
| **Disponibilidade** | 99.5% uptime |
| **Latência API** | <500ms p95 para clima, <200ms para sugestões |

---

## 7. User Journey

```
1. Usuário abre app e seleciona "Roteiros"
2. Escolhe origem/destino e modo (dirigindo/caminhando/bicicleta)
3. App calcula rota e exibe mapa interativo (OSM)
4. Sistema calcula 7 pontos intermediários e busca clima
5. Clima é renderizado como balões animados sobre mapa
6. Usuário inicia trajeto (pressiona "Começar")
7. GPS ativa e posição é atualizada a cada 20s
8. Sugestões de atividades aparecem dinamicamente
9. Se clima muda significativamente:
   - Alerta visual é exibido
   - Novas sugestões são geradas
   - Timeline é atualizada
10. Ao chegar ao destino, app oferece replay do trajeto
11. Usuário pode compartilhar ou salvar trajeto
```

---

## 8. Escopo MVP vs. Expansão Futura

### MVP (Fase 1 - Próximos 2 sprints)
✅ Mapa (OSM) renderizando rota
- ✅ Localização em tempo real
- ✅ Previsão climática em 5 pontos
- ✅ Balões de clima básicos (4 ícones: sol, nuvem, chuva, vento)
- ✅ Sugestões atualizadas a cada ponto
- ✅ Timeline básica

### Fase 2 (Próximas 4 sprints)
- 🔄 Alertas de risco
- 🔄 Animações avançadas (chuva/neve sobre mapa)
- 🔄 Histórico & replay
- 🔄 Múltiplas rotas alternativas

### Fase 3+ (Futuro)
- 📅 Integração com Strava/Garmin
- 📅 Compartilhamento social
- 📅 Recomendações baseadas em IA (machine learning)
- 📅 Sugestões de paradas (hotel, gasolina, restaurante)
- 📅 Integração com calendário & bookings

---

## 9. Métricas de Sucesso

| Métrica | Meta |
|---------|------|
| **Adoção** | 30% dos usuários ativos usam feature em 30 dias |
| **Engajamento** | 15 min média de sessão (vs. 5 min atual) |
| **Retenção** | 40% de retenção D7 (vs. 25% atual) |
| **Performance** | <2s para carregar mapa + clima |
| **Precisão** | 95% de sugestões relevantes (feedback) |
| **Taxa de Erro** | <1% de crashes relacionados a GPS/mapa |

---

## 10. Dependências & Riscos

### Dependências
- ✅ OSRM / OpenRouteService (roteamento)
- ✅ WeatherAPI / OpenWeather (integração backend)
- ✅ Gerenciamento de permissões de localização (Flutter)
- ✅ Geolocalização (geolocator package)

### Riscos
| Risco | Impacto | Mitigação |
|-------|--------|-----------|
| GPS impreciso/lento | Alto | Usar provider/geolocation com fallback, cacheamento |
| API Clima com rate limit | Alto | Implementar circuit breaker, cache de 5 min |
| Bateria drenada | Médio | Otimizar frequência de updates, modo econômico |
| Cobertura offline deficiente | Médio | Pre-cache de mapa + clima para rota 1 hora antes |

---

## 11. Roadmap & Timeline

```
Semana 1-2: Setup Google Maps, GPS tracking (Sprint 1)
Semana 3-4: Clima por ponto, balões básicos (Sprint 2)
Semana 5-6: Sugestões dinâmicas, timeline (Sprint 3)
Semana 7-8: Alertas, otimizações, testes (Sprint 4)
Semana 9+: Fase 2 - Animações avançadas, histórico, replay
```

---

## 12. Definições & Glossário

- **Ponto Intermediário**: Coordenada ao longo da rota (a cada ~50km ou mudança significativa)
- **Balão de Clima**: Ícone animado sobre mapa mostrando condição meteorológica
- **Timeline**: Vista linear do trajeto com marcos temporais e climáticos
- **Replay**: Playback do trajeto gravado com tempo acelerado
- **Rate Limiting**: Limite de requisições à API de clima (ex: 1 por 5 min/ponto)

---

## Aprovação

| Papel | Nome | Data | Assinatura |
|-------|------|------|-----------|
| Product Manager | Leonardo | Jun 2026 | ☐ |
| Tech Lead | (Tu) | Jun 2026 | ☐ |
| Design Lead | (Design) | Jun 2026 | ☐ |
