if Meteor.isClient
    Router.route '/residents', -> @render 'residents'
    Router.route '/resident/:doc_id/edit', -> @render 'resident_edit'
    Router.route '/resident/:doc_id/', -> @render 'resident_view'


    Template.resident_edit.onCreated ->
        @autorun => @subscribe 'doc', Router.current().params.doc_id, ->
    Template.resident_view.onCreated ->
        @autorun => @subscribe 'doc', Router.current().params.doc_id, ->
    Template.residents.onCreated ->
        @autorun => Meteor.subscribe 'resident_search', Session.get('username_query')
    Template.residents.helpers
        resident_docs: ->
            username_query = Session.get('username_query')
            Docs.find 
                model:'resident'
                name: {$regex:"#{name_query}", $options: 'i'}
            # Meteor.users.find({
            #     username: {$regex:"#{username_query}", $options: 'i'}
            #     # healthclub_checkedin:$ne:true
            #     # roles:$in:['resident','owner']
            #     },{ limit:20 }).fetch()
    Template.residents.events
        'click .add_resident': ->
            id = Docs.insert model:'resident'
            Router.go "/resident/#{id}/edit"
        'keyup .name_search': (e,t)->
            name_query = $('.name_search').val()
            if e.which is 8
                if name_query.length is 0
                    Session.set 'name_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'name_query',name_query
            else
                Session.set 'name_query',name_query


    Router.route '/users', -> @render 'users'
    Template.users.onCreated ->
        # @autorun -> Meteor.subscribe('users')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query'), 'user'
    Template.users.helpers
        users: ->
            username_query = Session.get('username_query')
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # healthclub_checkedin:$ne:true
                # roles:$in:['resident','owner']
                },{ limit:20 }).fetch()
    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .username_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query


if Meteor.isServer
    Meteor.publish 'users', (limit)->
        if limit
            Meteor.users.find({},limit:limit)
        else
            Meteor.users.find()


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
            username: {$regex:"#{name}", $options: 'i'}
            # roles:$in:[role]
        },{ limit:50})