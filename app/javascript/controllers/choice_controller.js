import { Controller } from 'stimulus'
import Choices from 'choices.js'

export default class extends Controller {
  static targets = [ 'select1', 'select2', 'select3', 'selectMulti', 'selectNoSearch' ]

  connect() {
    if (this.hasSelect1Target) {
      this.choice(this.select1Target, false, true);
    }

    if (this.hasSelect2Target) {
      this.choice(this.select2Target, false, true);
    }

    if (this.hasSelect3Target) {
      this.choice(this.select3Target, false, true);
    }

    if (this.hasSelectMultiTarget) {
      this.selectMultiTarget.parentNode.classList.add('choices__multi')
      this.choice(this.selectMultiTarget, true, true);
    }

    if (this.hasSelectNoSearchTarget) {
      this.choice(this.selectNoSearchTarget, false, false);
    }
  }

  choice(target, multi, search) {
    new Choices(target, {
        searchResultLimit: 30,
        position: 'bottom',
        itemSelectText: '',
        removeItemButton: multi,
        searchEnabled: search
    });
  }
}
