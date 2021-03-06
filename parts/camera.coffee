# # if Meteor.isClient
# #     Template.camera.events
# #         'click .take_picture': ->
# #             console.log 'hi'
# #             canvas = document.getElementById('canvas')
# #             video = document.getElementById('video')
# #             context = canvas.getContext('2d')
# #             canvas.width = 600
# #             canvas.height = 480
# #             context.drawImage(video, 0, 0, 600, 480)
# #             data = canvas.toDataURL('image/png');
# #             console.log data
# #             console.log(Router.current().params.doc_id)
# #             session = Docs.findOne Router.current().params.doc_id
# #             console.log session
# #             photo.setAttribute('src', data);
# # if Meteor.isServer
# #     Meteor.methods
# #         set_kiosk_photo: (session_id, data)->
# #             console.log 'session id', session_id
# #             console.log 'data', data
#
# # stream = undefined
# # closeAndCallback = undefined
# # photo = new ReactiveVar(null)
# # error = new ReactiveVar(null)
# # waitingForPermission = new ReactiveVar(null)
# # canvasWidth = 0
# # canvasHeight = 0
# # quality = 80
#
# Template.camera.onRendered ->
#     template = this
#     video = template.find('canvas')
#     # stream webcam video to the <video> element
#
#     # success = (newStream) ->
#     #   stream = newStream
#     #   vendorURL = window.URL or window.webkitURL
#     #   video.src = vendorURL.createObjectURL(stream)
#     #   video.play()
#     #   waitingForPermission.set false
#     #   return
#
#     # user declined or there was some other error
#
#     failure = (err) ->
#         error.set err
#         return
#
#     # initiate request for webcam
#
#     constraints = { audio: true, video: { width: 1280, height: 720 } };
#     navigator.mediaDevices.getUserMedia(constraints)
#         .then((mediaStream) ->
#             video = document.querySelector('video');
#             video.srcObject = mediaStream;
#             video.onloadedmetadata = (e)->
#                 video.play();
#         )
#         .catch((err)-> { console.log(err.name + ": " + err.message); })
#
#
#
#
#     # resize viewfinder to a reasonable size, not necessarily photo size
#     viewfinderWidth = 320
#     viewfinderHeight = 240
#     resized = false
#     video.addEventListener 'canplay', (->
#         if !resized
#             viewfinderHeight = video.videoHeight / (video.videoWidth / viewfinderWidth)
#             video.setAttribute 'width', viewfinderWidth
#             video.setAttribute 'height', viewfinderHeight
#             resized = true
#         return
#     ), false
#     return
#
# # is the current error a permission denied error?
#
# permissionDeniedError = ->
#   error.get() and (error.get().name == 'PermissionDeniedError' or error.get() == 'PERMISSION_DENIED')
#
# # is the current error a browser not supported error?
#
# browserNotSupportedError = ->
#   error.get() and error.get() == 'BROWSER_NOT_SUPPORTED'
#
# stopStream = (st) ->
#   if !st
#     return
#   if st.stop
#     st.stop()
#     return
#   if st.getTracks
#     tracks = st.getTracks()
#     i = 0
#     while i < tracks.length
#       track = tracks[i]
#       if track and track.stop
#         track.stop()
#       i++
#   return
#
# Template.camera.helpers
#   photo: ->
#     photo.get()
#   error: ->
#     error.get()
#   permissionDeniedError: permissionDeniedError
#   browserNotSupportedError: browserNotSupportedError
# Template.camera.events
#   'click .use-photo': ->
#     closeAndCallback null, photo.get()
#     return
#   'click .new-photo': ->
#     photo.set null
#     return
#   'click .cancel': ->
#     if permissionDeniedError()
#       closeAndCallback new (Meteor.Error)('permissionDenied', 'Camera permissions were denied.')
#     else if browserNotSupportedError()
#       closeAndCallback new (Meteor.Error)('browserNotSupported', 'This browser isn\'t supported.')
#     else if error.get()
#       closeAndCallback new (Meteor.Error)('unknownError', 'There was an error while accessing the camera.')
#     else
#       closeAndCallback new (Meteor.Error)('cancel', 'Photo taking was cancelled.')
#     if stream
#       stopStream stream
#     return
# Template.camera.events 'click .shutter': (event, template) ->
#   video = template.find('video')
#   canvas = template.find('canvas')
#   canvas.width = canvasWidth
#   canvas.height = canvasHeight
#   canvas.getContext('2d').drawImage video, 0, 0, canvasWidth, canvasHeight
#   data = canvas.toDataURL('image/jpeg', quality)
#   photo.set data
#   stopStream stream
#   return
# Template.camera.helpers 'waitingForPermission': ->
#   waitingForPermission.get()
#
# ###*
# # @summary Get a picture from the device's default camera.
# # @param  {Object}   options  Options
# # @param {Number} options.height The minimum height of the image
# # @param {Number} options.width The minimum width of the image
# # @param {Number} options.quality [description]
# # @param  {Function} callback A callback that is called with two arguments:
# # 1. error, an object that contains error.message and possibly other properties
# # depending on platform
# # 2. data, a Data URI string with the image encoded in JPEG format, ready to
# # use as the `src` attribute on an `<img />` tag.
# ###
#
# getPicture = (options, callback) ->
#   # if options are not passed
#   if !callback
#     callback = options
#     options = {}
#   desiredHeight = options.height or 640
#   desiredWidth = options.width or 480
#   # Canvas#toDataURL takes the quality as a 0-1 value, not a percentage
#   quality = (options.quality or 49) / 100
#   if desiredHeight * 4 / 3 > desiredWidth
#     canvasWidth = desiredHeight * 4 / 3
#     canvasHeight = desiredHeight
#   else
#     canvasHeight = desiredWidth * 3 / 4
#     canvasWidth = desiredWidth
#   canvasWidth = Math.round(canvasWidth)
#   canvasHeight = Math.round(canvasHeight)
#   view = undefined
#
#   closeAndCallback = ->
#     originalArgs = arguments
#     UI.remove view
#     photo.set null
#     callback.apply null, originalArgs
#     return
#
#   view = UI.renderWithData(Template.camera)
#   UI.insert view, document.body
#   return
