import { Controller } from 'stimulus'

const TYPE_IDS = [3, 8]; // SET THIS ARRAY ACCORDING TO YOUR DEVICE TYPE_IDS IN TABLE OF TYPES
const CONSUMABLE_TYPE_ID = 1; // SET THIS CONSTANT ACCORDING TO YOUR CONSUMABLE TYPE_ID IN TABLE OF CONSUMABLE TYPES

export default class extends Controller {
  static targets = [ 'input', 'instruction', 'info', 'cancel', 'timerReload', 'timerAbort' ]

  connect() {
    window.which_device = false;
    window.unnumbered_room = false;
    var request = this.create_request('GET', 'get_locations', true);
    request.onload = function() {
      window.locations = JSON.parse(request.response);
    };
    request.send();
  }

  changeInput(is_enter) {
    var input = parseInt(this.inputTarget.value);
    if (window.which_device) {
      ((input > 0) && (input <= window.devices.length)) ? this.move(window.devices[input-1]) : this.clearInput();
    } else {
      if (window.unnumbered_room) {
        if (is_enter == true) {
          this.get_devices(window.locations[input].department, window.locations[input].room);
        }
      } else {
        this.checkLocation(false);
      }
    }
  }

  checkLocation(is_enter) {
    var inputLocation = this.inputTarget.value;
    var department = '';
    switch(inputLocation[0]) {
      case '/':
        department = 'orbeli';
        break;
      case '*':
        department = 'prosvet';
        break;
      case '+':
        this.unnumberedRoom();
        break;
      default:
        department = 'sikeyrosa';
    }
    var room = Number(inputLocation.replace(/\D+/g,''));
    var location_found = false;
    var sub_room = 0;
    for (var i = 0; i < window.locations.length; i++) {
      if (room.toString() == window.locations[i].room.substring(0, room.toString().length) &&
          department == window.locations[i].department) {
        sub_room++;
        if (room == window.locations[i].room) {
          location_found = true;
        }
      }
    }
    if (location_found && (sub_room == 1 || is_enter)) {
      this.get_devices(department, room);
    }
  }

  unnumberedRoom() {
    this.clearInput();
    this.start_reload_timer();
    var sUnnumRooms = []; var oUnnumRooms = []; var pUnnumRooms = [];
    var allUnnumRooms = [sUnnumRooms, oUnnumRooms, pUnnumRooms];
    var allUnnumRoomsDepNames = ['Сикейроса', 'Орбели', 'Просвещения'];
    for (var i = 0; i < window.locations.length; i++) {
      if (isNaN(parseInt(locations[i].room))) {
        switch(locations[i].department) {
          case 'sikeyrosa':
            sUnnumRooms.push(i);
            break;
          case 'orbeli':
            oUnnumRooms.push(i);
            break;
          case 'prosvet':
            pUnnumRooms.push(i);
            break;
          default:
            console.log('unnumberedRoom - department error');
            alert('Упс! Что-то не так, обратитесь к системному администратору');
            document.location.reload(true);
        }
      }
    }
    this.instructionTarget.textContent = 'Введите номер, которому соответствует описание Вашего кабинета и нажмите Enter';
    var unnumRoomsHTML = '<div class="container"> <div class="row">';
    allUnnumRooms.forEach(function(dep, i, allUnnumRooms) {
      unnumRoomsHTML += '<div class="col"><p><h3>' + (allUnnumRoomsDepNames[i]) + '</h3></p>';
      dep.forEach(function(unnumRoom, j, dep) {
        unnumRoomsHTML += '<p align="left">' + unnumRoom + ') ' + locations[unnumRoom].room + '</p>';
      });
      unnumRoomsHTML += '</div>';
    });
    unnumRoomsHTML += '</div></div>';
    this.infoTarget.innerHTML = unnumRoomsHTML;
    window.unnumbered_room = true;
  }

