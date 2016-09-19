#= require jquery
#= require jquery-ujs
#= require turbolinks
#= require bootstrap-sass
#= require moment
#= require moment/locale/ru
#= require eonasdan-bootstrap-datetimepicker
#= require select2
#= require_tree ./classes

'use strict'
(($) ->
  $(document).on 'turbolinks:load', ->
    $('[data-datetimepicker]').each ->
      $(@).datetimepicker
        format: $(@).data('format') || ''

    $('.tageditable').each ->
      $(@).select2
        tags: true
        tokenSeparators: [',']
        ajax:
          url: $(@).data('tagsurl')
          dataType: 'json'
          delay: 200
          data: (params)->
            {q: params.term, page: params.page}
          processResults: (data, params)->
            params.page ?= 1
            {results: data.items, pagination: {more: (params.page * 30) < data.total_count}}
          cache: true
        escapeMarkup: (markup)->
          markup
        templateResult: (repo)->
          repo.name
        templateSelection: (repo)->
          repo.name or repo.text

    $('[data-reply-for]').click (e)->
      $('#reply_comment').remove()
      $('#new_comment').clone().prop('id', 'reply_comment').appendTo $(@).parents('.comment')
      $('#reply_comment input[name="comment[parent_id]"]').val $(@).data('reply-for')
      $('#reply_comment input:visible:text:first').focus()
      $('#reply_comment').form_validatable()
      e.preventDefault()
      return false

    $('[data-available]').each ->
      @time_available = parseInt $(@).data('available')
      time_interval = setInterval =>
        @time_available--
        seconds = parseInt(@time_available % 60, 10)
        $(@).html "#{parseInt(@time_available / 60, 10)}:#{if 10 > seconds then '0' + seconds else seconds}"
        if 0 >= @time_available
          clearInterval time_interval
      , 1000
) jQuery
