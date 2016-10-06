angular.module('starter.controllers', [])
  .controller('AppCtrl', function ($scope, $ionicModal, $timeout, $location) {

    // With the new view caching in Ionic, Controllers are only called
    // when they are recreated or on app start, instead of every page change.
    // To listen for when this page is active (for example, to refresh data),
    // listen for the $ionicView.enter event:
    //$scope.$on('$ionicView.enter', function(e) {
    //});

    // Form data for the login modal
    $scope.loginData = {};
    // Create the login modal that we will use later
    /*$ionicModal.fromTemplateUrl('templates/login.html', {
     scope: $scope
     }).then(function(modal) {
     $scope.modal = modal;
     });*/

    // Triggered in the login modal to close it
    /*$scope.closeLogin = function() {
     $scope.modal.hide();
     };*/

    // Open the login modal
    /*$scope.login = function() {
     $scope.modal.show();
     };*/

    // Perform the login action when the user submits the login form
    $scope.doLogin = function () {
      $scope.loginData = {
        username: $scope.loginData.username,
        password: $scope.loginData.password
      };
      console.log('Doing login', $scope.loginData);
      if ($scope.loginData.username == 'admin' && $scope.loginData.password == 'admin') {
        $location.path("app/map");
      }
      else {
        $location.path("/");
      }
    };
  })

  .controller('BrowseCtrl', function ($scope, $location, $state) {
    $scope.mapData = {};

    $scope.depart = "Jean Macé";
    $scope.arrive = "Hôtel de Ville de Lyon, 1 Place de la Comédie, 69001 Lyon";
    //$scope.mapData = {};

    $scope.doMap = function () {
      $scope.mapData = {
        depart: $scope.depart,
        arrive: $scope.arrive
      };
      //console.log('Doing map', $scope.mapData);
      if ($scope.mapData.depart != '' && $scope.mapData.arrive != '') {
        $state.go('app.map',{ mapData: $scope.mapData });
        //$location.path("app/map",{mapData: $scope.mapData});
      }
      else {
        $location.path("/browse");
      }
    };
  })

  .controller('MapCtrl', function ($scope, $stateParams, $cordovaGeolocation ) {

    // console.log('Doing map1', $stateParams.mapData);
    var options = {timeout: 10000, enableHighAccuracy: true};

    $cordovaGeolocation.getCurrentPosition(options).then(function (position) {

      var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);

      var mapOptions = {
        center: latLng,
        zoom: 15,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      $scope.map = new google.maps.Map(document.getElementById("map"), mapOptions);

      var map = $scope.map;

      // var poly = $http.json(url);

      //Wait until the map is loaded
      google.maps.event.addListenerOnce($scope.map, 'idle', function () {

        // var flightPlanCoordinates = [
        //   {lat: 37.772, lng: -122.214},
        //   {lat: 21.291, lng: -157.821},
        //   {lat: -18.142, lng: 178.431},
        //   {lat: -27.467, lng: 153.027}
        // ];
        //
        // var flightPath = new google.maps.Polyline({
        //   path: poly.routes.overview_polyline.points,
        //   geodesic: true,
        //   strokeColor: '#FF0000',
        //   strokeOpacity: 1.0,
        //   strokeWeight: 2
        // });
        //
        // flightPath.setMap(map);

        var marker = new google.maps.Marker({
          map: $scope.map,
          animation: google.maps.Animation.DROP,
          position: latLng
        });

        var infoWindow = new google.maps.InfoWindow({
          content: "Here I am!"
        });

        google.maps.event.addListener(marker, 'click', function () {
          infoWindow.open($scope.map, marker);
        });
      });

    }, function (error) {
      console.log("Could not get location");
    });
  });
