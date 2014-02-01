'use strict'

# require

gulp        = require 'gulp'
gulpif      = require 'gulp-if'
gutil       = require 'gulp-util'
jade        = require 'gulp-jade'
sass        = require 'gulp-sass'
clean       = require 'gulp-clean'
newer       = require 'gulp-newer'
notify      = require 'gulp-notify'
stylus      = require 'gulp-stylus'
coffee      = require 'gulp-coffee'
concat      = require 'gulp-concat'
embedlr     = require 'gulp-embedlr'
imagemin    = require 'gulp-imagemin'
livereload  = require 'gulp-livereload'
fs          = require 'fs'
open        = require 'open'
connect     = require 'connect'
yaml        = require 'js-yaml'
lr          = require 'tiny-lr'
browserSync = require 'browser-sync'
server      = lr()

# confing

SERVERPORT = '8080'
LIVERELOADPORT = '35729'

jade_src = [
  './source/**/*.jade'
  '!./source/layout/**/*.jade'
  '!./source/include/**/*.jade'
]

# task

# initial task
gulp.task 'init', ['concat'], ->
  gulp.src './source/**/*.jade'
    .pipe gulp.dest './tmp'
  gulp.start 'jade'

# clean
# https://github.com/peter-vilja/gulp-clean
gulp.task 'clean', ->
  gulp.src ['./data', './build', './tmp'], read: false
    .pipe clean()

# concat
# https://github.com/wearefractal/gulp-concat
gulp.task 'concat', ->
  gulp.src './source/data/**/*.yml'
    .pipe newer './data/all.yml'
    .pipe concat 'all.yml'
    .pipe gulp.dest './data'
    .pipe notify 
      title: 'Concat task complete'
      message: '<%= file.relative %>'

# jade
# https://github.com/phated/gulp-jade
gulp.task 'jade', ->
  contents = yaml.safeLoad fs.readFileSync './data/all.yml', 'utf-8'
  gulp.src jade_src
    .pipe newer './tmp'
    .pipe gulp.dest './tmp'
    .pipe jade
      pretty: true
      data: contents
    .pipe gulpif gutil.env.dev, embedlr()
    .pipe gulp.dest './build'
    .pipe livereload server
    .pipe notify 
      title: 'Jade task complete'
      message: '<%= file.relative %>'

# coffee
# https://github.com/wearefractal/gulp-coffee
gulp.task 'coffee', ->
  gulp.src './source/coffee/**/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './build/js'
    .pipe livereload server
    .pipe notify 
      title: 'Coffee task complete'
      message: '<%= file.relative %>'

# stylus
# https://github.com/stevelacy/gulp-stylus
gulp.task 'stylus', ->
  gulp.src './source/stylus/style.styl'
    .pipe stylus use: ['nib']
    .pipe gulp.dest './build/css'
    .pipe livereload server
    .pipe notify 
      title: 'Stylus task complete'
      message: '<%= file.relative %>'

# sass
# https://github.com/dlmanning/gulp-sass
gulp.task 'sass', ->
  gulp.src './source/sass/**/*.scss'
    .pipe sass
      outputStyle: 'expanded'
      imagePath: 'image/'
    .pipe gulp.dest './build/css'
    .pipe livereload server
    .pipe notify 
      title: 'Sass task complete'
      message: '<%= file.relative %>'

# imagemin
# https://github.com/sindresorhus/gulp-imagemin
gulp.task 'imagemin', ->
  gulp.src './source/image/**/*'
    .pipe newer './build/image/**/*'
    .pipe imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest './build/image'
    .pipe notify 
      title: 'Imagemin task complete'
      message: '<%= file.relative %>'

# connect
# https://github.com/senchalabs/connect
gulp.task 'connect', ->
  connect.createServer(
    connect.static './build/'
  ).listen SERVERPORT
  livereload server
  # open 'http://localhost:' + SERVERPORT

# browserSync
# https://github.com/shakyShane/gulp-browser-sync
gulp.task 'browser-sync', ->
  browserSync.init ['./build/**/*.html', './build/**/*.css'],
    server:
      baseDir: './build'

# defalut task

gulp.task 'default', ['init'], ->
  gulp.start 'connect'
  server.listen LIVERELOADPORT, (err) ->
    console.log err if (err)

    gulp.watch './source/**/*.jade', ['jade']
    gulp.watch './source/data/**/*.yml', ['concat']
    gulp.watch './source/stylus/**/*.styl', ['stylus']
    # gulp.watch './source/sass/**/*.scss', ['sass']
    gulp.watch './source/coffee/*.coffee', ['coffee']

gulp.task 'i', ['imagemin']
gulp.task 's', ['browser-sync']
gulp.task 'c', ['clean']
