# by anex.work

'use strict'
(($) ->
  default_option =
    please_wait: 'Пожалуйста, подождите'

  class FormValidatable
    constructor: (@el, options)->
      @options = $.extend {}, default_option, options
      @_normalize_form()
      @_create_event()
      @_prevent_double_submit()

    _normalize_form: ->
      @el.data 'type', 'json'

    _create_event: ->
      @el.on 'ajax:error', (x, s, er)=>
        console.log x, s
        if !s.responseJSON and (!s.responseJSON?.errors or !s.responseJSON?.error)
          @el.prepend "<div class='alert alert-danger' role='alert'>#{s.responseText}</div>"
          return
        errors = s.responseJSON.errors
        ((er)=>
          @el.find(":input[name*='[#{er}]'] + .help-block").remove()
          @el.find(":input[name*='[#{er}]']").
            after("<span class='help-block'>#{errors[er].join(', ')}</span>").
            closest('.form-group').addClass('has-error')
        ) er for er of errors
        if s.responseJSON.error
          @el.prepend "<div class='alert alert-danger' role='alert'>#{s.responseJSON.error}</div>"
      $(':input', @el).on 'change', ->
        return if !$(@).closest('.form-group').hasClass 'has-error'
        $(@).siblings('.help-block').remove()
        $(@).closest('.form-group').removeClass 'has-error'
        $('[role="aler"]', @).remove()

    _prevent_double_submit: ->
      val_default = $(':submit', @el).val()
      dis_default = $(':submit', @el).prop('disabled')
      @el.on
        submit: =>
          if $(':submit', @el).prop('disabled')
            e.preventDefault()
            return false
          $(':submit', @el).prop('disabled', true).val @options.please_wait
          $('.alert.alert-danger', @el).remove()
        'ajax:complete': (x, d, s)=>
          if 'success' != s
            $(':submit', @el).prop('disabled', false).val val_default
          else
            $(':submit', @el).prop('disabled', dis_default).val val_default
        'ajax:success': (e, x, d, s)=>
          @el[0].reset()
          $(':input', @el).trigger 'change'
          if s.responseJSON and s.responseJSON.location
            Turbolinks.visit s.responseJSON.location

  $(document).on 'turbolinks:load', ->
    $('form[data-remote="true"]').form_validatable()

  $.fn.extend
    form_validatable: (options)->
      @each ->
        new FormValidatable $(@), options
) jQuery
