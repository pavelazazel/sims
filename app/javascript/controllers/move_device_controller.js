import { Controller } from 'stimulus'
import { Modal } from 'bootstrap.native'

export default class extends Controller {
  static targets = [ 'modal', 'roomSelector', 'departmentSelector' ]

    modal(event) {
      window.deviceID = event.currentTarget.id
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
          +'Room:'
          +'<select class="custom-select" size="5" data-target="move-device.roomSelector">'
          +'</select>'
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
      for (var i = 0; i < window.locations.length; i++) {
        if (window.locations[i].department == this.departmentSelectorTarget.value) {
          roomSelectorContent += '<option value="' + i + '">' + window.locations[i].room + '</option>';
        }
      }
      this.roomSelectorTarget.innerHTML = roomSelectorContent;
    }

    move() {
      if (Number.isInteger(parseInt(this.roomSelectorTarget.value))) {
        var request = this.create_request('POST', 'devices/move', false);
        var isSaved;
        request.onload = function() {
          isSaved = JSON.parse(request.response);
        };
        request.send('device_id=' + window.deviceID + '&location_id=' + window.locations[this.roomSelectorTarget.value].id);
      }
      else {
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
