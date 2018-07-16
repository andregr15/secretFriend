$(document).on 'turbolinks:load', ->
  $('#member_email, #member_name').keypress (e) ->
    if e.which == 13 && valid_email($( "#member_email" ).val()) && $( "#member_name" ).val() != ""
      $('.new_member').submit()

  $('#member_email, #member_name').bind 'blur', ->
    if valid_email($( "#member_email" ).val()) && $( "#member_name" ).val() != ""
      $('.new_member').submit()

  $('body').on 'click', 'a.remove_member', (e) ->
    $.ajax '/members/'+ e.currentTarget.id,
        type: 'DELETE'
        dataType: 'json',
        data: {}
        success: (data, text, jqXHR) ->
          Materialize.toast('Membro removido', 4000, 'green')
          $('#member_' + e.currentTarget.id).remove()
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na remoção de membro', 4000, 'red')
    return false

  $('.new_member').on 'submit', (e) ->
    $.ajax e.target.action,
        type: 'POST'
        dataType: 'json',
        data: $(".new_member").serialize()
        success: (data, text, jqXHR) ->
          insert_member(data['id'], data['name'],  data['email'])
          $('#member_name, #member_email').val("")
          $('#member_name').focus()
          Materialize.toast('Membro adicionado', 4000, 'green')
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problema na hora de incluir membro', 4000, 'red')
    return false

  $('.member_edit input').bind 'blur', (e) ->
    member_id = e.currentTarget.form.id.substring(12)
    if valid_email($( "#email_" + member_id ).val()) && $( "#name_" + member_id ).val() != ""
      $('#'+ e.currentTarget.form.id).submit()

  $('.member_edit').on 'submit', (e) ->
    e.preventDefault();
    update_member(e)
    return false

  # submeter form adicionado dinamicamente
  # fonte: https://stackoverflow.com/questions/14832534/how-to-add-submit-event-to-dynamically-generated-form
  $(document).on 'submit', '.member_edit', (e) ->
    e.preventDefault();
    update_member(e)
    return false

update_member = (e) ->
  member_id = e.currentTarget.id.substring(12)
  $.ajax e.target.action,
    type: 'PUT',
    dataType: 'json'
    data: {
      member: {
        campaign_id: $('#campaign_id').val(),
        name: $('#name_' + member_id).val(),
        email: $('#email_' + member_id).val(),
      },
      # adicionando um token de autenticacao para o form de atualizacao adicionado dinamicamente
      # fonte: https://gist.github.com/collectiveidea/172391
      authenticity_token: authenticityToken()
    },
    success: (data, text, jqXHR) ->
      Materialize.toast('Membro atualizado', 4000, 'green')
    error: (jqXHR, textStatus, errorThrown) ->
      Materialize.toast(errorThrown, 4000, 'red')
  return false

authenticityToken = () ->
  return $('#authenticity-token').attr('content');

# Colocado o @ para jogar essa função para a janela
# fonte: https://stackoverflow.com/questions/11464057/coffeescript-function-created-in-app-assets-javascript-not-found
@member_on_blur = (form_id) ->
  member_id = form_id.substring(12)
  if valid_email($( "#email_" + member_id ).val()) && $( "#name_" + member_id ).val() != ""
    $('#'+ form_id).submit()
  return false

valid_email = (email) ->
  /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(email)

insert_member = (id, name, email) ->
  $('.member_list').append(
    '<form class="member_edit" id="edit_member_' + id + '" action="/members/'+ id + '" accept-charset="UTF-8" method="post">'+
      '<input type="hidden" name="_method" value="put">' +
      '<div class="member" id="member_' + id + '">' +
        '<div class="row">' +
          '<div class="col s12 m5 input-field">' +
            '<input id="name_' + id + '" type="text" class="validate" value="' + name + '" onblur="member_on_blur(this.form.id)">' +
            '<label for="name" class="active">Nome</label>' +
          '</div>' +
          '<div class="col s12 m5 input-field">' +
            '<input id="email_' + id + '" type="email" class="validate" value="' + email + '" onblur="member_on_blur(this.form.id)">' +
            '<label for="email" class="active" data-error="Formato incorreto">Email</label>' +
          '</div>' +
          '<div class="col s3 offset-s3 m1 input-field">' +
            '<i class="material-icons icon">visibility</i>' +
          '</div>' +
          '<div class="col s3 m1 input-field">' +
            '<a href="#" class="remove_member" id="' + id + '">' +
              '<i class="material-icons icon">delete</i>' +
            '</a>' +
          '</div>' +
        '</div>' +
      '</div>' +
    '</form>')
