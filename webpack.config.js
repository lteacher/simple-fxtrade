const path = require('path');

module.exports = {
  entry: "./build/index.js", // string | object | array
  // Here the application starts executing
  // and webpack starts bundling

  output: {
    // options related to how webpack emits results

    path: path.resolve(__dirname, "dist"), // string
    // the target directory for all output files
    // must be an absolute path (use the Node.js path module)

    filename: "index.js", // string
    // the filename template for entry chunks

    // publicPath: "/assets/", // string
    // the url to the output directory resolved relative to the HTML page

    // library: "MyLibrary", // string,
    // the name of the exported library

    // libraryTarget: "umd", // universal module definition
    // the type of the exported library

    /* Advanced output configuration (click to show) */
  },

  module: {
    // configuration regarding modules

    rules: [
      // rules for modules (configure loaders, parser options, etc.)
      {
        loader: "babel-loader",
        // the loader which should be applied, it'll be resolved relative to the context
        // -loader suffix is no longer optional in webpack2 for clarity reasons
        // see webpack 1 upgrade guide

        options: {
          presets: ["env"]
        },
        // options for the loader
      },
      {
        test: /\.json$/,
        loader: 'json-loader'
      },
    ],

    /* Advanced module configuration (click to show) */
  },

  node: {
    console: true,
    fs: 'empty',
    net: 'empty',
    tls: 'empty'
  },

  resolve: {
    // options for resolving module requests
    // (does not apply to resolving to loaders)

    // modules: [
    //   "node_modules",
    //   path.resolve(__dirname, "node_modules")
    // ],
    // directories where to look for modules

    // extensions: [".js", "json"],
    // extensions that are used

    /* alternative alias syntax (click to show) */

    /* Advanced resolve configuration (click to show) */
  },

  context: __dirname, // string (absolute path!)
  // the home directory for webpack
  // the entry and module.rules.loader option
  //   is resolved relative to this directory

  // target: "node", // enum
  // the environment in which the bundle should run
  // changes chunk loading behavior and available modules

  /* Advanced configuration (click to show) */
}
