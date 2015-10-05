class @MaterializeModalClass

  constructor: ->
    @errorMessage = new ReactiveVar()
    @bodyTemplate = new ReactiveVar()

  defaults:
    title: 'Message'
    message: ''
    body_template_data: {}
    type: 'message'
    closeLabel: null
    submitLabel: 'ok'
    inputSelector: "#prompt-input"

  options: {}

  reset: ->
    @options = @defaults
    @callback = null
    @errorMessage.set(null)


  open: ->
    console.log("MaterializeModal open", @) if DEBUG
    Blaze.remove(@tmpl) if @tmpl?
    @bodyTemplate.set(@options.bodyTemplate)
    @tmpl = Blaze.renderWithData(Template.materializeModal, @options, document.body)


  close: ->
    console.log "close" if DEBUG
    $('#materializeModal').closeModal
      complete: ->
        MaterializeModal.remove()


  remove: ->
    console.log("remove") if DEBUG
    Blaze.remove(@tmpl)
    @reset()



  modalReady: (tmpl) ->
    console.log("materializeModal is open") if DEBUG


  setTemplate: (template) ->
    @options.bodyTemplate = template
    @bodyTemplate.set(template)


  message: (@options = {}) ->
    _.defaults @options,
      message: t9nIt 'You need to pass a message to materialize modal!'
      title: t9nIt 'Message'
      submitLabel: t9nIt 'ok'
    , @defaults

    @open()


  alert: (@options = {}) ->
    _.defaults @options,
      type: 'alert'
      message: t9nIt 'Alert'
      title: t9nIt 'Alert'
      label: t9nIt "Alert"
      bodyTemplate: "materializeModalAlert"
      submitLabel: t9nIt 'ok'
      @defaults

    @open()


  error: (@options = {}) ->
    _.defaults @options,
      type: 'error'
      message: t9nIt 'Error'
      title: t9nIt 'Error'
      label: t9nIt "Error"
      bodyTemplate: "materializeModalError"
      submitLabel: t9nIt 'ok'
    , @defaults

    @open()


  confirm: (@options = {}) ->
    _.defaults @options,
      type: 'confirm'
      message: t9nIt 'Message'
      title: t9nIt 'Confirm'
      closeLabel: t9nIt 'cancel'
      submitLabel: t9nIt 'ok'
    , @defaults

    @open()


  prompt: (@options = {}) ->
    _.defaults @options,
      type: 'prompt'
      message: t9nIt 'Feedback?'
      title: t9nIt 'Prompt'
      bodyTemplate: 'materializeModalPrompt'
      closeLabel: t9nIt 'cancel'
      submitLabel: t9nIt 'submit'
      placeholder: t9nIt "Type something here"
    , @defaults

    @open()


  loading: (@options = {}) ->
    _.defaults @options,
      message: t9nIt('Loading') + ' ...'
      title: t9nIt 'Loading'
      bodyTemplate: 'materializeModalLoading'
      submitLabel: t9nIt 'cancel'
    , @defaults

    @open()


  form: (@options = {}) ->
    console.log("form options", @options) if DEBUG
    if not @options.bodyTemplate?
      Materialize.toast(t9nIt "Error: No template specified!", 3000, "red")
    else
      _.defaults @options,
        type: 'form'
        title: t9nIt "Edit Record"
        submitLabel: '<i class="material-icons left">save</i>' + t9nIt('save')
        closeLabel: '<i class="material-icons left">not_interested</i>' + t9nIt('cancel')
      , @defaults

      if @options.smallForm
        @options.size = 'modal-sm'
        @options.btnSize = 'btn-sm'
      @open()


  addValueToObjFromDotString: (obj, dotString, value) ->
    path = dotString.split(".")
    tmp = obj
    lastPart = path.pop()
    for part in path
      # loop through each part of the path adding to obj
      if not tmp[part]?
        tmp[part] = {}
      tmp = tmp[part]
    if lastPart?
      tmp[lastPart] = value


  fromForm: (form) ->
    console.log("fromForm", form) if DEBUG
    result = {}
    for key in form?.serializeArray() # This Works do not change!!!
      @addValueToObjFromDotString(result, key.name, key.value)
    # Override the result with the boolean values of checkboxes, if any
    for check in form?.find "input:checkbox"
      if $(check).prop('name')
        result[$(check).prop('name')] = $(check).prop 'checked'
    console.log("fromForm result", result) if DEBUG
    result


  doCallback: (yesNo, event, form) ->
    if yesNo
      switch @options.type
        when 'prompt'
          returnVal = $(@options.inputSelector).val()
        when 'select'
          returnVal = $('select option:selected')
        when 'form'
          if form?
            returnVal = @fromForm(form)
          else
            returnVal = null
        else
          returnVal = null

    if @options.callback?
      try
        @options.callback(yesNo, returnVal, event)
      catch error
        console.log("MaterializeModal Callback returned Error", error)
        Materialize.toast("#{error.reason}", 3000, 'toast-error')
        return false

    true


###

  status: (message, callback, title = 'Status', cancelText = 'Cancel') ->
    @_setData message, title, "materializeModalstatus",
      message: message
    @callback = callback
    @set("submitLabel", cancelText)
    @_show()

  updateProgressMessage: (message) ->
    if DEBUG
      console.log("updateProgressMessage", $("#progressMessage").html(), message)
    if $("#progressMessage").html()?
      $("#progressMessage").fadeOut 400, ->
        $("#progressMessage").html(message)
        $("#progressMessage").fadeIn(400)
    else
      @set("message", message)

###
