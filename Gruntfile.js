/*jshint camelcase: false*/

module.exports = function (grunt) {
  'use strict';

  // load all grunt tasks
  require('time-grunt')(grunt);
  require('load-grunt-tasks')(grunt);

  // configurable paths
  var config = {
    app: 'app',
    dist: 'dist',
    tmp: 'tmp',
    resources: 'resources'
  };

  grunt.initConfig({
    config: config,
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '<%= config.dist %>/*',
            '<%= config.tmp %>/*'
          ]
        }]
      }
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      files: '<%= config.app %>/js/*.js'
    },
    copy: {
      appLinux: {
        files: [{
          expand: true,
          cwd: '<%= config.app %>',
          dest: '<%= config.dist %>/app.nw',
          src: '**'
        }]
      },
      appMacos: {
        files: [{
          expand: true,
          cwd: '<%= config.app %>',
          dest: '<%= config.dist %>/node-webkit.app/Contents/Resources/app.nw',
          src: '**'
        }, {
          expand: true,
          cwd: '<%= config.resources %>/mac/',
          dest: '<%= config.dist %>/node-webkit.app/Contents/',
          filter: 'isFile',
          src: '*.plist'
        }, {
          expand: true,
          cwd: '<%= config.resources %>/mac/',
          dest: '<%= config.dist %>/node-webkit.app/Contents/Resources/',
          filter: 'isFile',
          src: '*.icns'
        }]
      },
      webkit: {
        files: [{
          expand: true,
          cwd: '<%=config.resources %>/node-webkit/MacOS',
          dest: '<%= config.dist %>/',
          src: '**'
        }]
      },
      copyWinToTmp: {
        files: [{
          expand: true,
          cwd: '<%= config.resources %>/node-webkit/Windows/',
          dest: '<%= config.tmp %>/',
          src: '**'
        }]
      },
      copyTmpToDist: {

        files: [{
          expand: true,
          cwd: '<%= config.tmp %>',
          dest: '<%= config.dist %>/',
          src: '**'
        }]
      }
    },
    compress: {
      appToTmp: {
        options: {
          archive: '<%= config.tmp %>/app.zip'
        },
        files: [{
          expand: true,
          cwd: '<%= config.app %>',
          src: ['**']
        }]
      },
      finalWindowsApp: {
        options: {
          archive: '<%= config.dist %>/DeilduTime.zip'
        },
        files: [{
          expand: true,
          cwd: '<%= config.tmp %>',
          src: ['**']
        }]
      }
    },
    rename: {
      app: {
        files: [{
          src: '<%= config.dist %>/node-webkit.app',
          dest: '<%= config.dist %>/DeilduTime.app'
        }]
      },
      zipToApp: {
        files: [{
          src: '<%= config.tmp %>/app.zip',
          dest: '<%= config.tmp %>/app.nw'
        }]
      }
    },
    exec: {
		win: {
			cmd: '"build/cache/win/<%= nodewebkit.options.version %>/nw.exe" .'
		},
		mac: {
			cmd: 'dist/DeilduTime.app/Contents/MacOS/node-webkit .'
		},
		linux32: {
			cmd: '"build/cache/linux32/<%= nodewebkit.options.version %>/nw" .'
		},
		linux64: {
			cmd: '"build/cache/linux64/<%= nodewebkit.options.version %>/nw" .'
		},
		// createDmg: {
		// 	cmd: 'dist/mac/yoursway-create-dmg/create-dmg --volname "TorrenTV ' + currentVersion + '" --background ./dist/mac/background.png --window-size 480 540 --icon-size 128 --app-drop-link 240 370 --icon "TorrenTV" 240 110 ./build/releases/TorrenTV/mac/TorrenTV-' + currentVersion + '-Mac.dmg ./build/releases/TorrenTV/mac/'
		// },
		// createWinInstall: {
		// 	cmd: 'makensis dist/windows/installer.nsi'
		// }
	},
  });

  grunt.registerTask('chmod', 'Add lost Permissions.', function () {
    var fs = require('fs');
    fs.chmodSync('dist/DeilduTime.app/Contents/Frameworks/node-webkit Helper EH.app/Contents/MacOS/node-webkit Helper EH', '555');
    fs.chmodSync('dist/DeilduTime.app/Contents/Frameworks/node-webkit Helper NP.app/Contents/MacOS/node-webkit Helper NP', '555');
    fs.chmodSync('dist/DeilduTime.app/Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/node-webkit Helper', '555');
    fs.chmodSync('dist/DeilduTime.app/Contents/MacOS/node-webkit', '555');
  });

  grunt.registerTask('createLinuxApp', 'Create linux distribution.', function (version) {
    var done = this.async();
    var childProcess = require('child_process');
    var exec = childProcess.exec;
    exec('mkdir -p ./dist; cp resources/node-webkit/'+ version +'/nw.pak dist/ && cp resources/node-webkit/'+ version +'/nw dist/node-webkit', function (error, stdout, stderr) {
      var result = true;
      if (stdout) {
        grunt.log.write(stdout);
      }
      if (stderr) {
        grunt.log.write(stderr);
      }
      if (error !== null) {
        grunt.log.error(error);
        result = false;
      }
      done(result);
    });
  });

  grunt.registerTask('createWindowsApp', 'Create windows distribution.', function () {
    var done = this.async();
    var concat = require('concat-files');
    concat([
      'tmp/nw.exe',
      'tmp/app.nw'
    ], 'tmp/DeilduTime.exe', function () {
      var fs = require('fs');
      fs.unlink('tmp/app.nw', function (error, stdout, stderr) {
        if (stdout) {
          grunt.log.write(stdout);
        }
        if (stderr) {
          grunt.log.write(stderr);
        }
        if (error !== null) {
          grunt.log.error(error);
          done(false);
        } else {
          fs.unlink('tmp/nw.exe', function (error, stdout, stderr) {
            var result = true;
            if (stdout) {
              grunt.log.write(stdout);
            }
            if (stderr) {
              grunt.log.write(stderr);
            }
            if (error !== null) {
              grunt.log.error(error);
              result = false;
            }
            done(result);
          });
        }
      });
    });
  });

  grunt.registerTask('setVersion', 'Set version to all needed files', function (version) {
    var config = grunt.config.get(['config']);
    var appPath = config.app;
    var resourcesPath = config.resources;
    var mainPackageJSON = grunt.file.readJSON('package.json');
    var appPackageJSON = grunt.file.readJSON(appPath + '/package.json');
    var infoPlistTmp = grunt.file.read(resourcesPath + '/mac/Info.plist.tmp', {
      encoding: 'UTF8'
    });
    var infoPlist = grunt.template.process(infoPlistTmp, {
      data: {
        version: version
      }
    });
    mainPackageJSON.version = version;
    appPackageJSON.version = version;
    grunt.file.write('package.json', JSON.stringify(mainPackageJSON, null, 2), {
      encoding: 'UTF8'
    });
    grunt.file.write(appPath + '/package.json', JSON.stringify(appPackageJSON, null, 2), {
      encoding: 'UTF8'
    });
    grunt.file.write(resourcesPath + '/mac/Info.plist', infoPlist, {
      encoding: 'UTF8'
    });
  });

  grunt.registerTask('dist-linux', [
    'jshint',
    'clean:dist',
    'copy:appLinux',
    'createLinuxApp:Linux64'
  ]);

  grunt.registerTask('dist-linux32', [
    'jshint',
    'clean:dist',
    'copy:appLinux',
    'createLinuxApp:Linux32'
  ]);

  grunt.registerTask('dist-win', [
    'jshint',
    'clean:dist',
    'copy:copyWinToTmp',
    'compress:appToTmp',
    'rename:zipToApp',
    'createWindowsApp',
    'copy:copyTmpToDist'
    // 'compress:finalWindowsApp'
  ]);

  grunt.registerTask('dist-mac', [
    'jshint',
    'clean:dist',
    'copy:webkit',
    'copy:appMacos',
    'rename:app',
    'chmod'
  ]);

  grunt.registerTask('check', [
    'jshint'
  ]);

  grunt.registerTask('dmg', 'Create dmg from previously created app folder in dist.', function () {
    var done = this.async();
    var createDmgCommand = 'resources/mac/package.sh "DeilduTime"';
    require('child_process').exec(createDmgCommand, function (error, stdout, stderr) {
      var result = true;
      if (stdout) {
        grunt.log.write(stdout);
      }
      if (stderr) {
        grunt.log.write(stderr);
      }
      if (error !== null) {
        grunt.log.error(error);
        result = false;
      }
      done(result);
    });
  });

};