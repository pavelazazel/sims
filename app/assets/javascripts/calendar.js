$(document).on('turbolinks:load', function() {
  $('#datetimepickerfrom').datetimepicker({
    format: 'DD/MM/YYYY HH:mm:ss UTCZ',
    language: 'en-gb',
    icons: {
      time: 'far fa-clock',
      date: 'far fa-calendar'
    },
  });
  $('#datetimepickerto').datetimepicker({
    format: 'DD/MM/YYYY HH:mm:ss UTCZ',
    language: 'en-gb',
    icons: {
      time: 'far fa-clock',
      date: 'far fa-calendar'
    },
  });
});
