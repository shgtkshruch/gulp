'use strict'

# require

gulp        = require 'gulp'
$           = require('gulp-load-plugins')()
fs          = require 'fs'
open        = require 'open'
yaml        = require 'js-yaml'
browserSync = require 'browser-sync'

# confing

config = 
  SERVERPORT: '8080'

# task

# connect
# https://github.com/avevlad/gulp-connect
gulp.task 'connect', $.connect.server
  root: __dirname + '/build'
  port: config.SERVERPORT
  livereload: true
  open:
    file: 'index.html'
    browser: 'chrome'

# concat
# https://github.com/wearefractal/gulp-concat
gulp.task 'concat', ->
  gulp.src './source/data/**/*.yml'
    .pipe $.newer './data/all.yml'
    .pipe $.concat 'all.yml'
    .pipe gulp.dest './data'
    .pipe $.notify 
      title: 'Concat task complete'
      message: '<%= file.relative %>'

# clean
# https://github.com/peter-vilja/gulp-clean
gulp.task 'clean', ->
  gulp.src ['./data', './tmp'], read: false
    .pipe $.clean()
    .pipe $.notify 
      title: 'Clean task complete'
      message: '<%= file.relative %>'

# jade
# https://github.com/phated/gulp-jade
gulp.task 'jade', ->
  contents = yaml.safeLoad fs.readFileSync './data/all.yml', 'utf-8'
  gulp.src './source/**/*.jade'
    .pipe $.newer './tmp'
    .pipe gulp.dest './tmp'
    .pipe $.filter '!layout/**'
    .pipe $.jade
      pretty: true
      data: contents
    .pipe gulp.dest './build'
    .pipe $.connect.reload()
    .pipe $.notify 
      title: 'Jade task complete'
      message: '<%= file.relative %>'

# coffee
# https://github.com/wearefractal/gulp-coffee
gulp.task 'coffee', ->
  gulp.src './source/coffee/**/*.coffee'
    .pipe $.coffee()
    .pipe gulp.dest './build/js'
    .pipe $.connect.reload()
    .pipe $.notify 
      title: 'Coffee task complete'
      message: '<%= file.relative %>'

# stylus
# https://github.com/stevelacy/gulp-stylus
gulp.task 'stylus', ->
  gulp.src './source/stylus/style.styl'
    .pipe $.stylus use: ['nib']
    .pipe gulp.dest './build/css'
    .pipe $.connect.reload()
    .pipe $.notify 
      title: 'Stylus task complete'
      message: '<%= file.relative %>'

# sass
# https://github.com/dlmanning/gulp-sass
gulp.task 'sass', ->
  gulp.src './source/sass/**/*.scss'
    .pipe $.sass
      outputStyle: 'expanded'
      imagePath: 'image/'
    .pipe gulp.dest './build/css'
    .pipe $.connect.reload()
    .pipe $.notify 
      title: 'Sass task complete'
      message: '<%= file.relative %>'

# imagemin
# https://github.com/sindresorhus/gulp-imagemin
gulp.task 'imagemin', ->
  gulp.src './source/image/**/*'
    .pipe $.newer './build/image/**/*'
    .pipe $.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest './build/image'
    .pipe $.connect.reload()
    .pipe $.notify 
      title: 'Imagemin task complete'
      message: '<%= file.relative %>'

# browserSync
# https://github.com/shakyShane/gulp-browser-sync
gulp.task 'browser-sync', ->
  browserSync.init ['./build/**/*.html', './build/**/*.css'],
    server:
      baseDir: './build'

# defalut task

gulp.task 'default', ['connect'], ->
  gulp.watch './source/**/*.jade', ['jade']
  gulp.watch './source/data/**/*.yml', ['concat']
  gulp.watch './source/stylus/**/*.styl', ['stylus']
  # gulp.watch './source/sass/**/*.scss', ['sass']
  gulp.watch './source/coffee/*.coffee', ['coffee']
  gulp.watch './source/image/**/*', ['imagemin']

gulp.task 'i', ->
  gulp.src './source/**/*.jade'
    .pipe gulp.dest './tmp'
  gulp.start 'connect'
  open 'http://localhost:' + config.SERVERPORT

gulp.task 's', ['browser-sync']

gulp.task 'c', ['clean']
