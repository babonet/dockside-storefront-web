'use strict';

const http = require('node:http');
const { routes, service, version } = require('./routes');

function send(res, status, body, contentType = 'application/json') {
  res.writeHead(status, { 'content-type': contentType });
  res.end(contentType === 'application/json' ? JSON.stringify(body) : body);
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
    });
    req.on('end', () => {
      if (!data) return resolve({});
      try {
        return resolve(JSON.parse(data));
      } catch (err) {
        return reject(Object.assign(err, { status: 400 }));
      }
    });
    req.on('error', reject);
  });
}

function createServer() {
  return http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');

    if (req.method === 'GET' && url.pathname === '/health') {
      return send(res, 200, { status: 'ok', service, version });
    }

    const route = routes.find((r) => r.method === req.method && r.match(url.pathname));
    if (!route) return send(res, 404, { error: 'not_found' });

    try {
      const body = req.method === 'GET' ? {} : await readJson(req);
      const params = route.match(url.pathname);
      const result = await route.handler({ body, params, query: url.searchParams });
      return send(res, result.status || 200, result.body, result.contentType);
    } catch (err) {
      if (err.status && err.status < 500) {
        return send(res, err.status, { error: err.message });
      }
      console.error(`[${new Date().toISOString()}] ${req.method} ${url.pathname} failed:`, err.stack || err);
      return send(res, 500, { error: 'internal_error' });
    }
  });
}

if (require.main === module) {
  const port = Number(process.env.PORT || 8080);
  createServer().listen(port, () => console.log(`${service} ${version} listening on :${port}`));
}

module.exports = { createServer };
