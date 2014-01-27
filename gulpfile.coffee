'use strict'

# require
gulp        = require('gulp')
fs          = require('fs')
yaml        = require('js-yaml')
gutil       = require('gulp-util')
concat      = require('gulp-concat')
jade        = require('gulp-jade')
stylus      = require('gulp-stylus')
coffee      = require('gulp-coffee')
livereload  = require('gulp-livereload')
lr          = require('tiny-lr')
server      = lr()
open        = require('open')
connect     = require('connect')
browserSync = require('browser-sync')

# task

# concat
# https://github.com/wearefractal/gulp-concat
gulp.task 'concat', ->
  gulp.src('./source/data/**/*.yml')
    .pipe(concat('all.yml'))
    .pipe(gulp.dest('./data'))

# jade
# https://github.com/phated/gulp-jade
gulp.task 'jade', ->
  config = yaml.safeLoad(fs.readFileSync('./data/all.yml', 'utf-8'))
  gulp.src('./source/**/*.jade')
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

# connect
# https://github.com/senchalabs/connect
gulp.task 'connect', ->
  connect.createServer(
    connect.static('./build/')
  ).listen(8080)

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

# livereload
# https://github.com/vohof/gulp-livereload
gulp.task 'livereload', ->
  server.listen 35729, (err) ->
    console.log(err) if (err)

    gulp.watch './source/**/*.jade', ['jade']
    gulp.watch './data/all.yml', ['jade']
    gulp.watch './source/data/**/*.yml', ['concat']
    gulp.watch './source/stylus/**/*.styl', ['stylus']
    gulp.watch './source/coffee/*.coffee', ['coffee']

# defalut task
gulp.task 'default', ['connect', 'open', 'livereload']
