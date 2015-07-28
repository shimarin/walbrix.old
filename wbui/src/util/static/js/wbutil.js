var app = angular.module("WbUtil", ["ngResource","ui.bootstrap"])
app.controller("InstallCert", ["$scope","$http", function($scope, $http) {
    $scope.issue_csr = function() {
        $http.get("/csr", {params:{cn:$scope.cn}}).success(function(data) {
            $scope.csr = data;
            $scope.refresh_status();
        })
    }
    $scope.save_cert = function() {
        $http.post("/crt", $scope.cert, {headers:{"Content-Type":"text/plain"}}).success(function(data) {
            if (data.success) $scope.refresh_status();
        });
    }
}]);
app.controller("BackupCert", ["$scope","$http", function($scope, $http) {
    $scope.get_pkcs12 = function() {
        $http.get("/pkcs12").success(function(data) {
            $scope.pkcs12 = data;
        })
    }
    $scope.restore_pkcs12 = function() {
        $http.post("/pkcs12", $scope.pkcs12_to_restore, {headers:{"Content-Type":"text/plain"}}).success(function(data) {
            if (data.success) $scope.refresh_status();
        });
    }
}]);
app.controller("AuthorizedKeys", ["$scope","$http", function($scope, $http) {
    // authorized_keys
    $http.get("/authorized_keys").success(function(data){
        $scope.authorized_keys = data;
    });
    $scope.save_authorized_keys = function() {
        $http.post("/authorized_keys", $scope.authorized_keys, {headers:{"Content-Type":"text/plain"}}).success(function(data) {
            console.log(data);
        });
    }
}]);
app.run(["$rootScope", "$http", "$resource", function($scope, $http, $resource) {
    // screenshot
    $scope.loading_screenshot = false;
    $scope.take_screenshot = function() {
        $scope.loading_screenshot = true;
        $http.get("/screenshot").success(function(data){
            $scope.screenshot = data;
            $scope.loading_screenshot = false;
        });
    }

    var status = $resource("/status");
    $scope.refresh_status = function() {
        $scope.status = status.get();
    }
    $scope.refresh_status();
}]);

