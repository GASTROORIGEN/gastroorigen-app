const ALLOWED_ORIGINS = new Set([
  'https://gastroorigen.github.io',
  'http://localhost:3000',
  'http://localhost:8080',
]);

const MODEL = 'gemini-2.5-flash';

const schema = {
  type: 'object',
  additionalProperties: false,
  properties: {
    identified: { type: 'boolean' },
    confidence: { type: 'integer', minimum: 0, maximum: 100 },
    category: { type: 'string', enum: ['ingrediente', 'platillo', 'otro', 'incierto'] },
    name: { type: 'string' },
    scientific_name: { type: 'string' },
    type: { type: 'string' },
    description: { type: 'string' },
    origin: { type: 'string' },
    mexico_region: { type: 'string' },
    characteristics: { type: 'array', items: { type: 'string' }, maxItems: 8 },
    flavor_profile: { type: 'array', items: { type: 'string' }, maxItems: 6 },
    scoville: { type: 'string' },
    uses: { type: 'array', items: { type: 'string' }, maxItems: 8 },
    dishes: { type: 'array', items: { type: 'string' }, maxItems: 8 },
    main_ingredients: { type: 'array', items: { type: 'string' }, maxItems: 12 },
    preparation: { type: 'string' },
    accompaniments: { type: 'array', items: { type: 'string' }, maxItems: 8 },
    sauces: { type: 'array', items: { type: 'string' }, maxItems: 8 },
    variants: { type: 'array', items: { type: 'string' }, maxItems: 8 },
    seasonality: { type: 'string' },
    history: { type: 'string' },
    cultural_note: { type: 'string' },
    needs_better_photo: { type: 'boolean' },
    capture_guidance: { type: 'string' }
  },
  required: [
    'identified','confidence','category','name','scientific_name','type','description','origin',
    'mexico_region','characteristics','flavor_profile','scoville','uses','dishes','main_ingredients',
    'preparation','accompaniments','sauces','variants','seasonality','history','cultural_note',
    'needs_better_photo','capture_guidance'
  ]
};

function applyCors(req, res) {
  const origin = req.headers.origin || '';
  if (ALLOWED_ORIGINS.has(origin)) res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Cache-Control', 'no-store');
}

function findOutputText(payload) {
  if (typeof payload.output_text === 'string' && payload.output_text.trim()) return payload.output_text;
  const steps = Array.isArray(payload.steps) ? payload.steps : [];
  for (let i = steps.length - 1; i >= 0; i--) {
    const step = steps[i];
    if (step?.type !== 'model_output' || !Array.isArray(step.content)) continue;
    for (const block of step.content) {
      if (block?.type === 'text' && typeof block.text === 'string' && block.text.trim()) return block.text;
    }
  }
  return '';
}

function collectSources(payload) {
  const seen = new Set();
  const out = [];
  const steps = Array.isArray(payload.steps) ? payload.steps : [];
  for (const step of steps) {
    if (step?.type !== 'model_output' || !Array.isArray(step.content)) continue;
    for (const block of step.content) {
      const annotations = Array.isArray(block?.annotations) ? block.annotations : [];
      for (const a of annotations) {
        if (a?.type !== 'url_citation' || !a.url || seen.has(a.url)) continue;
        seen.add(a.url);
        out.push({ title: a.title || a.url, url: a.url });
      }
    }
  }
  return out.slice(0, 8);
}

