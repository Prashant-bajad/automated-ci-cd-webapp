const express = require('express');
const app = express();
const port = process.env.PORT || 3000; // Environment variable se port ya default 3000 use karein

app.get('/', (req, res) => {
  res.send('Hello from Automated CI/CD Webapp!');
});

app.get('/api/status', (req, res) => {
  res.json({ status: 'running', message: 'API is healthy' });
});

app.listen(port, () => {
  console.log(`Web app listening at http://localhost:${port}`);
});