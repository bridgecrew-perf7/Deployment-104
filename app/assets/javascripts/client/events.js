$(document).on('turbolinks:load', function(event) {
  var bodyId, initCategory, initGoogleMapEvent, initGoogleMapOrganizer, initSlick, set_category, updateLatLng;
  bodyId = $('body').attr('id');
  initSlick = function() {
    return $('#cover-slick').not('.slick-initialized').slick({
      infinite: true,
      dots: false,
      arrows: false,
      fade: true,
      autoplay: true,
      autoplaySpeed: 4000
    });
  };
  $('.category-filter').on('click', function() {
    var category_id;
    category_id = $(this).attr('data-filter');
    set_category(category_id);
    return false;
  });
  set_category = function(category_id) {
    var selected;
    if (category_id === void 0 || category_id === '0') {
      $('#event-section .event-list .event-wrapper').show();
    } else {
      $('#event-section .event-list .event-wrapper').not('.event-category-' + category_id).hide();
      $('#event-section .event-list .event-wrapper.event-category-' + category_id).show();
    }
    selected = $("[data-filter=" + category_id + "]");
    selected.parents('.nav').find('li').removeClass('active');
    return selected.parent().addClass('active');
  };
  initCategory = function() {
    var category_id;
    if (bodyId === "organizer-events-edit" || bodyId === "organizer-events-new") {
      return;
    }
    category_id = $("[name=category-id]").attr('content');
    if (category_id === "" || category_id === void 0) {
      return false;
    }
    set_category(category_id);
    return false;
  };
  initGoogleMapEvent = function() {
    var centerLocation, eventLocation, icon_map, info, infowindow, lat, lng, location_address, location_name, map, marker;
    lat = $("#google-map").attr('data-lat');
    lng = $("#google-map").attr('data-lng');
    location_name = $("#location").attr('data-location-name');
    location_address = $("#location").attr('data-location-address');
    if (lat === void 0 || lng === void 0) {
      return;
    }
    lat = parseFloat(lat);
    lng = parseFloat(lng);
    eventLocation = {
      lat: lat || 13.725275,
      lng: lng || 100.5871969
    };
    centerLocation = {
      lat: lat + 0.001,
      lng: lng
    };
    map = new google.maps.Map(document.getElementById('google-map'), {
      center: centerLocation,
      zoom: 16,
      scrollwheel: false,
      draggable: false,
      disableDoubleClickZoom: true
    });
    icon_map = {
      url: "" + ($("#google-map").attr('data-icon-map-pin')),
      scaledSize: new google.maps.Size(64, 76)
    };
    marker = new google.maps.Marker({
      position: eventLocation,
      map: map,
      icon: icon_map,
      title: 'Hello World!'
    });
    info = "<center> <h5>" + location_name + "</h5> <p>" + location_address + "</p> <p> <i class='icon icon-xs icon-direction-flag'></i> <a href=\"https://www.google.co.th/maps?q=loc:" + lat + "," + lng + "\" target=\"_blank\">View on Google Map</a> </p> </center>";
    infowindow = new google.maps.InfoWindow({
      content: info
    });
    return infowindow.open(map, marker);
  };
  initGoogleMapEvent();
  initSlick();
  initCategory();
  initGoogleMapOrganizer = function() {
    var addMarker, dLat, dLng, hideMarkers, input, map, markers, searchBox;
    dLat = parseFloat($('#event_latitude').val()) || 13.7563309;
    dLng = parseFloat($('#event_longitude').val()) || 100.50176510000006;
    map = new google.maps.Map(document.getElementById('organizer-map'), {
      center: {
        lat: dLat,
        lng: dLng
      },
      zoom: 13,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    markers = [];
    input = document.getElementById('pac-input');
    searchBox = new google.maps.places.SearchBox(input);
    map.addListener('idle', function() {
      addMarker(new google.maps.LatLng(dLat, dLng));
    });
    hideMarkers = function() {
      var i;
      i = 0;
      while (i < markers.length) {
        markers[i].setMap(null);
        i++;
      }
    };
    addMarker = function(location) {
      var marker;
      hideMarkers();
      markers = [];
      marker = new google.maps.Marker({
        position: location,
        map: map,
        draggable: true
      });
      markers.push(marker);
      updateLatLng(location.lat(), location.lng());
      marker.addListener('dragend', function(event) {
        updateLatLng(event.latLng.lat(), event.latLng.lng());
      });
    };
    map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
    map.addListener('bounds_changed', function() {
      searchBox.setBounds(map.getBounds());
    });
    map.addListener('click', function(event) {
      addMarker(event.latLng);
    });
    searchBox.addListener('places_changed', function() {
      var bounds, places;
      places = searchBox.getPlaces();
      if (places.length === 0) {
        return;
      }
      bounds = new google.maps.LatLngBounds;
      places.forEach(function(place) {
        var icon;
        icon = {
          url: place.icon,
          size: new google.maps.Size(71, 71),
          origin: new google.maps.Point(0, 0),
          anchor: new google.maps.Point(17, 34),
          scaledSize: new google.maps.Size(25, 25)
        };
        addMarker(place.geometry.location);
        if (place.geometry.viewpor) {
          bounds.union(place.geometry.viewport);
        } else {
          bounds.extend(place.geometry.location);
        }
      });
      map.fitBounds(bounds);
    });
  };
  updateLatLng = function(lat, lng) {
    $('#event_latitude').val(lat);
    $('#event_longitude').val(lng);
  };
  if ($("#organizer-events-new").html() !== void 0 || $("#organizer-events-edit").html() !== void 0 || $("#profile-settings-section").html() !== void 0) {
    initGoogleMapOrganizer();
  }
  if (bodyId === "organizer-events-new") {
    return onTicketAdd();
  }
});
