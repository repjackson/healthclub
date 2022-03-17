if Meteor.isClient
    Router.route '/residents', -> @render 'residents'
    Router.route '/resident/:doc_id/edit', -> @render 'resident_edit'
    Router.route '/resident/:doc_id/', -> @render 'resident_view'


    Template.resident_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.resident_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => @subscribe 'model_docs', 'checkin', ->
        @autorun => @subscribe 'resident_checkins', Router.current().params.doc_id, ->
            
            
    Template.residents.onCreated ->
        @autorun => Meteor.subscribe 'resident_search', Session.get('name_search')
    Template.residents.helpers
        resident_docs: ->
            name_search = Session.get('name_search')
            Docs.find 
                model:'resident'
                # name: {$regex:"#{name_search}", $options: 'i'}
            # Meteor.users.find({
            #     username: {$regex:"#{username_search}", $options: 'i'}
            #     # healthclub_checkedin:$ne:true
            #     # roles:$in:['resident','owner']
            #     },{ limit:20 }).fetch()
    Template.residents.events
        'click .add_resident': ->
            id = Docs.insert model:'resident'
            Router.go "/resident/#{id}/edit"
        'keyup .name_search': (e,t)->
            console.log e.which
            name_search = $('.name_search').val()
            if e.which is 8
                if name_search.length is 0
                    Session.set 'name_search',null
                    Session.set 'checking_in',false
                else
                    Session.set 'name_search',name_search
            else
                Session.set 'name_search',name_search

    Template.resident_view.events
        'click .checkin': ->
            Docs.insert 
                model:'checkin'
                resident_id:@_id
                resident_name: "#{@first_name} #{@last_name}"
                active:true
                
            Docs.update @_id,
                $set:
                    checked_in:true
            
            $('body').toast({
                title: "#{@first_name} #{@last_name} checked in"
                class: 'success'
                transition:
                    showMethod   : 'zoom',
                    showDuration : 250,
                    hideMethod   : 'fade',
                    hideDuration : 250
            })
        
        
        
        'click .checkout': ->
            active_checkin = 
                Docs.findOne
                    model:'checkin'
                    # resident_id:@_id
                    # resident_name: "#{@first_name} #{@last_name}"
                    active:true
            if active_checkin
                Docs.update active_checkin._id,
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
                $('body').toast({
                    title: "#{@first_name} #{@last_name} checked out"
                    class: 'error'
                    transition:
                        showMethod   : 'zoom',
                        showDuration : 250,
                        hideMethod   : 'fade',
                        hideDuration : 250
                })
                Docs.update @_id,
                    $set:
                        checked_in:false 
                        last_checkout_timestamp:Date.now()


    Template.resident_view.helpers
        resident_checkins: ->
            Docs.find 
                model:'checkin'

    Template.resident_view.events
        # 'cilck


    Router.route '/users', -> @render 'users'
    Template.users.onCreated ->
        # @autorun -> Meteor.subscribe('users')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_search'), 'user'
    Template.users.helpers
        users: ->
            username_search = Session.get('username_search')
            Meteor.users.find({
                username: {$regex:"#{username_search}", $options: 'i'}
                # healthclub_checkedin:$ne:true
                # roles:$in:['resident','owner']
                },{ limit:20 }).fetch()
    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .username_search': (e,t)->
            username_search = $('.username_search').val()
            if e.which is 8
                if username_search.length is 0
                    Session.set 'username_search',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_search',username_search
            else
                Session.set 'username_search',username_search


if Meteor.isServer

    Meteor.publish 'resident_checkins', (resident_id)->
        Docs.find 
            model:'checkin'
            resident_id:resident_id

    Meteor.publish 'user_search', (username, role)->
        if role
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
                roles:$in:[role]
            },{ limit:20})
        else
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
            },{ limit:20})
    Meteor.publish 'resident_search', (name)->
        Docs.find({
            model:'resident'
            # username: {$regex:"#{name}", $options: 'i'}
            # roles:$in:[role]
        },{ limit:50})