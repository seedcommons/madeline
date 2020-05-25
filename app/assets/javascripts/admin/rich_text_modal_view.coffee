class MS.Views.RichTextModalView extends Backbone.View

  el: '#rich-text-modal'

  initialize: (options) ->
    console.log("Rich Text Modal View")
    @$el.modal('show')

  # events:
