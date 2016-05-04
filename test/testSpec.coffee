Promise         = require 'bluebird'
HosCom          = require 'hos-com'
HoSAuth         = require 'hos-auth'
crypto          = require 'crypto'
HoSController   = require '../bootstrap'
generalContract = require './serviceContract'
rp              = require 'request-promise'

amqpurl     = process.env.AMQP_URL ? "localhost"
username    = process.env.AMQP_USERNAME ? "guest"
password    = process.env.AMQP_PASSWORD ? "guest"

describe "Check basic operations", ()->
    beforeEach ()->
        @hosController = new HoSController()

        @serviceCon = JSON.parse(JSON.stringify(generalContract))
        @serviceCon.serviceDoc.basePath = "serviceTest#{crypto.randomBytes(4).toString('hex')}"
        @serviceRequester = new HosCom @serviceCon, amqpurl, username, password

        @hosAuth = new HoSAuth(amqpurl, username, password)

    afterEach ()->
        @hosController.destroy()
        @serviceRequester.destroy()
        @hosAuth.destroy()

    it "and it should get services and instances name", (done)->
        promisses = []
        promisses.push @hosAuth.connect()
        promisses.push @hosController.connect()
        promisses.push @serviceRequester.connect()

        Promise.all(promisses).then ()=>
            @serviceRequester.sendMessage({foo: "bar"} , '/ctrlr', {task: '/tasks', method: 'get'})
            .then (replyPayload)=>
                done()
            .catch (e)=>
                console.log e

        @hosAuth.on 'message', (msg)=>
            msg.accept()

    it "and it should get services and instances name plus their docs", (done)->
        promisses = []
        promisses.push @hosAuth.connect()
        promisses.push @hosController.connect()
        promisses.push @serviceRequester.connect()

        Promise.all(promisses).then ()=>
            @serviceRequester.sendMessage({foo: "bar"} , '/ctrlr', {task: '/tasks', method: 'get', query: {docincluded: true}})
            .then (replyPayload)=>
                done()
            .catch (e)=>
                console.log e

        @hosAuth.on 'message', (msg)=>
            msg.accept()
