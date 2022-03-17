if Meteor.isClient
    Router.route '/posts', -> @render 'posts'
    Router.route '/post/:doc_id/edit', -> @render 'post_edit'
    Router.route '/post/:doc_id/', -> @render 'post_view'


    Template.post_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => @subscribe 'model_docs', 'checkin', ->
        @autorun => @subscribe 'post_checkins', Router.current().params.doc_id, ->
            
            
    Template.posts.onCreated ->
        @autorun => Meteor.subscribe 'post_search', Session.get('name_search')
    Template.posts.helpers
        post_docs: ->
            name_search = Session.get('name_search')
            Docs.find 
                model:'post'
                # name: {$regex:"#{name_search}", $options: 'i'}
            # Meteor.users.find({
            #     username: {$regex:"#{username_search}", $options: 'i'}
            #     # healthclub_checkedin:$ne:true
            #     # roles:$in:['post','owner']
            #     },{ limit:20 }).fetch()
    Template.posts.events
        'click .add_post': ->
            id = Docs.insert model:'post'
            Router.go "/post/#{id}/edit"
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

    Template.post_view.events
        'click .checkin': ->
            Docs.insert 
                model:'checkin'
                post_id:@_id
                post_name: "#{@first_name} #{@last_name}"
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
                    # post_id:@_id
                    # post_name: "#{@first_name} #{@last_name}"
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


    Template.post_view.helpers
        post_checkins: ->
            Docs.find 
                model:'checkin'

    Template.post_view.events
        # 'cilck



if Meteor.isServer
    Meteor.publish 'post_checkins', (post_id)->
        Docs.find 
            model:'checkin'
            post_id:post_id

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
    Meteor.publish 'post_search', (name)->
        Docs.find({
            model:'post'
            # username: {$regex:"#{name}", $options: 'i'}
            # roles:$in:[role]
        },{ limit:50})