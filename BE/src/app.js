require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const morgan = require('morgan');
const expressLayouts = require('express-ejs-layouts'); 
const cookieParser = require('cookie-parser');
const methodOverride = require('method-override');


const apiRoutes = require('./routes/api');
const webRoutes = require('./routes/web');
const errorHandler = require('./middlewares/error');

const app = express();

// Core middlewares
app.use(cors());
app.use(morgan('dev'));
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(methodOverride((req,res)=>{
  if (req.body && typeof req.body === 'object' && '_method' in req.body) {
    const method = req.body._method;
    delete req.body._method;
    return method;
  }
}));
 // hỗ trợ PUT, DELETE từ form

// EJS view engine (Admin SSR)
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(expressLayouts);                     
app.set('layout', 'layouts/admin');
app.use('/public', express.static(path.join(__dirname, 'public')));

// Routes
app.use('/api/v1', apiRoutes);
app.use('/', webRoutes);

// Error handler
app.use(errorHandler);

module.exports = app;
