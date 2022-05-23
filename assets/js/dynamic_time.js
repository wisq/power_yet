import moment from "moment"

moment.updateLocale('en', {
    calendar : {
        lastDay : '[yesterday at] LT',
        sameDay : '[today at] LT',
        nextDay : '[tomorrow at] LT',
        lastWeek : '[last] dddd [at] LT',
        nextWeek : 'dddd [at] LT',
        sameElse : 'L'
    }
});

class MomentCalendar {
  constructor(elem) {
    this.element = elem;
    this.moment = moment(elem.textContent.trim());

    var self = this;
    setTimeout(function () { self.update(); }, 1);
  }

  update() {
    this.element.textContent = this.moment.calendar();

    var self = this;
    setTimeout(function () { self.update(); }, 60000);
  }
};

export class DynamicTime {
  init_all() {
    const elems = document.getElementsByClassName("dynamic_time");

    for (let i = 0; i < elems.length; i++) {
      let elem = elems[i];

      if (elem.getAttribute("data-init") == null) {
        elem.setAttribute("data-init", true);
        this.createMoment(elem);
      }
    }
  }

  createMoment(elem) {
    let type = elem.getAttribute("data-dt-type");
    var moment = null;

    switch (type) {
      case "calendar":
        return new MomentCalendar(elem);

      default:
        console.log({error: "Unknown DynamicTime type", type: type})
        break;
    }
  }
};
