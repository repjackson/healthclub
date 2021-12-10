if Meteor.isClient
    Template.delta.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'my_delta'

    Template.delta.helpers
        selected_tags: -> selected_tags.list()

        current_delta: ->
            Docs.findOne
                model:'delta'
                _author_id:Meteor.userId()

        sorted_facets: ->
            current_delta =
                Docs.findOne
                    model:'delta'
                    _author_id:Meteor.userId()
            if current_delta
                # console.log _.sortBy current_delta.facets,'rank'
                _.sortBy current_delta.facets,'rank'

        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            delta = Docs.findOne model:'delta'
            count = delta.result_ids.length
            if count is 1 then true else false


    Template.delta.events
        'click .create_delta': (e,t)->
            Docs.insert
                model:'delta'
                model_filter: Router.current().params.model_slug

        'keyup .import_subreddit': (e,t)->
            if e.which is 13
                val = t.$('.import_subreddit').val()
                Meteor.call 'pull_subreddit', val, (err,res)->
                    console.log res


        'click .print_delta': (e,t)->
            delta = Docs.findOne model:'delta'
            console.log delta

        'click .reset': ->
            model_slug =  Router.current().params.model_slug
            Session.set 'loading', true
            Meteor.call 'set_facets', model_slug, ->
                Session.set 'loading', false

        'click .delete_delta': (e,t)->
            delta = Docs.findOne model:'delta'
            if delta
                if confirm "delete  #{delta._id}?"
                    Docs.remove delta._id

        'click .add_model_doc': ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            # console.log model
            if model.collection and model.collection is 'users'
                name = prompt 'first and last name'
                split = name.split ' '
                first_name = split[0]
                last_name = split[1]
                username = name.split(' ').join('_')
                # console.log username
                Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                    if err
                        alert err
                    else
                        Meteor.users.update res,
                            $set:
                                first_name:first_name
                                last_name:last_name
                        Router.go "/m/#{model.slug}/#{res}/edit"
            else if model.slug is 'shop'
                new_doc_id = Docs.insert
                    model:model.slug
                Router.go "/shop/#{new_doc_id}/edit"
            else
                new_doc_id = Docs.insert
                    model:model.slug
                Router.go "/m/#{model.slug}/#{new_doc_id}/edit"


        'click .edit_model': ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            Router.go "/model/edit/#{model._id}"

        # 'click .page_up': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false
        #
        # 'click .page_down': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:-1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false

        # 'click .select_tag': -> selected_tags.push @name
        # 'click .unselect_tag': -> selected_tags.remove @valueOf()
        # 'click #clear_tags': -> selected_tags.clear()
        #
        # 'keyup #search': (e)->
            # switch e.which
            #     when 13
            #         if e.target.value is 'clear'
            #             selected_tags.clear()
            #             $('#search').val('')
            #         else
            #             selected_tags.push e.target.value.toLowerCase().trim()
            #             $('#search').val('')
            #     when 8
            #         if e.target.value is ''
            #             selected_tags.pop()


    Template.facet.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500

    Template.facet.events
        # 'click .ui.accordion': ->
        #     $('.accordion').accordion()

        'click .toggle_selection': ->
            delta = Docs.findOne model:'delta'
            facet = Template.currentData()

            Session.set 'loading', true
            if facet.filters and @name in facet.filters
                Meteor.call 'remove_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false
            else
                Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false

        'keyup .add_filter': (e,t)->
            # console.log @
            if e.which is 13
                delta = Docs.findOne model:'delta'
                facet = Template.currentData()
                if @field_type is 'number'
                    filter = parseInt t.$('.add_filter').val()
                else
                    filter = t.$('.add_filter').val()
                Session.set 'loading', true
                Meteor.call 'add_facet_filter', delta._id, facet.key, filter, ->
                    Session.set 'loading', false
                t.$('.add_filter').val('')




    Template.facet.helpers
        filtering_res: ->
            delta = Docs.findOne model:'delta'
            filtering_res = []
            if @key is '_keys'
                @res
            else
                for filter in @res
                    if filter.count < delta.total
                        filtering_res.push filter
                    else if filter.name in @filters
                        filtering_res.push filter
                filtering_res



        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne model:'delta'
            if Session.equals 'loading', true
                 'disabled basic'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else 'basic'

    Template.delta_result.onRendered ->
        # Meteor.setTimeout ->
        #     $('.progress').popup()
        # , 2000
    Template.delta_result.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data._id
        @autorun => Meteor.subscribe 'user_from_id', @data._id

    Template.delta_result.helpers
        template_exists: ->
            current_model = Router.current().params.model_slug
            if Template["#{current_model}_card_template"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false

        model_template: ->
            current_model = Router.current().params.model_slug
            "#{current_model}_card_template"


        result: ->
            if Docs.findOne @_id
                # console.log 'doc'
                result = Docs.findOne @_id
                if result.private is true
                    if result._author_id is Meteor.userId()
                        result
                else
                    result
            else if Meteor.users.findOne @_id
                # console.log 'user'
                Meteor.users.findOne @_id

    Template.delta_result.events
        'click .set_model': ->
            Meteor.call 'set_delta_facets', @slug, Meteor.userId()

        'click .route_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
            # delta = Docs.findOne model:'delta'
            # Docs.update delta._id,
            #     $set:model_filter:@slug
            #
            # Meteor.call 'fum', delta._id, (err,res)->



if Meteor.isServer
    Meteor.publish 'model_from_slug', (model_slug)->
        # if model_slug in ['model','brick','field','tribe','block','page']
        #     Docs.find
        #         model:'model'
        #         slug:model_slug
        # else
        match = {}
        # if tribe_slug then match.slug = tribe_slug
        match.model = 'model'
        match.slug = model_slug

        Docs.find match


    Meteor.publish 'my_delta', ->
        if Meteor.userId()
            Docs.find
                _author_id:Meteor.userId()
                model:'delta'
        else
            Docs.find
                _author_id:null
                model:'delta'
