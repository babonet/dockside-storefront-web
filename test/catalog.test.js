'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { featured, renderHome } = require('../src/catalog');

test('returns the requested number of featured products', () => {
  assert.equal(featured(2).length, 2);
});

test('never returns an empty featured list', () => {
  assert.equal(featured(0).length, 1);
});

test('escapes product names when rendering the home page', () => {
  const html = renderHome([{ sku: 'X', name: '<script>', price: 1 }]);
  assert.ok(!html.includes('<script>'));
});
