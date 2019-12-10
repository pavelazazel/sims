const { environment } = require('@rails/webpacker')
const webpack = require("webpack")

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

module.exports = environment
