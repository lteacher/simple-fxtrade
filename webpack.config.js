const path = require('path');

const browser = {
  entry: "./build/index.js",

  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "browser.js",
    library: "fx",
    libraryTarget: "umd",
  },

  module: {
    rules: [
      {
        loader: "babel-loader",

        options: {
          presets: ["env"]
        },
      },
      {
        test: /\.json$/,
        loader: 'json-loader'
      },
    ],
  },

  node: {
    console: true,
    fs: 'empty',
    net: 'empty',
    tls: 'empty'
  },
}

const node = {
  entry: "./build/index.js",

  target: 'node',

  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "node.js",
    libraryTarget: "umd",
  },

  module: {
    rules: [
      {
        loader: "babel-loader",

        options: {
          presets: ["env"]
        },
      },
      {
        test: /\.json$/,
        loader: 'json-loader'
      },
    ],
  },
}

module.exports = [browser, node];
