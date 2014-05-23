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
  SOURCE: '../source'
  BUILD: '../build'
  DATA: '../data'

source =
  jade: config.SOURCE + '/**/*.jade'
  stylus: config.SOURCE + '/**/*.styl'
  sass: config.SOURCE + '/**/*.scss'
  coffee: config.SOURCE + '/**/*.coffee'
  yaml: config.SOURCE + '/**/*.yml'
  image: config.SOURCE + '/**/*.{png, jpg, gif}'

# task

# connect
# https://github.com/avevlad/gulp-connect
gulp.task 'connect', -> 
  $.connect.server
    root: config.BUILD
    port: config.SERVERPORT
    livereload: true
    # open:
    #   file: 'index.html'
    #   browser: 'chrome'

# concat
# https://github.com/wearefractal/gulp-concat
gulp.task 'concat', ->
  gulp.src source.yaml
    .pipe $.concat 'all.yml'
    .pipe gulp.dest config.DATA
    .pipe $.notify
      title: 'Concat task complete'
      message: '<%= file.relative %>'

# clean
# https://github.com/peter-vilja/gulp-clean
gulp.task 'clean', ->
  gulp.src ['./data'], read: false
    .pipe $.clean()
    .pipe $.notify
      title: 'Clean task complete'
      message: '<%= file.relative %>'

# jade
# https://github.com/phated/gulp-jade
gulp.task 'jade', ->
  # contents = yaml.safeLoad fs.readFileSync config.DATA + '/all.yml', 'utf-8'
  gulp.src source.jade
    .pipe $.filter '!layout/**'
    .pipe $.changed config.BUILD,
      extension: '.html'
    .pipe $.jade
      pretty: true
      # data: contents
    .pipe gulp.dest config.BUILD
    .pipe $.connect.reload()
    .pipe $.notify
      title: 'Jade task complete'
      message: '<%= file.relative %>'

# coffee
# https://github.com/wearefractal/gulp-coffee
gulp.task 'coffee', ->
  gulp.src source.coffee
    .pipe $.changed config.BUILD,
      extension: '.js'
    .pipe $.coffee()
    .pipe gulp.dest config.BUILD
    .pipe $.connect.reload()
    .pipe $.notify
      title: 'Coffee task complete'
      message: '<%= file.relative %>'

# stylus
# https://github.com/stevelacy/gulp-stylus
gulp.task 'stylus', ->
  gulp.src source.stylus
    .pipe $.filter '**/style.styl'
    .pipe $.changed config.BUILD + '/css',
      extension: '.css'
    .pipe $.stylus use: ['nib']
    .pipe gulp.dest config.BUILD
    .pipe $.connect.reload()
    .pipe $.notify
      title: 'Stylus task complete'
      message: '<%= file.relative %>'

# sass
# https://github.com/sindresorhus/gulp-ruby-sass
gulp.task 'sass', ->
  gulp.src source.sass
    .pipe $.filter '**/style.scss'
    .pipe $.changed config.BUILD + '/css',
      extension: '.css'
    .pipe $.rubySass
      sourcemap: true
      style: 'expanded'
    .pipe gulp.dest config.BUILD
    .pipe $.connect.reload()
    .pipe $.notify
      title: 'Sass task complete'
      message: '<%= file.relative %>'

# imagemin
# https://github.com/sindresorhus/gulp-imagemin
gulp.task 'imagemin', ->
  gulp.src source.image
    .pipe $.changed config.BUILD
    .pipe $.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest config.BUILD
    .pipe $.connect.reload()
    .pipe $.notify
      title: 'Imagemin task complete'
      message: '<%= file.relative %>'

# browserSync
# https://github.com/shakyShane/gulp-browser-sync
gulp.task 'browser-sync', ->
  browserSync.init ['./build/**/*.html', './build/**/*.css'],
    server:
      baseDir: config.BUILD

# defalut task

gulp.task 'default', ['connect'], ->
  gulp.watch source.jade, ['jade']
  gulp.watch source.yaml, ['concat']
  gulp.watch source.stylus, ['stylus']
  gulp.watch source.sass, ['sass']
  gulp.watch source.coffee, ['coffee']

gulp.task 'i', ['concat'], ->
  gulp.start 'connect'
  open 'http://localhost:' + config.SERVERPORT

gulp.task 's', ['browser-sync']

gulp.task 'c', ['clean']
