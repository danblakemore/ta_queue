TaQueue.Views.Tas ||= {}

class TaQueue.Views.Tas.ShowView extends Backbone.View
  template: JST["backbone/templates/tas/show_view"]

  className: "post_it"

  initialize: (options) ->
    @ta = options.ta

  render: ->
    $(@el).html(@template({ @ta }))
    $(@el).css('background-color', @ta.hexColor())
    this
    
