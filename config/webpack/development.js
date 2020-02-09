process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.loaders.append("bootstrap.native", {
  test: /bootstrap\.native/,
  use: {
    loader: "bootstrap.native-loader",
    options: {
      only: ["modal"],
      bsVersion: 4
    }
  }
})

module.exports = environment.toWebpackConfig()
