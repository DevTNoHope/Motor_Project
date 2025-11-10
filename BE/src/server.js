const app = require('./app');
const { PORT = 8000 } = process.env;

app.listen(PORT,'0.0.0.0', () => {
  console.log(`BE running at http://0.0.0.0:${PORT}`);
});
