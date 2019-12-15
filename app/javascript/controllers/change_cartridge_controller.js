import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'input', 'instruction', 'info', 'cancel', 'timer' ]

  connect() {
    window.which_device = false;
    var request = this.create_request('GET', 'get_locations', true);
    request.onload = function() {
      window.locations = JSON.parse(request.response);
    };
    request.send();
  }

  changeInput() {
    if (which_device) {
      var input = parseInt(this.inputTarget.value);
      ((input > 0) && (input <= window.devices.length)) ? this.move(window.devices[input-1]) : this.clearInput();
    } else {
      this.checkLocation(false);
    }
  }

  checkLocation(isEnter) {
    var inputLocation = this.inputTarget.value;
    var department = '';
    switch(inputLocation[0]) {
      case '/':
        department = 'orbeli';
        break;
      case '*':
        department = 'prosvet'
        break;
      default:
        department = 'sikeyrosa'
    }
    var room = Number(inputLocation.replace(/\D+/g,''));
    var location_found = false;
    var sub_room = 0;
    for (var i = 0; i < window.locations.length; i++) {
      if (room.toString() == window.locations[i].room.substring(0, room.toString().length)) {
        sub_room++;
        if (department == window.locations[i].department && room == window.locations[i].room) {
          location_found = true;
        }
      }
    }
    if (location_found && (sub_room == 1 || isEnter)) {
      this.get_devices(department, room);
    }
  }

  get_devices(department, room) {
    var type_id = 1;             // SET THIS VARIABLE ACCORDING TO YOUR DEVICE TYPE_ID IN TABLE OF TYPES
    var request = this.create_request('POST', 'get_devices', false);
    var devices = [];
    request.onload = function() {
      devices = JSON.parse(request.response);
    };
    request.send('type_id=' + type_id + '&department=' + department + '&room=' + room);
    if (devices.length == 1) {
      this.move(devices[0]);
    } else if (devices.length > 1) {
      this.which_device(devices);
    } else {
      this.clearInput();
      alert('В кабинете №' + room +' не найдено принтеров. Проверьте ввод или обратитесь к администратору.');
      document.location.reload(true);
    }
  }

  move(device) {
    var consumable_type_id = 1;  // SET THIS VARIABLE ACCORDING TO YOUR CONSUMABLE TYPE_ID IN TABLE OF CONSUMABLE TYPES
    var request = this.create_request('POST', 'move', false);
    var cartridge;
    request.onload = function() {
      cartridge = JSON.parse(request.response);
    };
    request.send('consumable_type_id=' + consumable_type_id + '&name_id=' + device[0] + '&location_id=' + device[2]);
    this.clearInput();
    this.inputTarget.style.display = 'none';
    if (cartridge.title) {
      this.instructionTarget.textContent = 'Ваш картридж ' + cartridge.title;
      this.infoTarget.textContent = 'Возьмите его из соответствующей коробки. Использованный картридж положите в коробку "На заправку"';
      this.cancelTarget.style.display = 'block';
      this.start_timer(10);
      var abort_request = this.create_request('POST', 'abort', true);
      window.addEventListener('keydown', function(event){
        if (event.key == 'Delete') {
          console.log(cartridge.movement_id);
          abort_request.send('movement_id=' + cartridge.movement_id);
          alert('Смена картриджа отменена!');
          document.location.reload(true);
        }
      }, true);
    } else {
      this.instructionTarget.textContent = 'Ошибка! Картридж не найден';
      this.infoTarget.textContent = 'Обратитесь к сетевому администратору или попробуйте снова. Страница будет перезагружена';
      setTimeout(function(){
        document.location.reload(true);
      }, 5000);
    }
  }

  which_device(devices) {
    this.instructionTarget.textContent = 'Введите порядковый номер принтера, которому требуется замена картриджа';
    var devices_str = '<div class="container"> <div class="row">';
    console.log(devices);
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

  start_timer(sec) {
    this.timerTarget.innerHTML = 'Чтобы отменить действие нажмите клавишу Del(.)   Осталось ' + sec + ' секунд';
    setInterval(function(target) {
      sec--;
      target.innerHTML = 'Чтобы отменить действие нажмите клавишу Del(.)   Осталось ' + sec + ' секунд';
      if (sec < 1) {
        document.location.reload(true);
      }
    }, 1000, this.timerTarget);
  }

  create_request(http_method, url, async) {
    var request = new XMLHttpRequest();
    request.open(http_method, url, async);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    return request;
  }

  isEnter(event) {
    if (event.key == 'Enter') {
      this.checkLocation(true);
    }
  }

  clearInput() {
    this.inputTarget.value = '';
  }
}
