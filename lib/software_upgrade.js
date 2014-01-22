// Generated by IcedCoffeeScript 1.6.3-j
(function() {
  var FileBundle, SoftwareUpgrade, fs, iced, log, make_esc, npm, path, __iced_k, __iced_k_noop;

  iced = require('iced-coffee-script/lib/coffee-script/iced').runtime;
  __iced_k = __iced_k_noop = function() {};

  make_esc = require('iced-error').make_esc;

  npm = require('./npm').npm;

  path = require('path');

  fs = require('fs');

  log = require('./log');

  FileBundle = (function() {
    function FileBundle(uri, body) {
      this.uri = uri;
      this.body = body;
    }

    FileBundle.prototype.filename = function() {
      return path.basename(this.uri.path);
    };

    FileBundle.prototype.fullpath = function() {
      return this._fullpath;
    };

    FileBundle.prototype.write = function(dir, encoding, cb) {
      var err, p, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      p = this._fullpath = path.join(dir, this.filename());
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "FileBundle.write"
          });
          fs.writeFile(p, _this.body, {
            mode: 0x100,
            encoding: encoding
          }, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return err = arguments[0];
              };
            })(),
            lineno: 21
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          return cb(err);
        };
      })(this));
    };

    return FileBundle;

  })();

  exports.SoftwareUpgrade = SoftwareUpgrade = (function() {
    function SoftwareUpgrade(config) {
      this.config = config;
    }

    SoftwareUpgrade.prototype.fetch = function(file, cb) {
      var body, err, req, ret, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.fetch"
          });
          _this.config.request(file, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                err = arguments[0];
                req = arguments[1];
                return body = arguments[2];
              };
            })(),
            lineno: 35
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          if (typeof err === "undefined" || err === null) {
            ret = new FileBundle(req.request.uri, body);
          }
          return cb(err, ret);
        };
      })(this));
    };

    SoftwareUpgrade.prototype.fetch_package = function(cb) {
      var err, file, ___iced_passed_deferral, __iced_deferrals, __iced_k, _ref;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      file = ["dist", ((_ref = this.config.argv.get()) != null ? _ref[0] : void 0) || "latest-stable"].join('/');
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.fetch_package"
          });
          _this.fetch(file, __iced_deferrals.defer({
            assign_fn: (function(__slot_1) {
              return function() {
                err = arguments[0];
                return __slot_1["package"] = arguments[1];
              };
            })(_this),
            lineno: 43
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          return cb(err);
        };
      })(this));
    };

    SoftwareUpgrade.prototype.fetch_signature = function(cb) {
      var err, file, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      file = "/" + (this.config.key_version()) + "/" + (this["package"].filename()) + ".asc";
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.fetch_signature"
          });
          _this.fetch(file, __iced_deferrals.defer({
            assign_fn: (function(__slot_1) {
              return function() {
                err = arguments[0];
                return __slot_1.signature = arguments[1];
              };
            })(_this),
            lineno: 50
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          return cb(err);
        };
      })(this));
    };

    SoftwareUpgrade.prototype.write_files = function(cb) {
      var esc, tmpdir, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      esc = make_esc(cb, "SoftwareUpgrade::write_files");
      tmpdir = this.config.get_tmpdir();
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.write_files"
          });
          _this["package"].write(tmpdir, 'binary', esc(__iced_deferrals.defer({
            lineno: 58
          })));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
              funcname: "SoftwareUpgrade.write_files"
            });
            _this.signature.write(tmpdir, 'utf8', esc(__iced_deferrals.defer({
              lineno: 59
            })));
            __iced_deferrals._fulfill();
          })(function() {
            return cb(null);
          });
        };
      })(this));
    };

    SoftwareUpgrade.prototype.verify_signature = function(cb) {
      var args, err, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      args = {
        which: 'code',
        sig: this.signature.fullpath(),
        file: this["package"].fullpath()
      };
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.verify_signature"
          });
          _this.config.oneshot_verify(args, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return err = arguments[0];
              };
            })(),
            lineno: 69
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          return cb(err);
        };
      })(this));
    };

    SoftwareUpgrade.prototype.install_package = function(cb) {
      var args, err, p, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      p = this["package"].fullpath();
      log.debug("| Full name for install: " + p);
      log.info("Running npm install " + (this["package"].filename()) + ": this may take a minute, please be patient");
      args = ["install", "-g", p];
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.install_package"
          });
          npm({
            args: args
          }, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return err = arguments[0];
              };
            })(),
            lineno: 79
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          return cb(err);
        };
      })(this));
    };

    SoftwareUpgrade.prototype.run = function(cb) {
      var esc, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      esc = make_esc(cb, "SoftwareUpgrade::run");
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
            funcname: "SoftwareUpgrade.run"
          });
          _this.fetch_package(esc(__iced_deferrals.defer({
            lineno: 86
          })));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
              funcname: "SoftwareUpgrade.run"
            });
            _this.fetch_signature(esc(__iced_deferrals.defer({
              lineno: 87
            })));
            __iced_deferrals._fulfill();
          })(function() {
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
                funcname: "SoftwareUpgrade.run"
              });
              _this.write_files(esc(__iced_deferrals.defer({
                lineno: 88
              })));
              __iced_deferrals._fulfill();
            })(function() {
              (function(__iced_k) {
                __iced_deferrals = new iced.Deferrals(__iced_k, {
                  parent: ___iced_passed_deferral,
                  filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
                  funcname: "SoftwareUpgrade.run"
                });
                _this.verify_signature(esc(__iced_deferrals.defer({
                  lineno: 89
                })));
                __iced_deferrals._fulfill();
              })(function() {
                (function(__iced_k) {
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral,
                    filename: "/Users/max/src/keybase-node-installer/src/software_upgrade.iced",
                    funcname: "SoftwareUpgrade.run"
                  });
                  _this.install_package(esc(__iced_deferrals.defer({
                    lineno: 90
                  })));
                  __iced_deferrals._fulfill();
                })(function() {
                  return cb(null);
                });
              });
            });
          });
        };
      })(this));
    };

    return SoftwareUpgrade;

  })();

}).call(this);