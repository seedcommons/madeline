# Handles adding, removing, and formatting translations in a project step form
class MS.Views.ProjectStepTranslationsView extends Backbone.View

  initialize: (params) ->
    @permittedLocales = I18n.availableLocales
    @updateLinks()

  events:
    'click a.add-language': 'addLanguage'
    'click a.remove-language': 'removeLanguage'
    'change select.locale': 'localeChanged'

  addLanguage: (e) ->
    e.preventDefault()

    newLocale = @availableLocales()[0]
    return false unless newLocale

    # Clone existing block
    newBlock = @$('.language-block').last().clone()
    oldLocale = $(newBlock).data('locale')

    # Update new block to new locale
    newBlock.html(newBlock.html().replace(new RegExp("_#{oldLocale}", 'g'), "_#{newLocale}"))
    newBlock.data('locale', newLocale)
    newBlock.find('input[type=text], textarea').val('')
    newBlock.find('select.locale').val(newLocale)

    @$('a.add-language').before(newBlock)

    @updatePlaceholders(newBlock, newLocale)
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
    @updatePlaceholders(block, select.val())
    @updateLinks()

  # Updates placeholders for text fields to a new locale
  updatePlaceholders: (block, locale) ->
    block.find('[data-translatable]').each ->
      item_name = $(this).attr('data-translatable')
      $(this).attr('placeholder', I18n.t(item_name, { locale: locale }))

  availableLocales: ->
    used = @$('select.locale').map( -> $(this).val() ).get()
    @permittedLocales.filter (l) -> used.indexOf(l) < 0

  blockCount: ->
    @$('.language-block').length

  addToDeletedLocales: (locale) ->
    el = @$('[name$="[deleted_locales]"]')
    array = JSON.parse(el.val())
    array.push(locale)
    el.val(JSON.stringify(array))
