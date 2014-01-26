'use strict'

# require
gulp        = require('gulp')
gutil       = require('gulp-util')
jade        = require('gulp-jade')
stylus      = require('gulp-stylus')
coffee      = require('gulp-coffee')
livereload  = require('gulp-livereload')
lr          = require('tiny-lr')
server      = lr()
open        = require('open')
connect     = require('connect')
browserSync = require('browser-sync')
yamlconfig = require('yaml-config')

config = yamlconfig.readConfig('./data/data.yml')

# task

# jade
# https://github.com/phated/gulp-jade
gulp.task 'jade', ->
  gulp.src('./source/index.jade')
    .pipe(jade(
      pretty: true
      data: config
    ))
    .pipe(gulp.dest('./build'))
    .pipe(livereload(server))

# coffee
# https://github.com/wearefractal/gulp-coffee
gulp.task 'coffee', ->
  gulp.src('./source/coffee/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest('./build/js'))
    .pipe(livereload(server))

# stylus
# https://github.com/stevelacy/gulp-stylus
gulp.task 'stylus', ->
  gulp.src('./source/stylus/*.styl')
    .pipe(stylus())
    .pipe(gulp.dest('./build/css'))
    .pipe(livereload(server))

# open
# https://github.com/pwnall/node-open
gulp.task 'open', ->
  open('http://localhost:8080/')

# browserSync
# https://github.com/shakyShane/gulp-browser-sync
gulp.task 'browser-sync', ->
  browserSync.init ['build/**/*.html', 'build/**/*.css'],
    server:
      baseDir: './build'


# defalut task
gulp.task 'default', ->
  connect.createServer(
    connect.static('./build/')
  ).listen(8080)

  gulp.run 'open'

  server.listen 35729, (err) ->
    console.log(err) if (err)

    gulp.watch './source/**/*.jade', ->
      gulp.run 'jade'
    gulp.watch './source/stylus/**/*.styl', ->
      gulp.run 'stylus'
    gulp.watch './source/coffee/*.coffee', ->
      gulp.run 'coffee'
