$ ->
  addToAvailableLocales = (scope, locale) ->
    elem = $(scope).find('#add_another_language')
    $(elem).data('available-locales').splice(0, 0, locale)
    setLinksVisibility(scope)

  getNextAvailableLocale = (scope) ->
    elem = $(scope).find('#add_another_language')
    # hide the add new language link if we are returning the last unused locale
    locale = $(elem).data('available-locales').splice(0, 1)[0]
    setLinksVisibility(scope)
    locale

  setLinksVisibility = (scope) ->
    els = $(scope).find('.remove_language')
    if els.length == 1
      $(els).hide()
    else
      $(els).show()

    el = $(scope).find('#add_another_language')
    if $(el).data('available-locales').length == 0
      $(el).hide()
    else
      $(el).show()

  setCallbacks = (scope) ->
    #
    # remove language
    #

    $(scope).find('.remove_language').click (evt) ->
      evt.preventDefault()

      locale = $(evt.target).data('locale')
      $(scope).find(".step-form-left-group[data-locale=\"#{locale}\"]").remove()
      addToAvailableLocales(scope, locale)

      deleted_locales = JSON.parse($("#deleted_locales").val())
      deleted_locales.push(locale)
      $(scope).find("#deleted_locales").val(JSON.stringify(deleted_locales))
      setLinksVisibility(scope)

    #
    # add another language
    #

    $(scope).find('#add_another_language').click (evt) ->
      evt.preventDefault()

      newLocale = getNextAvailableLocale(scope)


      # clone the last language block and set it up with the next available locale
      lastLanguageBlock = $(scope).find(".step-form-left-group").last()
      clone = lastLanguageBlock.clone()
      localeToReplace = $(clone).data('locale')
      html = $(clone).prop('outerHTML')
      html = html.replace(new RegExp("_#{localeToReplace}", 'g'), "_#{newLocale}")
                 .replace(new RegExp("data-locale=\"#{localeToReplace}\"", 'g'), "data-locale=\"#{newLocale}\"")
      newLanguageBlock = $.parseHTML(html)
      $(newLanguageBlock).data('locale', newLocale)
      $(newLanguageBlock).find(".summary").attr("placeholder", gon.I18n[newLocale].summary).val('')
      $(newLanguageBlock).find(".details").attr("placeholder", gon.I18n[newLocale].details).val('')
      $(newLanguageBlock).find("#project_step_locale_#{newLocale} option[value='#{newLocale}']").attr("selected", "selected")
      $(newLanguageBlock).find("#remove_#{newLocale}_language").click (evt) ->
        evt.preventDefault()
        $(scope).find(".step-form-left-group[data-locale=\"#{newLocale}\"]").remove()
        addToAvailableLocales(scope, newLocale)
        setLinksVisibility(scope)

      $(newLanguageBlock).insertAfter(lastLanguageBlock)
      setLinksVisibility(scope)
      setCallbacks(scope)

    #
    # Change existing translation locale
    #

    $(scope).find('.locale').change (evt) ->
      evt.preventDefault()
      newLocale = $(evt.target).val()
      parent = $(evt.target).parents(".language-block")
      parent.find('.summary').attr("placeholder", gon.I18n[newLocale].summary);
      parent.find('.details').attr("placeholder", gon.I18n[newLocale].summary);

  #
  # Run once on load
  #


  $('div .panel.step').each((idx, el) ->
    setLinksVisibility(el)
    setCallbacks(el)
  )


