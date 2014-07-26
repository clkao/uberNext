#!/usr/bin/env lsc -cj
author: 'Chia-liang Kao'
name: 'ly-crx'
description: 'ly-crx'
version: '0.0.1'
homepage: 'https://github.com/g0v/ly-crx'
repository:
  type: 'git'
  url: 'https://github.com/g0v/ly-crx'
engines:
  node: '0.8.x'
  npm: '1.1.x'
scripts:
  prepublish: 'PATH=./node_modules/.bin:$PATH lsc -cj package.ls'
  build: 'gulp build'
dependencies: {}
devDependencies:
  LiveScript: '^1.2.x'
  nib: '^1.0.3'
  gulp: '^3.8.6'
  'gulp-livescript': '^1.0.3'
  'gulp-exec': '^2.1.0'
  'gulp-rename': '^1.2.0'
  'gulp-stylus': '^1.3.0'
