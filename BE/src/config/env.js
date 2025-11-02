const required = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_NAME'];
required.forEach((k) => {
  if (!process.env[k]) console.warn(`[ENV] Missing ${k}`);
});
module.exports = {
  db: {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    pass: process.env.DB_PASS,
    name: process.env.DB_NAME
  }
};
