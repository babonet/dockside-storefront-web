'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { featured } = require('../src/catalog');

test('caps featured products at the catalog size', () => {
  assert.equal(featured(99).length, 4);
});
