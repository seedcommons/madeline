#= require moment
#= require fullcalendar

$ ->
  $('#calendar').fullCalendar({
      events: [
        {
            title  : 'event1',
            start  : '2016-03-01'
        },
        {
            title  : 'event2',
            start  : '2016-03-18',
            end    : '2016-03-19'
        },
        {
            title  : 'event3',
            start  : '2010-01-09T12:30:00'
        }
      ]
    })
