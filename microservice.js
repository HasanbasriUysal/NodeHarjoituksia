// A MINIMAL SERVICE TO FETCH PRICE DATA AND SAVE IT INTO POSTGRESQL DATABASE
// ==========================================================================

// LIBRARIES AND MODULES
// ---------------------

// The pg-pool library for PostgreSQL Server
const Pool = require('pg').Pool;

// The node-cron library to schedule API call to porssisahko.net
const cron = require('node-cron');

// Home made library to access price API from porssisahko.net
const getPrices = require('./getNewPrices');

// TODO: Create a module to fetch FMI observations and forecasts
// lets name it getFmiData.js

// Home made library to add messages to a log file
const logger = require('./logger')

// DATABASE SETTINGS
// ------------

// Create a new pool for Postgres connections
const pool = new Pool({
  user: 'postgres', // In production always create a new user for the app
  password: 'Q2werty',
  host: 'localhost', // Or localhost or 127.0.0.1 if in the same computer
  database: 'smarthome',
  port: 5432
});

// GET, PROCESS AND SAVE DATA
// --------------------------

// Use a date variable to keep track of successful data retrievals
let lastFetchedDate = '1.1.2023'; // Initial value, in production use settings file
let message = ''
const logFile = 'dataOperations.log'

// Try to run an operation in 5 minute intervals from 3 to 4 PM
cron.schedule('*/5 11 * * *', () => {
  try {
    let timestamp = new Date(); // Get the current timestamp
    let dateStr = timestamp.toLocaleDateString(); // Take date part of the timestamp

    // If the date of last successful fetch is not the current day, fetch data
    if (lastFetchedDate != dateStr) {
      message = 'Started fetching price data'

      // Log event to  console and log file
      console.log(message);
      logger.add2log(message, logFile)
      getPrices.fetchLatestPriceData().then((json) => {

        // Loop through prices data and pick startDate and price elements
        json.prices.forEach(async (element) => {
          let values = [element.startDate, element.price];

          // Build a SQL clauset to insert values into table
          const sqlClause = 'INSERT INTO public.hourly_price VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING *';

          // Function for running SQL operations asyncronously
          const runQuery = async () => {
            let resultset = await pool.query(sqlClause, values);
            return resultset;
          }
          // Call query function
          runQuery().then((resultset) => {

            // If there is alredy a price for thetimeslot, row is empty ie. undefined
            if (resultset.rows[0] != undefined) {
              message = 'Added a row' // The message when not undefined
            }
            else {
              message = 'Skipped an existing row' // The message when undefined
            }

            // Log the result of insert operation
            console.log(message);
            logger.add2log(message, logFile)

          })

        });
      });
      lastFetchedDate = dateStr; // Set fetch date to current date

      // Log when last fetched
      message = 'Fetched at ' + lastFetchedDate;
      console.log(message)
      logger.add2log(message, logFile)
    } else {

      // Log if data has been retrieved earlier at the same day
      message = 'Next scheduled event: Data has been successfully retrieved earlier today'
      console.log(message);
      logger.add2log(message, logFile)
    }

    // Log an error if something has been failed to run
  } catch (error) {
    message = 'An error occurred (' + error.toString() + '), trying again in 5 minutes until 4 PM';
    console.log(message)
    logger.add2log(message, logFile)
  }

});

// TODO: Use getFmiData modules function to get obsevations every hour
// and save them to a database table

// TODO: Use getFmiData modules function to get forecasts every hour
// and save them to a database table