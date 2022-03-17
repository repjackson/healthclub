if Meteor.isClient
    Router.route '/rentals', -> @render 'rentals'
    Router.route '/rental/:doc_id/edit', -> @render 'rental_edit'
    Router.route '/rental/:doc_id/', -> @render 'rental_view'


    Template.rental_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.rental_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => @subscribe 'model_docs', 'checkin', ->
        @autorun => @subscribe 'rental_checkins', Router.current().params.doc_id, ->
            
            
    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'rental_search', Session.get('name_search')
    Template.rentals.helpers
        rental_docs: ->
            name_search = Session.get('name_search')
            Docs.find 
                model:'rental'
                # name: {$regex:"#{name_search}", $options: 'i'}
            # Meteor.users.find({
            #     username: {$regex:"#{username_search}", $options: 'i'}
            #     # healthclub_checkedin:$ne:true
            #     # roles:$in:['rental','owner']
            #     },{ limit:20 }).fetch()
    Template.rentals.events
        'click .add_rental': ->
            id = Docs.insert model:'rental'
            Router.go "/rental/#{id}/edit"
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

    Template.rental_view.events
        'click .checkin': ->
            Docs.insert 
                model:'checkin'
                rental_id:@_id
                rental_name: "#{@first_name} #{@last_name}"
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
                    # rental_id:@_id
                    # rental_name: "#{@first_name} #{@last_name}"
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


    Template.rental_view.helpers
        rental_checkins: ->
            Docs.find 
                model:'checkin'

    Template.rental_view.events
        # 'cilck



if Meteor.isServer
    Meteor.publish 'rental_checkins', (rental_id)->
        Docs.find 
            model:'checkin'
            rental_id:rental_id

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
    Meteor.publish 'rental_search', (name)->
        Docs.find({
            model:'rental'
            # username: {$regex:"#{name}", $options: 'i'}
            # roles:$in:[role]
        },{ limit:50})