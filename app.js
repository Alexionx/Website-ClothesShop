
const express = require('express');
const app = express();
const ejs = require('ejs');


app.set('view engine', 'ejs');

app.use(express.static('public'));


app.get('/', (req, res) => {
  res.redirect('/index');
});

app.get('/index', (req, res) => {
  res.render('index');
});

app.get('/profile', (req, res) => {
  res.render('profile');
});

app.get('/description', (req, res) => {
  res.render('description');
});


const port = process.env.PORT || 3000;
app.listen(port, '0.0.0.0', () => {
  console.log(`Server is listening on ${port}`);
});