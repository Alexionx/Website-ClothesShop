// Import required modules
const express = require('express');
const app = express();
const ejs = require('ejs');

// Set the view engine to use EJS (optional)
app.set('view engine', 'ejs');

app.use(express.static('public'));

// Define a route handler for the root route
app.get('/', (req, res) => {
  // Redirect to the '/index' route
  res.redirect('/index');
});



// Define a route handler for the root route
app.get('/index', (req, res) => {
  // Render the 'index.ejs' template
  res.render('index');
});

app.get('/profile', (req, res) => {
  // Render the 'index.ejs' template
  res.render('profile');
});

app.get('/description', (req, res) => {
  // Render the 'index.ejs' template
  res.render('description');
});

// Start the server and listen on port 3000
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is listening on http://localhost:${port}`);
});