import { Controller } from 'stimulus'
import { Modal } from 'bootstrap.native'

export default class extends Controller {
  static targets = [ 'modal', 'typeSelector', 'consumablesList' ]

  modal() {
    var modal = new Modal(this.modalTarget, {});
    window.action = 'send'
    var types;
    var typeSelector;

    var request_types = this.create_request('GET', 'consumables/get_types', false);
    request_types.onload = function() {
      types = JSON.parse(request_types.response);
    };
    request_types.send();

    typeSelector = '<option selected value="' + types[0].id  + '">' + types[0].title + '</option>'
    for (var i = 1; i < types.length; i++) {
      typeSelector += '<option value="' + types[i].id + '">' + types[i].title + '</option>'
    }

    var modalContent =
        '<div class="modal-header">'
          +'<h4 class="modal-title"> Refill consumables </h4>'
          +'<button type="button" class="close" data-dismiss="modal" aria-label="Close">'
            +'<span aria-hidden="true">×</span>'
          +'</button>'
        +'</div>'
        +'<div class="modal-body">'
          +'<div id="send" class="custom-control custom-radio custom-control-inline" data-action="change->refill-consumable#radio">'
            +'<input type="radio" id="radio_send" name="radio" class="custom-control-input" checked>'
            +'<label class="custom-control-label" for="radio_send">Send to refill</label>'
          +'</div>'
          +'<div id="get" class="custom-control custom-radio custom-control-inline ml-5" data-action="change->refill-consumable#radio">'
            +'<input type="radio" id="radio_get" name="radio" class="custom-control-input">'
            +'<label class="custom-control-label" for="radio_get">Get from refill</label>'
          +'</div>'
          +'<p></p>'
          +'Type:'
          +'<select class="custom-select" data-target="refill-consumable.typeSelector" data-action="refill-consumable#selectType">'
            + typeSelector
          +'</select>'
          +'<p></p>'
          + '<div class="form-group" data-target="refill-consumable.consumablesList">'
          + '</div>'
        +'</div>'
        +'<div class="modal-footer">'
          +'<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>'
          +'<button type="button" class="btn btn-primary" data-action="refill-consumable#execute">OK</button>'
        +'</div>';
    modal.setContent(modalContent);
    this.selectType();
    modal.show();
  }

  selectType() {
    var id = 0;
    var consumables;
    var consumablesContent = '';
    var request_consumables = this.create_request('POST', 'consumables/get_consumables', false);
    request_consumables.onload = function() {
      consumables = JSON.parse(request_consumables.response);
    };
    request_consumables.send('type_id=' + this.typeSelectorTarget.value);
    var max = 0;
    for (var i = 0; i < consumables.length; i++) {
      max = window.action == 'send' ? consumables[i].quantity_ready_to_refill : consumables[i].quantity_at_refill
      if (max > 0) {
        id = consumables[i].id
        consumablesContent += '<div class="form-group row"><label class="ml-3 col-form-label col-4 text-right">'
                           + consumables[i].title + ': </label>' + '<input id="input' + id
                           + '" class="form-control col-3" type="number" value="' + max + '" max="' + max
                           + '" min="0" onchange="range' + id + '.value = input' + id + '.value">'
                           + '<div class="col-4"><input type="range" class="form-control-range slider mt-2"'
                           + 'oninput="input'+ id + '.value = range' + id + '.value"'
                           + 'type="range" min="0" max="' + max + '" value="' + max + '" id="range' + id
                           + '" onchange="input' + id + '.value = range' + id + '.value"></div></div>'
      }
    }
    this.consumablesListTarget.innerHTML = consumablesContent;
  }

  radio(event) {
    window.action = event.currentTarget.id;
    this.selectType();
  }

  execute() {
    var isSaved = false;
    var consumable;
    var consumablesCounts = this.consumablesListTarget.childNodes
    var data = '{"act":"' + window.action + '", "counters":[';
    for (var i = 0; i < consumablesCounts.length; i++) {
      consumable = consumablesCounts[i].childNodes[1];
      data += '{"id":' + consumable.id.slice(5) + ', "count":' + consumable.value + '},';
    }
    data = data.slice(0, -1);
    data += ']}';
    var request_execute = new XMLHttpRequest();
    request_execute.open('POST', 'consumables/refill', false);
    request_execute.setRequestHeader('Content-type', 'application/json');
    request_execute.onload = function() {
      isSaved = JSON.parse(request_execute.response);
    };
    request_execute.send(data);

    if (!isSaved) {
        alert('Something went wrong. Please contact your system administrator')
      }
      document.location.reload(true);
  }

  create_request(http_method, url, async) {
    var request = new XMLHttpRequest();
    request.open(http_method, url, async);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    return request;
  }
}
