amqpurl         = process.env.AMQP_URL ? "localhost"
amqpusername    = process.env.AMQP_USERNAME ? "guest"
amqppassword    = process.env.AMQP_PASSWORD ? "guest"
taskOperations  = require('./taskOperations')

module.exports = (HoSCom, contract)->
    class ZettaboxAdmin
        hos = null
        constructor: ()->
            @hos = new HoSCom contract, amqpurl, amqpusername, amqppassword
            @hos.on '/tasks.get', (msg)=>
                taskOperations.getTasks(msg, @hos)

        connect: ()->
            promisses = []
            promisses.push @hos.connect()
            Promise.all promisses

        destroy: ()->
            @hos.destroy()
