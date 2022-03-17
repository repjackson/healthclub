Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: true

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

# Router.onBeforeAction(force_loggedin, {
#   # only: ['admin']
#   # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
#   except: ['register', 'forgot_password','reset_password','delta','doc_view','verify-email','download_rules_pdf']
# });

Router.route "/add_guest/:new_guest_id", -> @render 'add_guest'

Router.route '/inbox', -> @render 'inbox'
# Router.route '/register', -> @render 'register'
# Router.route '/admin', -> @render 'admin'
Router.route '/dashboard', -> @render 'dashboard'
Router.route '/manager', -> @render 'manager'

# Router.route '/building/:building_code', -> @render 'building'

Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})


Router.route '/m/:model_slug', (->
    @render 'delta'
    ), name:'delta'
Router.route '/m/:model_slug/:doc_id/edit', -> @render 'model_doc_edit'
Router.route '/m/:model_slug/:doc_id/view', (->
    @render 'model_doc_view'
    ), name:'doc_view'
Router.route '/model/edit/:doc_id', -> @render 'model_edit'

# Router.route '/user/:username', -> @render 'user'
Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'
Router.route '/forgot_password', -> @render 'forgot_password'

Router.route '/staff', -> @render 'staff'
Router.route '/frontdesk', -> @render 'frontdesk'
Router.route '/user/:username/edit', -> @render 'user_edit'
Router.route '/p/:slug', -> @render 'page'
Router.route '/settings', -> @render 'settings'
Router.route '/sign_rules/:doc_id/:username', -> @render 'rules_signing'
Router.route '/sign_guidelines/:doc_id/:username', -> @render 'guidelines_signing'
# Router.route '/users', -> @render 'people'
Router.route '/sign_waiver/:receipt_id', -> @render 'sign_waiver'
# Router.route "/meal/:meal_id", -> @render 'meal_doc'

Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/download_rules_pdf/:username', (->
    @render 'download_rules_pdf'
    ), name: 'download_rules_pdf'


Router.route '/login', -> @render 'login'
Router.route '/register', -> @render 'register'

# Router.route '/', -> @redirect '/m/model'
# Router.route '/', -> @redirect "/user/#{Meteor.user().username}"
# Router.route '/', (->
#     @layout 'layout'
#     @render 'staff'
#     ), name:'front'


Router.route '/checkin', (->
    @layout 'mlayout'
    @render 'checkin'
    ), name:'checkin'


Router.route '/session/:doc_id', (->
    @layout 'mlayout'
    @render 'session'
    ), name:'session'
