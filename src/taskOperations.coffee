HoSQueues = require 'hos-queues'
SwaggerMerge = require 'swagger-merge'
Promise = require 'bluebird'

totalNumberOfInstances = (services)->
    totalNum = 0
    for serviceName in Object.keys(services)
        for service in services[serviceName].instances
            totalNum = totalNum + 1
    return totalNum

getSwaggers = (msg, hos, services)->
    new Promise (fullfil, reject)->
        swaggers = []
        counter = 0
        totalNum = totalNumberOfInstances(services)

        docFinished = ()=>
            counter = counter + 1
            if counter is totalNum
                info =
                    version: "0.0.1",
                    title: "HoS controller rout documentation",
                    description: "Documentation of all the routs and services available in HoS environment\n"

                services.doc = SwaggerMerge.merge(swaggers , info, '/', 'localhost')

                fullfil(services)

        for serviceName in Object.keys(services)
            for service in services[serviceName].instances
                if service.address is '/ctrlr.' + hos._serviceId
                    services[serviceName].instances[services[serviceName].instances.indexOf(service)].contract = hos._serviceContract
                    swaggers.push hos._serviceContract.serviceDoc
                    docFinished()
                else
                    p = hos.sendMessage({} , service.address, {task: 'contract', method: 'get'})
                    p.then (contract)=>
                        services[serviceName].instances[services[serviceName].instances.indexOf(service)].contract = contract
                        if contract.serviceDoc and contract.serviceDoc.paths
                            swaggers.push contract.serviceDoc
                        docFinished()
                    p.catch (e)=>
                        docFinished()

module.exports =
    getTasks: (msg, hos)->
        HoSQueues.now()
        .then (services)=>
            if msg.properties.headers.query and msg.properties.headers.query.docincluded and msg.properties.headers.query.docincluded is true
                getSwaggers(msg, hos, services).then (sws)=> msg.reply(sws)
            else
                msg.reply(services)
        .catch (e)=> msg.reject(e)
