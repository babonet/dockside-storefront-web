'use strict';

const PRODUCTS = [
  { sku: 'SKU-1001', name: 'Harbor canvas tote', price: 19.99 },
  { sku: 'SKU-2002', name: 'Lighthouse ceramic mug', price: 5 },
  { sku: 'SKU-3003', name: 'Anchor wool throw', price: 64 },
  { sku: 'SKU-4004', name: 'Sea-glass coaster set', price: 12.5 },
];

function featured(limit = 3) {
  return PRODUCTS.slice(0, Math.max(1, Math.min(limit, PRODUCTS.length)));
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}

function renderHome(items) {
  const cards = items
    .map((p) => `<li><strong>${escapeHtml(p.name)}</strong> <span>$${p.price.toFixed(2)}</span></li>`)
    .join('');
  return `<!doctype html><html><head><title>Dockside Market</title></head><body><h1>Dockside Market</h1><ul>${cards}</ul></body></html>`;
}

module.exports = { featured, renderHome };
