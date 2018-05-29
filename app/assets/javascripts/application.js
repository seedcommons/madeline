// These are scripts required by all parts of the app, including admin and public.
// This manifest does NOT pull in the admin and public directories.

//= require jquery
//= require jquery_ujs

//= require i18n
//= require i18n/translations

//= require bootstrap-sprockets
//= require jasny-bootstrap

//= require select2-full
//= require URI
//= require shared/bootstrap-multi-modal-fix

//= require jquery-ui
//= require jquery.remotipart
//= require wice_grid
//= require tree.jquery
//= require jquery.dirtyforms
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.es.js

//= require moment
//= require fullcalendar
//= require fullcalendar/locale-all.js

//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink

//= require summernote/summernote-bs4.min
//= require summernote-init

//= require_self
//= require_tree ./shared

// Namespaces
window.MS = {Views: {}};
