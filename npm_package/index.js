const { basename, dirname, join, relative, resolve } = require('path');
const {sync} = require('glob');
const extname = require('path-complete-extname');
const {ConfigObject} = require('@rails/webpacker/package/config_types');
const config = require('@rails/webpacker/package/config');
const { source_path: sourcePath, static_assets_extensions: fileExtensions } = require('@rails/webpacker/package/config');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const getExtensionsGlob = () => {
  const {extensions} = config;
  return extensions.length === 1 ? `**/*${extensions[0]}` : `**/*{${extensions.join(',')}}`
};

module.exports = class Base {
  constructor(config, environment) {
    if (config.service_workers_entry_path === undefined) {
      throw "Please define `service_workers_entry_path: service_workers` in webpacker.yml"
    }
    this.packsFolder = config.public_output_path;
    this.jsFolder = 'js';
    this.cssFolder = 'css';
    this.mediaFolder = 'media';
    this.publicFolder = '/';
    this.editConfig(config);
    this.editDevServer(environment);
    this.editLoaders(environment);
    this.editEntries(environment);
    this.editOutputConfig(environment, config);
    this.editManifestPlugin(environment, config);
    this.editMiniCssExtractPlugin(environment, config);
  }

  editConfig(config) {
    config.outputPath = resolve(config.public_root_path);
    config.publicPath = this.publicFolder;
    config.publicPathWithoutCDN = `/${config.public_output_path}/`;
  }

  editDevServer(environment) {
    if (environment.config.devServer !== undefined) {
      environment.config.devServer.contentBase = environment.config.devServer.contentBase.replace(`/${this.packsFolder}`, '');
      environment.config.devServer.publicPath = this.publicFolder;
    }
  }

  editLoaders(environment) {
    environment.loaders.get('file').use[0].options.name = (file) => {
      if (file.includes(sourcePath)) {
        return `${this.packsFolder}/media/[path][name]-[hash].[ext]`
      }
      return `${this.packsFolder}/media/[folder]/[name]-[hash:8].[ext]`
    };
  }

  editEntries(environment) {
    const result = new ConfigObject();
    const glob = getExtensionsGlob();
    var rootPath = join(config.source_path, config.source_entry_path);
    var paths = sync(join(rootPath, glob));
    paths.forEach((path) => {
      let name_extension = this.jsFolder;
      if (extname(path).match(/\.(css|scss|sass)$/i)) {
        name_extension = this.cssFolder;
      }
      const name = join(config.public_output_path, name_extension, basename(path, extname(path)));
      result.set(name, resolve(path))
    });

    //sets the rule to put service workers on the root folder
    rootPath = join(config.source_path, config.service_workers_entry_path);
    paths = sync(join(rootPath, glob));
    if (paths.length === 0) {
      console.warn("webpacker-pwa is configured but no service workers are available.")
    }
    paths.forEach((path) => {
      const name = basename(path, extname(path));
      result.set(name, resolve(path))
    });

    environment.entry = result;
  }

  editOutputConfig(environment, config) {
    environment.config.output.filename = function (entry) {
      if (entry.chunk.name === 'service-worker') {
        return '[name].js'
      } else {
        return '[name]-[contenthash].js'
      }
    };
    environment.config.output.chunkFilename = '[name]-[contenthash].chunk.js';
    environment.config.output.hotUpdateChunkFilename = '[id]-[hash].hot-update.js';
    environment.config.output.path = config.outputPath;
    environment.config.output.publicPath = config.publicPath;
  }

  editManifestPlugin(environment, config) {
    let manifestPlugin = environment.plugins.get('Manifest');
    manifestPlugin.options.publicPath = false;
    manifestPlugin.options.output = join(config.public_output_path, 'manifest.json');
    manifestPlugin.options.customize = (entry, original, manifest, asset) => {
      const substring1 = join(config.public_output_path, this.jsFolder, '/');
      const substring2 = join(config.public_output_path, this.cssFolder, '/');
      const substring3 = join(config.public_output_path, this.mediaFolder);
      entry.key = entry.key.replace(substring1, '');
      entry.key = entry.key.replace(substring2, '');
      entry.key = entry.key.replace(substring3, this.mediaFolder);
      entry.value = join('/', entry.value);
      return entry;
    };
  }

  editMiniCssExtractPlugin(environment, config) {
    environment.plugins.delete('MiniCssExtract');
    environment.plugins.append(
      'MiniCssExtract',
      new MiniCssExtractPlugin({
        filename: '[name]-[contenthash:8].css',
        chunkFilename: '[name]-[contenthash:8].chunk.css'
      }));
  }
};
