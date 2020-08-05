const path = require('path')

/**
 * Output directory
 */
const buildDir = path.join(__dirname, 'build')

/**
 * Lambda Functions
 */
const entryPoints = {
  'http-search': './src/controllers/http/search.js'
}

/**
 * Webpack config
 */
module.exports = {
  mode: 'production',
  target: 'node',
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        type: 'javascript/esm'
      }
    ]
  },
  entry: entryPoints,
  output: {
    libraryTarget: 'commonjs2',
    path: buildDir
  },
  optimization: {
    minimize: false
  }
}
