if Meteor.isClient
    Template.manager.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift_walk'
        @autorun => Meteor.subscribe 'model_docs', 'unit_key_access', 20
        @autorun => Meteor.subscribe 'last_days_sessions'
    Template.manager.helpers
        'shift_walks': ->
            Docs.find {
                model:'shift_walk'
            }, sort:_timestamp:-1
        'key_checkouts': ->
            Docs.find {
                model:'unit_key_access'
            }, sort:_timestamp:-1
        'check_ins': ->
            Docs.find {
                model:'checkin'
            }, sort:_timestamp:-1

    Template.checkin_list_item.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', @data.resident_username
    Template.checkin_list_item.helpers
        resident: () ->
            Meteor.users.findOne username:@resident_username

if Meteor.isServer
    Meteor.publish 'last_days_sessions', ->
        # this_moment = moment(Date.now())
        # console.log this_moment.subtract(20, 'hours')
        hours = 1000*60*60*24
        now = Date.now()
        start_window = now-hours
        console.log start_window
        Docs.find
            model:'checkin'
            # _author_id:Meteor.userId()
            _timestamp:$gt:start_window
