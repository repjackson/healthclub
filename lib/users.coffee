if Meteor.isClient
    Router.route '/residents', -> @render 'residents'
    Router.route '/resident/:doc_id/edit', -> @render 'resident_edit'
    Router.route '/resident/:doc_id/', -> @render 'resident_view'


    Template.resident_edit.onCreated ->
        @autorun => @subscribe 'doc', Router.current().params.doc_id, ->
    Template.resident_view.onCreated ->
        @autorun => @subscribe 'doc', Router.current().params.doc_id, ->
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
            # username: {$regex:"#{name}", $options: 'i'}
            # roles:$in:[role]
        },{ limit:50})