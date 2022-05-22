export class Geolocator {
  constructor(submit) {
    var form = this.form = submit.form;
    this.fields = {
      latitude:  form.elements["latitude"],
      longitude: form.elements["longitude"],
      formatted: form.elements["formatted"],
    };

    var self = this;
    form.onsubmit = function() { return self.on_submit() };
  }

  set_position(position) {
    this.fields.latitude.value  = position.coords.latitude;
    this.fields.longitude.value = position.coords.longitude;
    var accuracy = Math.ceil(position.coords.accuracy);
    this.fields.formatted.value = "your position (" + accuracy + "m accuracy)";
  }

  is_position_set() {
    return this.fields.latitude.value.length > 0
        && this.fields.longitude.value.length > 0
        && this.fields.formatted.value.length > 0;
  }

  on_submit() {
    if (this.is_position_set()) {
      return true;
    }

    var self = this;
    setTimeout(function () { self.submit_attempt(); }, 1);
    return false;
  }

  submit_attempt() {
    var self = this;
    navigator.geolocation.getCurrentPosition(
      function (p) { self.geo_success(p) },
      function () { self.geo_failure() }
    );
  }

  geo_success(position) {
    this.set_position(position);
    return this.form.submit();
  }

  geo_failure() {
    alert("Unable to get your position.  Please try again, or use the search field instead.");
  }
};
