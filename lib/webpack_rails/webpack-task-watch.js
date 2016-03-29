var webpack = require('webpack');
var fs = require('fs');
var path = require('path');

// webpack Compiler.Watching instance
var watcher = null;
// callbacks which will be called when next build completes
var currentBuildCallbacks = [];
// object with property 'stats' for success or 'error' for failure
var lastBuildResult = null;

function buildComplete(buildResult) {
  lastBuildResult = buildResult;

  currentBuildCallbacks.forEach(function(callback) {
    callback(buildResult);
  });
  currentBuildCallbacks = [];
}

function makeWatcher(webpackConfig) {
  return webpack(webpackConfig).watch({
    aggregateTimeout: 300, // wait so long for more changes
  }, function(err, stats) {
    if (err) {
      buildComplete({
        error: err,
      });
    } else if (stats.hasErrors()) {
      var errWithDetails = new Error('Webpack build error');
      errWithDetails.stack = (
        'Webpack build error:\n' +
        stats.toJson({errorDetails: true}).errors.join("\n") + ''
      );

      buildComplete({
        error: errWithDetails,
      });
    } else {
      var statsData = stats.toJson({
        hash: true,
        assets: true,
        modules: true,
        chunkOrigins: true,
        cached: true,
      });

      var modules = statsData.modules.map(function(moduleStats) {
        var loadersEnd = moduleStats.identifier.lastIndexOf('!')
        return moduleStats.identifier.slice(loadersEnd == -1 ? 0 : loadersEnd+1)
      })

      buildComplete({
        modules: modules,
      });
    }
  });
}

module.exports = function waitForBuild(opts, done) {
  function sendResults(buildResult) {
    if (buildResult.error) done(buildResult.error);
    else done(null, buildResult);
  }

  if (!watcher) {
    var webpackConfig = require(path.resolve(opts.webpack_config_file || 'config/webpack.config.js'));
    watcher = makeWatcher(webpackConfig);
  }

  if (!watcher.running) {
    sendResults(lastBuildResult);
  } else {
    currentBuildCallbacks.push(sendResults);
  }
};
