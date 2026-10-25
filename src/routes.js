'use strict';

const { featured, renderHome } = require('./catalog');
const pkg = require('../package.json');

const routes = [
  {
    method: 'GET',
    match: (path) => (path === '/' ? {} : null),
    handler: async () => ({ status: 200, body: renderHome(featured(3)), contentType: 'text/html; charset=utf-8' }),
  },
  {
    method: 'GET',
    match: (path) => (path === '/api/featured' ? {} : null),
    handler: async ({ query }) => ({ status: 200, body: { items: featured(Number(query.get('limit') || 3)) } }),
  },
];

module.exports = { service: pkg.name, version: pkg.version, routes };
