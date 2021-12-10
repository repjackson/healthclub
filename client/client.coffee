# Meteor.startup ->
#     scheduler.init "scheduler_here", new Date()
#     scheduler.meteor(Docs.find(model:'event'), Docs);



$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable

Session.setDefault 'invert', false
Template.registerHelper 'loading_checkin', () -> Session.get 'loading_checkin'
Template.registerHelper 'parent', () -> Template.parentData()
Template.registerHelper 'invert_class', () -> if Session.equals('dark_mode',true) then 'invert' else ''
Template.registerHelper 'is_loading', () -> Session.get 'loading'
Template.registerHelper 'dev', () -> Meteor.isDevelopment
Template.registerHelper 'is_author', () ->
    @_author_id is Meteor.userId()
Template.registerHelper 'is_grandparent_author', () ->
    grandparent = Template.parentData(2)
    grandparent._author_id is Meteor.userId()
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm:ss a")
Template.registerHelper 'today', () ->
    moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
Template.registerHelper 'is_event', () -> @shop_type is 'event'
Template.registerHelper 'is_service', () -> @shop_type is 'service'
Template.registerHelper 'is_product', () -> @shop_type is 'product'


Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")




# Template.registerHelper 'parent_template', () -> Template.parentData()
    # Session.get 'displaying_profile'

# Template.registerHelper 'checking_in_doc', () ->
#     Docs.findOne
#         model:'healthclub_session'
#         current:true
#      # Session.get('session_document')

# Template.registerHelper 'current_session_doc', () ->
#         Docs.findOne
#             model:'healthclub_session'
#             current:true



# Template.registerHelper 'checkin_guest_docs', () ->
#     Docs.findOne Router.current().params.doc_id
#     session_document = Docs.findOne Router.current().params.doc_id
#     # console.log session_document.guest_ids
#     Docs.find
#         _id:$in:session_document.guest_ids


Meteor.methods
    submit_checkin: ->
        Session.set 'adding_guest', false
        healthclub_session_document = Docs.findOne Router.current().params.doc_id
        # console.log @
        resident = Meteor.users.findOne healthclub_session_document.user_id

        # healthclub_session_document = Docs.findOne
        #     model:'healthclub_session'
        user = Meteor.users.findOne
            username:resident.username
        healthclub_session_document = Docs.findOne Router.current().params.doc_id
        if healthclub_session_document.guest_ids.length > 0
            # now = Date.now()
            current_month = moment().format("MMM")
            Meteor.users.update user._id,
                $addToSet:
                    total_guests:healthclub_session_document.guest_ids.length
                    "#{current_month}_guests":healthclub_session_document.guest_ids.length
        Docs.update healthclub_session_document._id,
            $set:
                # session_type:'healthclub_checkin'
                submitted:true
        Router.go "/healthclub"
        $('body').toast({
            title: "#{resident.first_name} #{resident.last_name} checked in"
            class: 'success'
            transition:
                showMethod   : 'zoom',
                showDuration : 250,
                hideMethod   : 'fade',
                hideDuration : 250
        })




Template.registerHelper 'resident_guests', () ->
    Docs.find
        _id:$in:@guest_ids

Template.registerHelper 'is_springdale', () ->
    console.log @
    unit = Docs.findOne Router.current().params.unit_id
    console.log unit
    if unit.building_code is 'springdale' or 'sp' then true else false

Template.registerHelper 'current_month_guests', () ->
    # console.log @
    current_month = moment().format("MMM")
    @["#{current_month}_guests"]

Template.registerHelper 'referenced_product', () ->
    Docs.findOne
        _id:@product_id


Template.registerHelper 'resident_status_class', ()->
    # console.log @
    unless @rules_and_regs_signed
        'red_flagged'
    else unless @email_validated
        'orange_flagged'
    else ''

Template.registerHelper 'author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'is_text', () ->
    # console.log @field_type
    @field_type is 'text'

