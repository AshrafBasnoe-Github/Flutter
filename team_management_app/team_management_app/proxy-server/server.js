const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

app.use('/api', createProxyMiddleware({
  target: 'https://team-management-api.dops.tech',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api/v2', // Verander dit naar je API pad
  },
  onProxyReq: (proxyReq, req, res) => {
    proxyReq.setHeader('Access-Control-Allow-Origin', '*');
  },
}));

app.listen(3000, () => {
  console.log('Proxy server is running on http://localhost:3000');
});