module.exports = {
  addMemberView: function() {
    var nameTextbox = document.createElement('input');
    var addMemberBtn = document.createElement('input');
    nameTextbox.id = 'textbox-fn';
    nameTextbox.type = 'text';
    nameTextbox.placeholder = 'Nombre';
    addMemberBtn.id = 'add-member-btn';
    addMemberBtn.type = 'button';
    addMemberBtn.value = 'Hacerme socio';
    document.getElementById('body').appendChild(nameTextbox);
    document.getElementById('body').appendChild(addMemberBtn);
    $(document).on('click', '#add-member-btn', App.addMember);
  }
}
