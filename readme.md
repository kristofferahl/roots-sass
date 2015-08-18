# roots-sass

Sass plugin for roots.cx based on node-sass

## Installation

	npm install roots-sass --save

## Usage

```coffee
sass = require 'roots-sass'

module.exports =
  extensions: [sass(files: "assets/css/main.scss", out: 'css/site.css', style: 'compressed')]
```

## Options

### files
String or array of strings pointing to one or more file paths.

### out
Where you want to output your compiled css file to in your public folder (or whatever you have set output to in the roots settings).

### style
Determines the output format of the final CSS style. (nested/expanded/compact/compressed)