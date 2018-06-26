$(document).on 'turbolinks:load', ->
  $('.sidenav').sidenav()
  return

$(document).on 'ready turbolinks:before-visit', ->
  elem = document.querySelector('#sidenav');
  instance = M.Sidenav.getInstance(elem);
  if instance
    instance.destroy()

