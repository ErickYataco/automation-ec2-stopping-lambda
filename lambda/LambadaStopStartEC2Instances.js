const AWS = require('aws-sdk')
const EC2 = new AWS.EC2()

exports.handler = async (event, context) => {

    var instances   =[]
    var regions     =[]

    try {

        var hour = new Date(new Date().toLocaleString("en-US", {timeZone:process.env.TIME_ZONE})).getHours()

        regions = await EC2.describeRegions().promise()
        var region, stateInstance

        for (region of regions.Regions){
            var ec2 = new AWS.EC2({region: region.RegionName})
            
            if (hour == '12'){
                stateInstance = 'running'
            }

            if (hour == '7'){
                stateInstance = 'stopped'
            }

            var params = {
                Filters:[{
                    Name: 'instance-state-name',
                    Values: [
                        stateInstance,
                    ]
                }]
            }
    
            instances = await ec2.describeInstances(params).promise()
            var instance, result, ids = []

            if (instances.Reservations.length>0){
                for ( instance of instances.Reservations[0].Instances) {
                    ids.push(instance.InstanceId)  
                }
                console.log('ids ',ids)  
                
                if ( hour == '7'){
                    result = await ec2.startInstances({InstanceIds: ids}).promise()
                    console.log('stoped ',result)  
                }
                if (hour == '12'){
                    result = await ec2.stopInstances({InstanceIds: ids}).promise()
                    console.log('stoped ',result)  
                }

            }
    
        }

        return true
        

    } catch (error) {

        console.log('error: ',error)
        return false

    }

}