const fx = require('../dist');

// Wrap in async function
const examples = async () => {

  // Get accounts for authorized user (using OANDA_API_KEY env var)
  const {accounts: [{id}]} = await fx.accounts()

  // Set the id context for all future api calls
  fx.setAccount(id);

  // Get the instruments for the account
  const {instruments} = await fx.instruments();





}

// Call the wrapper function
examples();
