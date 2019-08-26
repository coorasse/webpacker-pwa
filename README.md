# Webpacker Progressive Web App

Webpacker does not support Progressive Web Apps? Here is the solution for you.

This package adds customizations on the top of the standard Rails Webpacker configuration and allows you to start
writing a Progressive Web App.

Is meant as a quick tool that you can use to get it working today, without waiting for the necessary changes to be introduceds and approved on webpacker. 
It follows the guide written about The Progressive Rails App.

## Features

* Overrides default Webpacker configuration transparently
* Compiles service workers directly in the `public` folder.
* Allows to code service workers and use webpack-dev-server.
* No changes are needed server-side
* Works without Sprockets.

## Usage

1. Install the npm package:

`bin/yarn add webpacker-wpa`

2. Edit `config/webpack/environment.js`:

<pre>
const { resolve } = require('path');
const { config, environment, Environment } = require('@rails/webpacker');
<b>const WebpackerPwa = require('webpacker-pwa');
new WebpackerPwa(config, environment);</b>
module.exports = environment;
</pre>

3. Define the service workers folder in `config/webpacker.yml`

`service_workers_entry_path: service_workers`

Start writing your Progressive Rails App! :tada:

## Compatibility

The package is doing a lot of changes on the default Webpacker configuration.
If some configurations change on Webpacker, this package might need to be updated.
The current version has been tested with Webpacker ~> 4.0.

