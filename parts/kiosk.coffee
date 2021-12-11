if Meteor.isClient
    Template.kiosk_settings.onCreated ->
        @autorun -> Meteor.subscribe 'kiosk_document'

    Template.kiosk_container.onCreated ->
        @autorun -> Meteor.subscribe 'kiosk_document'

    Template.kiosk_settings.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 3000

    Template.set_kiosk_template.events
        'click .set_kiosk_template': ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            Docs.update kiosk_doc._id,
                $set:kiosk_view:@value





    Template.kiosk_settings.events
        'click .create_kiosk': (e,t)->
            Docs.insert
                model:'kiosk'

        'click .print_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            console.log kiosk

        'click .delete_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk
                if confirm "delete  #{kiosk._id}?"
                    Docs.remove kiosk._id

    Template.kiosk_settings.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view

    Template.kiosk_container.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view


    Template.healthclub_session.onCreated ->
        @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
        @autorun => Meteor.subscribe 'checkin_guests',Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'resident_from_healthclub_session', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'healthclub_session', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'model_docs', 'guest'

        # @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    Template.healthclub_session.onRendered ->
        # @timer = new ReactiveVar 5
        Session.set 'timer',5
        Session.set 'timer_engaged', false
        # Meteor.setTimeout ->
        #     healthclub_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     if healthclub_session_document and healthclub_session_document.user_id
        #         resident = Meteor.users.findOne healthclub_session_document.user_id
        #         # if resident.user_id
        #         rules_found = Docs.findOne
        #             model:'rules_and_regs_signing'
        #             resident:resident.username
        #         if resident.rules_and_regulations_signed and resident.member_waiver_signed
        #             Session.set 'timer_engaged', true
        #             interval_id = Meteor.setInterval( ->
        #                 if Session.equals 'timer_engaged', true
        #                     if Session.equals 'timer', 0
        #                         Meteor.call 'submit_checkin'
        #                         Meteor.clearInterval interval_id
        #                     else
        #                         Session.set('timer', Session.get('timer')-1)
        #                 # t.timer.set(t.timer.get()-1)
        #             ,1000)
        # , 4000


    Template.healthclub_session.events
        'click .cancel_checkin': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            if healthclub_session_document
                Docs.remove healthclub_session_document._id
            if healthclub_session_document and healthclub_session_document.user_id
                Meteor.users.update healthclub_session_document.user_id,
                    $inc:
                        checkins_without_email_verification:-1
                        checkins_without_gov_id:-1


            Router.go "/healthclub"

        # 'click .recheck_photo': ->
        #     healthclub_session_document = Docs.findOne Router.current().params.doc_id
        #     if healthclub_session_document and healthclub_session_document.user_id
        #         user = Meteor.users.findOne healthclub_session_document.user_id
        #         Meteor.call 'image_check', user
        #         Meteor.call 'staff_government_id_check', user
        #
        #
        #
        # 'click .recheck': ->
        #     console.log @
        #     Meteor.call 'run_user_checks', @
        #     Meteor.call 'member_waiver_signed', @
        #     Meteor.call 'rules_and_regulations_signed', @

        'click .add_guest': ->
            # console.log @
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_guest_id =
                Docs.insert
                    model:'guest'
                    session_id: healthclub_session_document._id
                    resident_id: healthclub_session_document.user_id
                    resident: healthclub_session_document.resident_username
            # Session.set 'displaying_profile', null
            #
            Router.go "/add_guest/#{new_guest_id}"

        'click .sign_rules': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'rules_and_regs_signing'
                session_id: healthclub_session_document._id
                resident_id: healthclub_session_document.user_id
                resident: healthclub_session_document.resident_username
            Router.go "/sign_rules/#{new_id}/#{healthclub_session_document.resident_username}"
            # Session.set 'displaying_profile',null


        'click .sign_guidelines': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'member_guidelines_signing'
                session_id: healthclub_session_document._id
                resident_id: healthclub_session_document.user_id
                resident: healthclub_session_document.resident_username
            Router.go "/sign_guidelines/#{new_id}/#{healthclub_session_document.resident_username}"
            # Session.set 'displaying_profile',null

        'click .add_recent_guest': ->
            current_session = Docs.findOne
                model:'session'
                current:true
            Docs.update current_session._id,
                $addToSet:guest_ids:@_id

        'click .remove_guest': ->
            current_session = Docs.findOne
                model:'session'
                current:true
            # console.log current_session
            Docs.update current_session._id,
                $pull:guest_ids:@_id

        'click .toggle_adding_guest': ->
            Session.set 'adding_guest', true
            Session.set 'timer_engaged', false

        'click .submit_checkin': (e,t)->
            Meteor.call 'submit_checkin'

        'click .cancel_auto_checkin': (e,t)->
            Session.set 'timer_engaged',false

    Template.healthclub_session.helpers
        timer_engaged: ->
            Session.get 'timer_engaged'
        timer: ->
            Session.get 'timer'
            # console.log Template.instance()
            # Template.instance().timer.get()

        rules_signed: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            if healthclub_session_document.user_id
                resident = Meteor.users.findOne healthclub_session_document.user_id
                # if resident.user_id
                Docs.findOne
                    model:'rules_and_regs_signing'
                    resident:resident.username
        session_document: -> Docs.findOne Router.current().params.doc_id

        adding_guests: -> Session.get 'adding_guest'
        checking_in_doc: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log healthclub_session_document
            healthclub_session_document
        checkin_guest_docs: () ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            Docs.find
                _id:$in:healthclub_session_document.guest_ids

        user: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            if healthclub_session_document and healthclub_session_document.user_id
                Meteor.users.findOne healthclub_session_document.user_id


    Template.resident_guest.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data
    Template.resident_guest.helpers
        guest_doc: ->
            Docs.findOne Template.currentData()



if Meteor.isServer
    Meteor.publish 'kiosk_document', ()->
        Docs.find
            model:'kiosk'



    # publishComposite 'healthclub_session', (doc_id)->
    #     {
    #         find: ->
    #             Docs.find doc_id
    #         children: [
    #             { find: (doc) ->
    #                 Meteor.users.find
    #                     _id: doc.user_id
    #                 }
    #             { find: (doc) ->
    #                 Docs.find
    #                     model: 'guest'
    #                     _id:doc.guest_ids
    #                 }
    #             ]
    #     }
