contract    = require './src/serviceContract'
HoSCom      = require 'hos-com'

controller = require('./src/controller')(HoSCom, contract)
module.exports = controller
