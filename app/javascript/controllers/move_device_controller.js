import { Controller } from 'stimulus'
import { Modal } from 'bootstrap.native'

export default class extends Controller {
  static targets = [ 'modal', 'roomSelector', 'departmentSelector', 'swapSwitch' ]

    modal(event) {
      window.deviceID = event.currentTarget.id;
      var modal = new Modal(this.modalTarget, {});
      var request_departments = this.create_request('GET', 'devices/get_departments', false);
      var request_locations = this.create_request('GET', 'devices/get_locations', false);
      var departments;
      var departmentSelector;
      request_departments.onload = function() {
        departments = JSON.parse(request_departments.response);
      };
      request_departments.send();
      request_locations.onload = function() {
        window.locations = JSON.parse(request_locations.response);
      };
      request_locations.send();
      for (var i = 0; i < departments.length; i++) {
        departmentSelector += '<option value="' + departments[i] + '">' + departments[i] + '</option>'
      }
      var modalContent =
        '<div class="modal-header">'
          +'<h4 class="modal-title"> Move Device with ID=' + window.deviceID + ' to:</h4>'
          +'<button type="button" class="close" data-dismiss="modal" aria-label="Close">'
            +'<span aria-hidden="true">×</span>'
          +'</button>'
        +'</div>'
        +'<div class="modal-body">'
          +'Department:'
          +'<select class="custom-select" data-target="move-device.departmentSelector" data-action="change->move-device#selectDepartment">'
            +'<option selected>Choose department</option>'
            + departmentSelector
          +'</select>'
          +'<p></p>'
          +'Room: <div data-target="move-device.roomSelector">'
          // element <select> must be firstChild of div roomSelector!
          +'<select class="custom-select" size="6" data-action="change->move-device#selectRoom">'
          +'</select>'
          +'</div>'
          +'<p></p>'
          +'<div class="custom-control custom-switch">'
            +'<input type="checkbox" class="custom-control-input" disabled id="swapSwitch" data-target="move-device.swapSwitch">'
            +'<label class="custom-control-label" for="swapSwitch" data-toggle="tooltip" data-placement="bottom" title="Swap availiable only if in the target location only one device of the same type">Swap with a device of the same type</label>'
          +'</div>'
        +'</div>'
        +'<div class="modal-footer">'
          +'<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>'
          +'<button type="button" class="btn btn-primary" data-action="move-device#move">Move</button>'
        +'</div>';
      modal.setContent(modalContent);
      modal.show();
    }

    selectDepartment() {
      var roomSelectorContent;
      roomSelectorContent = '<select class="custom-select" size="6" data-action="change->move-device#selectRoom">'
      for (var i = 0; i < window.locations.length; i++) {
        if (window.locations[i].department == this.departmentSelectorTarget.value) {
          roomSelectorContent += '<option value="' + i + '">' + window.locations[i].room + '</option>';
        }
      }
      roomSelectorContent += '</select>'
      this.roomSelectorTarget.firstChild.innerHTML = roomSelectorContent;
    }

    selectRoom() {
      var request = this.create_request('POST', 'devices/is_swappable', false);
      var swap;
      request.onload = function() {
        swap = JSON.parse(request.response).swap == 'true';
      };
      request.send('device_id=' + window.deviceID + '&location_id=' + window.locations[this.roomSelectorTarget.firstChild.value].id);
      if (swap) {
        this.swapSwitchTarget.removeAttribute("disabled");
      } else {
        this.swapSwitchTarget.setAttribute("disabled", "");
        this.swapSwitchTarget.checked = false;
      }
    }

    move() {
      if (Number.isInteger(parseInt(this.roomSelectorTarget.firstChild.value))) {
        var request = this.create_request('POST', 'devices/move', false);
        var isSaved;
        request.onload = function() {
          isSaved = JSON.parse(request.response);
        };
        request.send('device_id=' + window.deviceID
                   + '&location_id=' + window.locations[this.roomSelectorTarget.firstChild.value].id
                   + '&swap=' + this.swapSwitchTarget.checked);
      } else {
        alert('Please, select location');
      }

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
