//= require_self
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./routers

window.MS = {
  Models: {},
  Collections: {},
  Routers: {},
  Views: {}
};

$(function() { new MS.Views.ApplicationView() })
