if Meteor.isServer
    Meteor.publish 'model_from_child_id', (child_id)->
        child = Docs.findOne child_id
        Docs.find
            model:'model'
            slug:child.type


    Meteor.publish 'model_fields_from_child_id', (child_id)->
        child = Docs.findOne child_id
        model = Docs.findOne
            model:'model'
            slug:child.type
        Docs.find
            model:'field'
            parent_id:model._id