Template.registerHelper 'template_parent', () ->
    # console.log Template.parentData()
    Template.parentData()

Template.registerHelper 'fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            view_roles:$in:Meteor.user().roles
        }, sort:rank:1

Template.registerHelper 'edit_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            edit_roles:$in:Meteor.user().roles
        }, sort:rank:1

Template.registerHelper 'current_user', (input) ->
    Meteor.user() and Meteor.user().username is Router.current().params.username


Template.registerHelper 'user_is_client', (input) ->
    user = Meteor.users.findOne username:Router.current().params.username
    if user and user.roles and 'client' in user.roles then true else false

Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'current_model', (input) ->
    Docs.findOne
        model:'model'
        slug: Router.current().params.model_slug

Template.registerHelper 'in_list', (key) ->
    if Meteor.userId()
        if Meteor.userId() in @["#{key}"] then true else false


Template.registerHelper 'is_admin', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','admin'], Meteor.user().roles) then true else false
        if 'admin' in Meteor.user().roles then true else false

Template.registerHelper 'is_staff', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'staff' in Meteor.user().roles then true else false
Template.registerHelper 'is_frontdesk', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'frontdesk' in Meteor.user().roles then true else false
Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false
Template.registerHelper 'is_manager', () ->
    if Meteor.user() and Meteor.user().roles
        if 'manager' in Meteor.user().roles then true else false

Template.registerHelper 'is_resident', () ->
    if Meteor.user() and Meteor.user().roles
        if 'resident' in Meteor.user().roles then true else false

Template.registerHelper 'is_user', () ->
    if Meteor.user() and Meteor.user().roles
        if 'user' in Meteor.user().roles then true else false

Template.registerHelper 'is_resident_or_user', () ->
    if Meteor.user() and Meteor.user().roles
        # console.log _.intersection(Meteor.user().roles, ['resident','user']).length
        if _.intersection(Meteor.user().roles, ['resident','user']).length then true else false

Template.registerHelper 'user_is_resident', () -> if @roles and 'resident' in @roles then true else false
Template.registerHelper 'user_is_owner', () -> if @roles and 'owner' in @roles then true else false
Template.registerHelper 'user_is_staff', () -> if @roles and 'staff' in @roles then true else false
Template.registerHelper 'user_is_user', () -> if @roles and 'user' in @roles then true else false
Template.registerHelper 'user_is_resident_or_owner', () -> if @roles and _.intersection(@roles,['resident','owner']) then true else false


Template.registerHelper 'is_eric', () -> if Meteor.userId() and 'ytjpFxiwnWaJELZEd' is Meteor.userId() then true else false
Template.registerHelper 'is_alpha', () -> if Meteor.userId() and 'ytjpFxiwnWaJELZEd' is Meteor.userId() then true else false


Template.registerHelper 'current_user', () ->  Meteor.users.findOne username:Router.current().params.username
Template.registerHelper 'is_current_user', () ->  Meteor.user().username is Router.current().params.username
Template.registerHelper 'view_template', -> "#{@field_type}_view"
Template.registerHelper 'edit_template', -> "#{@field_type}_edit"
Template.registerHelper 'is_model', -> @model is 'model'


# Template.body.events
#     'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> Session.equals 'editing_id', @_id


Template.registerHelper 'can_edit', () -> Meteor.userId() is @_author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    if doc then doc else if user then user


Template.registerHelper 'user_from_username_param', () ->
    found = Meteor.users.findOne username:Router.current().params.username
    # console.log found
    found
Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        parent["#{@key}"]


Template.registerHelper 'is_marketplace', () -> @model is 'marketplace'
Template.registerHelper 'is_post', () -> @model is 'post'
Template.registerHelper 'is_meal', () -> @model is 'meal'


Template.registerHelper 'in_dev', () -> Meteor.isDevelopment

Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'



Template.registerHelper 'in_dev', () -> Meteor.isDevelopment