  get_devices(department, room) {
    var devices = [];
    for (var i = 0; i < TYPE_IDS.length; i++) {
      var request = this.create_request('POST', 'get_devices', false);
      request.onload = function() {
        devices = devices.concat(JSON.parse(request.response));
      };
      request.send('type_id=' + TYPE_IDS[i] + '&department=' + department + '&room=' + room);
    }
    if (devices.length == 1) {
      this.move(devices[0]);
    } else if (devices.length > 1) {
      this.which_device(devices);
    } else {
      this.clearInput();
      alert('В кабинете №' + room +' не найдено печатающих устройств. Проверьте ввод или обратитесь к администратору.');
      document.location.reload(true);
    }
  }

  move(device) {
    var request = this.create_request('POST', 'move', false);
    var cartridge;
    request.onload = function() {
      cartridge = JSON.parse(request.response);
    };
    request.send('consumable_type_id=' + CONSUMABLE_TYPE_ID + '&name_id=' + device[0] + '&location_id=' + device[2]);
    this.clearInput();
    this.inputTarget.style.display = 'none';
    this.timerReloadTarget.style.display = 'none';
    if (cartridge.title) {
      this.instructionTarget.textContent = 'Ваш картридж ' + cartridge.title;
      this.infoTarget.textContent = 'Возьмите его из коробки ' + cartridge.placement
                                  + '. Использованный картридж положите в коробку "На заправку"';
      this.cancelTarget.style.display = 'block';
      this.start_abort_timer();
      var abort_request = this.create_request('POST', 'abort', true);
      window.addEventListener('keydown', function(event){
        if (event.key == '.' || event.key == 'Delete') {
          abort_request.send('movement_id=' + cartridge.movement_id);
          alert('Смена картриджа отменена! Нажмите Enter чтобы продолжить');
          document.location.reload(true);
        }
      }, true);
    } else {
      this.instructionTarget.textContent = 'Ошибка! Картридж не найден';
      this.infoTarget.textContent = 'Возможно, подходящие картриджи закончились. '
                                  + 'Обратитесь к системному администратору или попробуйте снова. Страница будет перезагружена';
      setTimeout(function(){
        document.location.reload(true);
      }, 5000);
    }
  }

  which_device(devices) {
    this.start_reload_timer();
    this.instructionTarget.textContent = 'Введите порядковый номер принтера, которому требуется замена картриджа';
    var devices_str = '<div class="container"> <div class="row">';
    devices.forEach(function(device, i, devices) {
      devices_str += '<div class="col"><p><h1>' + (i + 1) + '</h1></p>'
                  + '<p><img src=' + device[3] + '></p>'
                  + device[1] + '</div>';
    });
    devices_str += '</div></div>'
    this.infoTarget.innerHTML = devices_str;
    window.devices = devices;
    window.which_device = true;
    this.clearInput();
  }

  start_abort_timer(sec = 10) {
    this.timerAbortTarget.innerHTML = 'Чтобы отменить действие нажмите клавишу Del(.)   Осталось ' + sec + ' секунд';
    setInterval(function(target) {
      sec--;
      target.innerHTML = 'Чтобы отменить действие нажмите клавишу Del(.)   Осталось ' + sec + ' секунд';
      if (sec < 1) {
        document.location.reload(true);
      }
    }, 1000, this.timerAbortTarget);
  }

  start_reload_timer(sec = 60) {
    if (!window.reloadTimerStarted) {
      window.reloadTimerStarted = true;
      this.timerReloadTarget.innerHTML = 'Автоматический выход через ' + sec +
                                         ' секунд <br> Для немедленного выхода нажмите минус(-)';
      setInterval(function(target) {
        sec--;
        target.innerHTML = 'Автоматический выход через ' + sec +
                           ' секунд <br> Для немедленного выхода нажмите минус(-)';
        if (sec < 1) {
          document.location.reload(true);
        }
      }, 1000, this.timerReloadTarget);
    }
  }

  create_request(http_method, url, async) {
    var request = new XMLHttpRequest();
    request.open(http_method, url, async);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    return request;
  }

  isKeyDown(event) {
    if (event.key == 'Enter') {
      if (window.unnumbered_room) {
        this.changeInput(true);
      } else {
        this.checkLocation(true);
      }
    }
    if (event.key == '-') {
      document.location.reload(true);
    }
  }

  clearInput() {
    this.inputTarget.value = '';
  }
}
