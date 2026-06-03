import express from 'express';
const router = express.Router();

// POST /travel/route-tracking/start
router.post('/start', async (req, res) => {
  try {
    const { originLat, originLng, destinationLat, destinationLng, mode } = req.body;
    if (!originLat || !originLng || !destinationLat || !destinationLng) {
      return res.status(400).json({ error: 'invalid_request', message: 'origin/destination required' });
    }

    // TODO: call routing service to calculate route
    const sessionId = crypto.randomUUID?.() || Date.now().toString();
    res.json({ trackingSessionId: sessionId, routePoints: [], intermediatePoints: [] });
  } catch (err) {
    res.status(500).json({ error: 'server_error', message: String(err) });
  }
});

export default router;
