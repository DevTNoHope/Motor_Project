const app = require('./app');
const { PORT = 8000 } = process.env;

app.listen(PORT, () => {
  console.log(`BE running at http://localhost:${PORT}`);
});
