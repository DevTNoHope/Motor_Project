const http = require('http');
const app = require('./app');
const { initSocket } = require('./socket');
const { PORT = 8000 } = process.env;

// Tạo HTTP server từ app express
const server = http.createServer(app);

// Khởi tạo socket.io trên server này
initSocket(server);

server.listen(PORT, '0.0.0.0', () => {
  console.log(`BE with Socket.IO running at http://0.0.0.0:${PORT}`);
});
