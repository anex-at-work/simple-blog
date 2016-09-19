# anex.work
#= require typeahead.js/bloodhound
#= require typeahead.js/typeahead.jquery

'use strict'
(($) ->
  window['typeahead'] = {} if !window['typeahead']

  $.fn.typeaheadable = (e)->
    @.each ->
      bloodhound = new Bloodhound
        queryTokenizer: Bloodhound.tokenizers.whitespace
        datumTokenizer: Bloodhound.tokenizers.whitespace
        remote:
          url: "#{$(@).data('url')}#{if $(@).data('url').indexOf('?') == -1 then '?' else '&amp;'}q=%q"
          wildcard: '%q'

      suggestion_template = if $(@).data('template') and window['typeahead'][$(@).data('template')] then window['typeahead'][$(@).data('template')] else (->)
      ta = $(@).typeahead null,
        name: 'id'
        display: 'name'
        source: bloodhound
        limit: 15
        templates:
          suggestion: suggestion_template
          notFound: =>
            if $(@).data 'observe'
              hidden_el = $(@).parents('.form-group').siblings 'input[type="hidden"]'
              return if !hidden_el
              observe_ids = (id.trim() for id in $(@).data('observe').split(','))
              ((el_id)->
                hidden_el.filter("[name*='[#{el_id}]']").val '') el_id for el_id in observe_ids
            undefined

      ta.parent().next('.floating-label').insertAfter(ta)
      if $(@).data 'observe'
        _el = $ @
        ta.on 'typeahead:select', (e, el)->
          hidden_el = _el.parents('.form-group').siblings 'input[type="hidden"]'
          return if !hidden_el
          observe_ids = (id.trim() for id in _el.data('observe').split(','))
          ((el_id)->
            hidden_el.filter("[name*='[#{el_id}]']").val el[el_id]) el_id for el_id in observe_ids
      if $(@).data 'copy-after'
        ta.on 'typeahead:select', (e, el)->
          ((el_id)->
            changed_el = $("[data-bind='#{el_id}']")
            if changed_el.find('> :first-child').is('img')
              changed_el.find('> :first-child').attr 'src', el[el_id]
            else if changed_el.hasClass('googlemapable')
              changed_el.data 'location', el[el_id]
              changed_el.googlemapable 'reset'
            else changed_el.html el[el_id]
            if changed_el.data 'editableurl'
              $.ajax
                url: changed_el.data('editableurl')
                type: 'put'
                data:
                  copy: el.id
          ) el_id for el_id of el
    @
) jQuery
