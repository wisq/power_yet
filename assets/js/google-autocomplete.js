export class GPAC {
  constructor(input) {
    this.input = input;
    this.options = {
      componentRestrictions: {country: 'ca'},
      bounds: {
        north: 45.584122,
        south: 44.935184,
        west: -76.382505,
        east: -75.174205
      },
      strictBounds: true,
      fields: ["geometry", "formatted_address"]
    };
    this.ac_input = new google.maps.places.Autocomplete(input, this.options);
    this.ac_service = new google.maps.places.AutocompleteService();
    this.geocoder = new google.maps.Geocoder();

    var form = input.form;
    this.fields = {
      latitude:  form.elements["latitude"],
      longitude: form.elements["longitude"],
      formatted: form.elements["formatted"],
    };

    var self = this;
    google.maps.event.addListener(this.ac_input, 'place_changed', function(e) {
      self.on_place_changed();
    });

    input.addEventListener("change", function () { self.clear_place() });

    input.form.onsubmit = function() { return self.on_submit() };
  }

  on_place_changed() {
    var place = this.ac_input.getPlace();

    if (place.geometry) {
      this.set_place(place);
    }
  }

  set_place(place) {
    var location = place.geometry.location;
    this.fields.latitude.value  = location.lat();
    this.fields.longitude.value = location.lng();
    this.fields.formatted.value = place.formatted_address;
  }

  clear_place() {
    this.fields.latitude.value  = "";
    this.fields.longitude.value = "";
    this.fields.formatted.value = "";
  }

  is_place_set() {
    return this.fields.latitude.value.length > 0
        && this.fields.longitude.value.length > 0
        && this.fields.formatted.value.length > 0;
  }

  on_submit() {
    if (this.is_place_set()) {
      return true;
    }

    var self = this;
    setTimeout(function () { self.submit_attempt(); }, 1);
    return false;
  }

  submit_attempt() {
    var address = this.input.value;
    if (address.length >= 1) {
      this.submit_autocomplete(this.input.value);
    } else {
      alert("Please enter a city, address, or postal code.");
    }
  }

  submit_failed() {
    var address = this.input.value;
    alert("Can't find address:\n\n" + address + "\n\nPlease search for an address within Ottawa.");
  }

  submit_autocomplete(address) {
    var query = Object.assign(this.options, {'input': address});

    var self = this;
    this.ac_service.getPlacePredictions(query, function(results, status) {
      if (status == 'OK') {
        var result = results[0];

        if (result.place_id) {
          return self.submit_place_id(result.place_id);
        }
      }
      return self.submit_failed();
    });
  }

  submit_place_id(place_id) {
    var self = this;
    this.geocoder.geocode({placeId: place_id}, function (results, status) {
      if (status == 'OK') {
        var place = results[0];

        if (place.geometry) {
          self.set_place(place);
          return self.input.form.submit();
        }
      }
      return self.submit_failed();
    });
  }
};
