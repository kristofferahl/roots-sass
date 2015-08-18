fs        = require 'fs'
path      = require 'path'
RootsUtil = require 'roots-util'
sass      = require 'node-sass'
_         = require 'lodash'
minimatch = require 'minimatch'

module.exports = (opts) ->

  opts = _.defaults opts,
    files: 'assets/css/**/*.scss'
    out: false
    style: 'nested'

  opts.files = Array.prototype.concat(opts.files)

  class RootsAss

    constructor: (@roots) ->
      @category = 'rootsass'
      @util = new RootsUtil(@roots)
      @file_map = {}
      @files = opts.files

      @roots.config.locals ?= {}
      @roots.config.locals.css = (prefix = '') =>
        paths = []

        if opts.out
          paths.push("#{prefix}#{opts.out}")
        else
          for matcher in @files
            paths = paths.concat(get_output_paths.call(@, matcher, prefix))

        paths.map((p) -> "<link rel='stylesheet' href='#{p}' />").join("\n")

    fs: ->
      extract: true
      detect: (f) => _.any(@files, minimatch.bind(@, f.relative))

    compile_hooks: ->
      before_file: (ctx) =>
        result = sass.renderSync({
          file: ctx.file.relative,
          outputStyle: opts.style
        })
        ctx.content = result.css
      after_file: (ctx) =>
        if opts.out then @file_map[ctx.file.relative] = ctx.content
      write: (ctx) =>
        !opts.out

    category_hooks: ->
      after: (ctx) =>
        if not opts.out then return

        all_contents = ''

        for matcher in @files
          for file, content of @file_map when minimatch(file, matcher)
            all_contents += content

        @util.write(opts.out, all_contents)

    get_output_paths = (files, prefix) ->
      @util.files(files).map (f) =>
        filePath = @util.output_path(f.relative).relative
        fileName = path.join(prefix, filePath.replace(path.extname(filePath), '.css'))
        fileName.replace(new RegExp('\\' + path.sep, 'g'), '/')