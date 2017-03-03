// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.


//////////////////////////////////////////////////////////////////////////////////
// Note: For the admin system, we are moving away from the old practice
// of including JS on a per-page basis.
// All admin JS should generally be under the backbone folder, and
// everything in there is included via `require backbone/madeline_system` above.


//= require jquery
//= require jquery_ujs

//= require i18n
//= require i18n/translations

//= require bootstrap-sprockets
//= require jasny-bootstrap
//= require select2-full
//= require URI
//= require bootstrap-multi-modal-fix

//= require jquery-ui
//= require jquery.remotipart
//= require wice_grid
//= require tree.jquery
//= require jquery.dirtyforms
//= require bootstrap-datepicker

//= require twitter/bootstrap/rails/confirm
//= require admin/confirm

//= require moment
//= require fullcalendar
//= require fullcalendar/lang-all.js

//= require admin/admin

//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/madeline_system
