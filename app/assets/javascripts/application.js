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
//= require bootstrap-sprockets
//= require jasny-bootstrap
//= require select2-full
//= require URI
//= require bootstrap-responsive-tabs

//= require jquery-ui
//= require wice_grid

//= require twitter/bootstrap/rails/confirm
//= require admin/admin
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/madeline_system
