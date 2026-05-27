const { StreamChat } = require('stream-chat');
const env = require('./env');

let client = null;

function getStreamClient() {
  if (client) {
    return client;
  }

  if (!env.stream.apiKey || !env.stream.apiSecret) {
    return null;
  }

  client = StreamChat.getInstance(env.stream.apiKey, env.stream.apiSecret);
  return client;
}

module.exports = {
  getStreamClient
};

