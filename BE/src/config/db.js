const { Sequelize } = require('sequelize');
const { db } = require('./env');

const sequelize = new Sequelize(db.name, db.user, db.pass, {
  host: db.host,
  port: db.port,
  dialect: 'mysql',
  logging: false,
  timezone: '+00:00' // Lưu UTC
});

// Health check helper
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('[DB] Connection has been established successfully.');
  } catch (error) {
    console.error('[DB] Unable to connect to the database:', error);
    throw error;
  }
}

module.exports = { sequelize, testConnection };
