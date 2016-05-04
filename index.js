/* jshint node:true */
'use strict';
require('coffee-script/register');
var HoSController = require('./bootstrap');

var hosController = new HoSController()
hosController.connect()