module.exports = async function handler(req, res) {
  applyCors(req, res);
  if (req.method === 'OPTIONS') return res.status(204).end();

  const key = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
  if (req.method === 'GET') {
    return res.status(200).json({
      ok: true,
      service: 'GASTROORIGEN Gemini Vision',
      configured: Boolean(key),
      provider: 'google-gemini',
      model: MODEL,
      grounding: 'google_search'
    });
  }
  if (req.method !== 'POST') return res.status(405).json({ error: 'Método no permitido.' });
  if (!key) return res.status(503).json({ error: 'Gemini todavía no está configurado en el servidor.', code: 'GEMINI_NOT_CONFIGURED' });

  try {
    const { image, mode = 'No estoy seguro', source = 'camera' } = req.body || {};
    if (typeof image !== 'string') return res.status(400).json({ error: 'Falta la fotografía.' });
    const match = image.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/s);
    if (!match) return res.status(400).json({ error: 'Formato de fotografía no válido.' });
    const mimeType = match[1];
    const base64 = match[2];
    if (base64.length > 6_500_000) return res.status(413).json({ error: 'La fotografía es demasiado grande.' });

    const prompt = `Eres GASTROORIGEN, un sistema de identificación y consulta de gastronomía mexicana.\n\nAnaliza la fotografía y genera una ficha completa del elemento principal visible. El usuario indicó: ${mode}. La fuente es: ${source}.\n\nREGLAS:\n1. Primero identifica visualmente el ingrediente o platillo. No inventes certeza. Si la foto no permite identificarlo, usa identified=false, category=incierto y explica cómo repetir la foto.\n2. Para origen, historia, regiones, usos, variantes y contexto cultural, usa la Búsqueda de Google cuando sea útil y evita afirmar datos dudosos como hechos.\n3. Si es ingrediente, llena dishes con platillos mexicanos donde se usa; main_ingredients y preparation pueden quedar vacíos si no aplican.\n4. Si es platillo, llena main_ingredients, preparation y variants; dishes puede quedar vacío.\n5. scoville solo aplica a chiles o productos con escala Scoville; de lo contrario devuelve cadena vacía.\n6. Responde en español de México, con texto claro y conciso.\n7. No conviertas una hipótesis visual en un dato histórico. La confianza corresponde a la IDENTIFICACIÓN VISUAL.\n8. Devuelve arreglos vacíos o cadenas vacías cuando un campo no aplique.\n9. El resultado debe ajustarse exactamente al esquema JSON.`;

    const response = await fetch('https://generativelanguage.googleapis.com/v1beta/interactions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': key,
        'Api-Revision': '2026-05-20'
      },
      body: JSON.stringify({
        model: MODEL,
        input: [
          { type: 'text', text: prompt },
          { type: 'image', data: base64, mime_type: mimeType }
        ],
        tools: [{ type: 'google_search' }],
        generation_config: { thinking_level: 'low' },
        response_format: {
          type: 'text',
          mime_type: 'application/json',
          schema
        }
      })
    });

    const rawText = await response.text();
    let raw;
    try { raw = JSON.parse(rawText); } catch { raw = { raw: rawText }; }

    if (!response.ok) {
      const googleMessage = raw?.error?.message || raw?.message || 'Google Gemini no pudo completar la solicitud.';
      if (response.status === 429) return res.status(429).json({ error: 'Se alcanzó temporalmente el límite gratuito de Gemini. Intenta de nuevo más tarde.', detail: googleMessage, code: 'GEMINI_RATE_LIMIT' });
      if (response.status === 400 || response.status === 403) return res.status(response.status).json({ error: 'Gemini rechazó la solicitud. Revisa la clave y los permisos de Google AI Studio.', detail: googleMessage, code: 'GEMINI_AUTH_OR_REQUEST' });
      return res.status(502).json({ error: 'No se pudo obtener respuesta de Gemini.', detail: googleMessage, code: 'GEMINI_UPSTREAM' });
    }

    const outputText = findOutputText(raw);
    if (!outputText) return res.status(502).json({ error: 'Gemini respondió sin una ficha utilizable.', code: 'GEMINI_EMPTY' });

    let result;
    try { result = JSON.parse(outputText); }
    catch { return res.status(502).json({ error: 'No se pudo interpretar la ficha devuelta por Gemini.', code: 'GEMINI_BAD_JSON' }); }

    return res.status(200).json({
      ok: true,
      provider: 'google-gemini',
      model: MODEL,
      result,
      sources: collectSources(raw),
      usage: raw?.usage || null
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Error interno al procesar la fotografía.', detail: error?.message || String(error) });
  }
};
