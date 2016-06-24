# Handles adding, removing, and formatting translations in a project step form
class MS.Views.TranslationsView extends Backbone.View

  el: '.languages'

  initialize: (params) ->
    @permittedLocales = I18n.availableLocales
    @updateLinks()

  events:
    'click a.add-language': 'addLanguage'
    'click a.remove-language': 'removeLanguage'
    'change select.locale': 'localeChanged'

  addLanguage: (e) ->
    e.preventDefault()

    availLoc = @availableLocales()

    newLocale = availLoc[0]
    return false unless newLocale

    # Clone existing block
    newBlock = @$('.language-block').last().clone()
    oldLocale = $(newBlock).data('locale')

    # Remove already-defined locales from dropdown.
    newBlock.find('select.locale option')
      .filter (_, o) -> availLoc.indexOf($(o).val()) == -1
      .remove()

    @changeBlockLocale(newBlock, newLocale)
    @$('a.add-language').before(newBlock)
    @updateLinks()

  removeLanguage: (e) ->
    e.preventDefault()
    block = @$(e.target).closest('.language-block')
    locale = block.data('locale')
    block.remove()
    @addToDeletedLocales(locale)
    @updateLinks()

  # Shows/hides add/remove links depending on context
  updateLinks: ->
    @$('a.remove-language')[if @blockCount() > 1 then 'show' else 'hide']()
    @$('a.add-language')[if @availableLocales().length > 0 then 'show' else 'hide']()

  localeChanged: (e) ->
    select = @$(e.target)
    block = select.closest('.language-block')
    @addToDeletedLocales(block.data('locale'))
    @changeBlockLocale(block, select.val())
    @updateLinks()

  changeBlockLocale: (block, newLocale) ->
    oldLocale = block.data('locale')
    block.html(block.html().replace(new RegExp("_#{oldLocale}", 'g'), "_#{newLocale}"))
    block.data('locale', newLocale).attr("data-locale", newLocale)
    block.find('input[type=text], textarea').val('')
    block.find('select.locale').val(newLocale)
    @updatePlaceholders(block, newLocale)

  # Updates placeholders for text fields to a new locale
  updatePlaceholders: (block, locale) ->
    block.find('[data-translatable]').each ->
      item_name = $(this).attr('data-translatable')
      $(this).attr('placeholder', I18n.t(item_name, { locale: locale }))
      $(this).prev().html(I18n.t(item_name, { locale: locale }))

  availableLocales: ->
    @permittedLocales.filter (l) => @usedLocales().indexOf(l) < 0

  usedLocales: ->
    @$('select.locale').map( -> $(this).val() ).get()

  blockCount: ->
    @$('.language-block').length

  addToDeletedLocales: (locale) ->
    input = @$('[name$="[deleted_locales][]"]').first()
    if input.val()
      input2 = input.clone().insertAfter(input).val(locale)
    else
      input.val(locale)
