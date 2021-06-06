import express from 'express';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import path from 'path';
import routes from './src/routes/apiRoutes';

//const mongoCon = require('./src/data/mongo_direct/dbCons/mongoCon');
const cookieSession = require('cookie-session');
const createError = require('http-errors');

const app = express();
const PORT = 3000;

//body-parser setups
app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(bodyParser.json());
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, './src/views'));

routes(app);

// serving static files
app.use(express.static(path.join(__dirname, './static/')));

app.get('/', (req, res) => {  
  //res.sendFile(path.join(__dirname + '/static/index.html'));
});

app.use((request, response, next) => {
  return next(createError(404, 'File not found'));
});

app.use((err, request, response, next) => {
  response.locals.message = err.message;
  console.error(err);
  const status = err.status || 500;
  response.locals.status = status;
  response.status(status);
  response.render('error404');
});

app.listen(PORT, () =>
  console.log(`Your server is RUNNING on ${PORT}`));