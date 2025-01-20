const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function(app) {
  app.use(
    '/api',
    createProxyMiddleware({
      target: 'https://team-management-api.dops.tech',
      changeOrigin: true,
      pathRewrite: {
        '^/api': '/api/v2', // Verander dit naar de juiste API versie
      },
    })
  );
};