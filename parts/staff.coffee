if Meteor.isClient
    Template.staff.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000

    Template.staff.onCreated ->
        # @autorun => Meteor.subscribe 'todays_checklist', ->
        @autorun => Meteor.subscribe 'sessions', ->
        # @autorun => Meteor.subscribe 'shift_walks', 


    Template.staff.helpers
        old_session_docs: ->
            Docs.find 
                model:'checkin'
                
        active_sessions: ->
            Docs.find
                model:'checkin'
                active:true


    Template.staff.events
        'click .add_resident': ->
            new_id = 
                Docs.insert 
                    model:'resident'
            Router.go "/resident/#{new_id}/edit"
            


    Template.session_card.onCreated ->
        # @autorun => Meteor.subscribe 'user_by_username', @data.resident_username
        console.log @
        @autorun => Meteor.subscribe 'doc', Session.get('session_resident_id')
        @autorun => Meteor.subscribe 'session_guests', @data
    Template.session_card.helpers
        icon_class: ->
            switch @session_type
                when 'checkin' then 'treadmill'
                when 'garden_key_checkout' then 'basketball'
                when 'unit_key_checkout' then 'key'

        session_resident: ->
            # Meteor.users.findOne
            #     username:@resident_username
            Docs.findOne 
                model:'resident'
                _id: Session.get('session_resident_id')


        checkin_guest_docs: () ->
            Docs.find
                _id:$in:@guest_ids

    Template.session_card.events
        'click .sign_out': (e,t)->
            # resident = Meteor.users.findOne
            #     username:@resident_username
            #
            # console.log @
            # if confirm "Check Out #{@first_name} #{@last_name}?"
            $(e.currentTarget).closest('.card').transition('fade up',500)
            Meteor.setTimeout =>
                Docs.update @_id,
                    $set: active: false
            , 500


if Meteor.isServer
    Meteor.methods
        lookup_key: (building_number, unit_number)->
            found_key = Docs.findOne
                model:'key'
                building_number:building_number
                unit_number:unit_number

    Meteor.publish 'sessions', ->
        Docs.find
            model:'checkin'
            # model:$in:['checkin','garden_key_checkout','unit_key_checkout']
            active:true

    Meteor.publish 'old_sessions', ->
        Docs.find
            model:'checkin'
            # model:$in:['checkin','garden_key_checkout','unit_key_checkout']
            active:$ne:true


    Meteor.publish 'session_guests', (session_data)->
        if session_data
            Docs.find
                _id:$in:session_data.guest_ids
