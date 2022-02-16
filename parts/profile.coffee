if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'

    
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_models', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'staff_resident_widget'


    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000





    Template.profile.helpers
        current_user: ->
            Meteor.users.findOne username:Router.current().params.username

        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.profile.events
        'click .checkin': ->
            Meteor.users.update Meteor.userId(),
                $set:checked_in:true
            Docs.insert 
                model:'checkin'
                active:true
        
        
        'click .checkout': ->
            Meteor.users.update Meteor.userId(),
                $set:checked_in:false
            active_session_doc = 
                Docs.findOne 
                    model:'checkin'
                    active:true
                    
            if active_session_doc
                Docs.update active_session_doc._id,
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
                

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Meteor.logout()
            Router.go '/login'



    Template.user_healthclub.events
        'click .generate_barcode': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.healthclub_code
                JsBarcode("#barcode", current_user.healthclub_code);
            else
                alert 'No healthclub code'



    Template.user_array_element_toggle.helpers
        user_array_element_toggle_class: ->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"] and @value in @user["#{@key}"] then 'black' else 'basic'
    Template.user_array_element_toggle.events
        'click .toggle_element': (e,t)->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"]
                if @value in @user["#{@key}"]
                    Meteor.users.update @user._id,
                        $pull: "#{@key}":@value
                else
                    Meteor.users.update @user._id,
                        $addToSet: "#{@key}":@value
            else
                Meteor.users.update @user._id,
                    $addToSet: "#{@key}":@value


    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users



    Template.user_array_list.onCreated ->
        @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users




    Template.user_violations.onCreated ->
        @autorun => Meteor.subscribe 'violations', Router.current().params.username
        @editing_violation = new ReactiveVar null
    Template.user_violations.helpers
        violations: ->
            Docs.find
                model:'violation'

        editing_violation: ->
            Template.instance().editing_violation.get()

        editing_violation_doc: ->
            Docs.findOne Template.instance().editing_violation.get()

    Template.user_violations.events
        'click .add_inline_violation': ->
            new_violation_id = Docs.insert
                model:'violation'
                username: Router.current().params.username
            Template.instance().editing_violation.set new_violation_id

        'click .edit_violation': ->
            Template.instance().editing_violation.set @_id

        'click .save_violation': ->
            Template.instance().editing_violation.set null




    Template.user_unit.onCreated ->
        @autorun => Meteor.subscribe 'user_unit', Router.current().params.username
    Template.user_unit.helpers
        unit: ->
            Docs.findOne
                model:'unit'


    # Template.user_unit.onCreated ->
    #     @autorun => Meteor.subscribe 'user_unit', Router.current().params.username
    Template.user_permit.helpers
        permit_doc: ->
            Docs.findOne
                model:'parking_permit'


    Template.user_guests.onCreated ->
        @autorun => Meteor.subscribe 'user_guests', Router.current().params.username
    Template.user_guests.helpers
        guests: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'guest'
                _id:$in:user.guest_ids





    Template.user_checkins.onCreated ->
        @autorun => Meteor.subscribe 'checkins', Router.current().params.username
    Template.user_checkins.helpers
        checkins: ->
            Docs.find
                model:'checkin'
                resident_username:Router.current().params.username




    Template.user_log.onCreated ->
        @autorun => Meteor.subscribe 'user_log', Router.current().params.username
    Template.user_log.helpers
        user_log_events: ->
            Docs.find {
                model:'log_event'
            }, sort:_timestamp:-1


    Template.membership_status.events
        'click .email_rules_receipt': ->
            Meteor.call 'send_rules_regs_receipt_email', @_id


    Template.staff_verification.events
        'click .verify': ->
            if confirm 'verify user government id?'
                current_user = Meteor.users.findOne username:Router.current().params.username
                Meteor.users.update current_user._id,
                    $set:
                        staff_verifier:Meteor.user().username
                        verification_timestamp:Date.now()

        'click .rerun_check': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'staff_government_id_check', current_user




if Meteor.isServer
    Meteor.publish 'checkins', (username)->
        Docs.find
            model:'checkin'
            resident_username:username


    Meteor.publish 'user_unit', (username)->
        user = Meteor.users.findOne username:username
        if user.unit_number
            Docs.find
                model:'unit'
                building_code:user.building_code
                unit_number:user.unit_number


    Meteor.publish 'user_bookmarks', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            bookmark_ids:$in:[user._id]


    Meteor.publish 'violations', (username)->
        Docs.find
            model:'violation'
            username:username

    Meteor.publish 'user_confirmed_transactions', (username)->
        Docs.find
            model:'karma_transaction'
            recipient:username
            # confirmed:true


    Meteor.publish 'user_guests', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'guest'
            _id:$in:user.guest_ids


    Meteor.publish 'user_log', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'log_event'
            object_id:user._id


    Meteor.publish 'user_referenced_docs', (username)->
        Docs.find
            resident:username
