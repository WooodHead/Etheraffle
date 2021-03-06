const express = require('express')
    , app = express()
    , port = 3000
    , cors = require('cors')
    , utils = require('./modules/utils')
    , bodyParser = require('body-parser')
    , retrieveResults = require('./pathways/retrieve_results')
    , retrieveMatches = require('./pathways/retrieve_matches')

process.on('unhandledRejection', err => { console.log('unhandledRejection', err.stack)} )//TODO: remove!
/* Add cors support */
app.use(cors())
/* Various pathways to serve the whitepaper */
app.use('/whitepaper', (req,res) => {
  res.sendFile((`${__dirname}/public/etheraffleWhitePaper.pdf`))
})
app.use('/ethrelief/whitepaper', (req,res) => {
  res.sendFile((`${__dirname}/public/ethReliefWhitePaper.pdf`))
})
/* Requests to etheraffle.com/ico picks up the ico react app static files from this location */
app.use('/ico', express.static(`${__dirname}/../../ico/build/`))
/* Public folder for serving static images/miscellany */
app.use('/public', express.static(`${__dirname}/public/`))
/* All other reqs pick up this app's build */
app.use(express.static(__dirname + '/build/'))
app.use(bodyParser.urlencoded({extended: true}))
app.use(bodyParser.json())
app.use((err, req, res, next) => {//Allows custom error handling of the bodyParser middleware...
  if(err instanceof SyntaxError) return res.status(500).send('Error - malformed JSON input!')
  return res.status(500).send('Internal Server Error!')
})
/* Specific pathways come first... */
app.get('/ico', (req, res) => res.sendFile(`${__dirname}/../../ico/build/index.html`))
/* Before the catch all version grabs the other requests! */
app.get('/*', (req, res) => res.sendFile(`${__dirname}/build/index.html`))
/* Get matches array for smart contract */
app.post('/api/a', (req,res) => {
  return retrieveMatches(req.body)
  .then(result => {
    res.status(200).json({m:result})
  }).catch(err => utils.errorHandler('api/a', 'App', req.body, err))
})
/* Get user results for front end */
app.post('/api/ethaddress', (req,res) => {
  return retrieveResults(req.body)
  .then(results => {
    return results != null ? res.status(200).json(results) : res.status(200).json({message:'Eth address not found'})
  }).catch(err => utils.errorHandler('/api/ethaddress', 'App', req.body, err))
})
/* Contact form emails */
app.post('/api/contactform', (req,res) => {
  return utils.sendEmail('Contact Form Submission', `From: ${req.body.email}<br><br>Query: ${req.body.query}`, 'support')
  .then(bool => {
    res.status(200).json({success: bool})
  }).catch(err => utils.errorHandler('api/contactform', 'App', req.body, err))
})
app.listen(port, () => console.log(`Express server started & is listening on port: ${port}`))
