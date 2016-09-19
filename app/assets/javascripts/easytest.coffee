#= require jquery
#= require jquery-ujs

'use strict'
(($) ->
  $ ->
    recount = ->
      i = 1
      $(el).css({zIndex: i++}) for el, n in $('.slider .slider__content > div') by -1
    recount()

    $('.slider .slider__arrow-left').click (e)->
      $('.slider .slider__item:last-child').insertAfter $('.slider .slider__item:first-child')
      recount()
      $('.slider .slider__item:first-child').stop(true, true).animate
        opacity: 0
      , 500, ()->
        $(@).insertAfter $('.slider .slider__item:nth-child(2)')
        $(@).css
          opacity: 1
        recount()
    $('.slider .slider__arrow-right').click (e)->
      $('.slider .slider__item:first-child').stop(true, true).animate
        opacity: 0
      , 500, ()->
        $(@).insertAfter $('.slider .slider__item:last-child')
        $(@).css
          opacity: 1
        recount()

) jQuery
