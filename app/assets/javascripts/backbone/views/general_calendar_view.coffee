# This creates and controls a standard calendar which displays a standard month and week view.
class MS.Views.GeneralCalendarView extends MS.Views.CalendarView

  el: '.calendar'

  initialize: (params) ->
    @prepareVariables(params)
    @prepareDefaultSettings(params, this)

    @settings =
      customButtons:
        legend:
          text: I18n.t('calendar.legend', locale: params.locale)
      header:
        left: 'prev,next today'
        center: 'title'
        right: 'month,basicWeek legend'
      dayClick: @dayClick.bind(this)

    @initializeCalendar()
    @renderLegend()
