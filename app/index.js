const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from multi-region app',
    region: process.env.AWS_REGION || 'unknown',
    db: process.env.DATABASE_ENDPOINT || 'unset'
  });
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
