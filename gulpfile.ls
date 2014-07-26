require! <[gulp gulp-livescript gulp-exec gulp-rename gulp-stylus gulp-jade]>

gulp.task 'livescript' ->
  gulp.src './src/**/*.ls'
    .pipe gulp-livescript!
    .pipe gulp.dest './dist'

gulp.task 'assets' ->
  gulp.src './assets/**'
    .pipe gulp.dest './dist'

gulp.task 'css' ->
  gulp.src './src/**/*.styl'
    .pipe gulp-stylus use: [require('nib')!]
    .pipe gulp.dest './dist'

gulp.task 'jade' ->
  gulp.src './src/**/*.jade'
    .pipe gulp-jade!
    .pipe gulp.dest './dist'

gulp.task 'json' ->
  gulp.src './manifest.json.ls'
    .pipe gulp-exec 'lsc -cj < <%= file.path %>', {+pipeStdout}
    .pipe gulp-rename 'manifest.json'
    .pipe gulp.dest './dist'

gulp.task 'build' <[json css livescript jade assets]> (cb) ->
  {exec} = require 'child_process'
  err, stdout, stderr <- exec 'cd dist; zip -r ../uberNext.zip *'
  console.log stdout
  console.log stderr
  cb err
