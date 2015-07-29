var app = angular.module("WbUtil", ["ngResource","ngMessages","ui.bootstrap"])
app.controller("InstallCert", ["$scope","$http", function($scope, $http) {
    $scope.issue_csr = function() {
        if ($scope.cn && $scope.cn.toLowerCase() == "wbfree01") {
            $scope.csr_result = { unusable: true };
            return;
        }
        $http.get("/csr", {params:{cn:$scope.cn}}).success(function(data) {
            $scope.csr_result = { success: true, data: data };
            $scope.refresh_status();
        }).error(function(data) {
            $scope.csr_result = { error: true};
        });
    }
    $scope.save_cert = function() {
        $http.post("/crt", $scope.cert, {headers:{"Content-Type":"text/plain"}}).success(function(data) {
            $scope.crt_result = data;
            if (data.success) {
                $scope.refresh_status();
                $scope.cert = "";
            }
        }).error(function(data) {
            $scope.crt_result = { error: true };
        });
    }
}]);
app.controller("BackupCert", ["$scope","$http", function($scope, $http) {
    $scope.get_pkcs12 = function() {
        $http.get("/pkcs12").success(function(data) {
            $scope.pkcs12_result = { success:true, data:data };
        }).error(function(data) {
            $scope.pkcs12_result = { error:true };
        });
    }
    $scope.restore_pkcs12 = function() {
        $http.post("/pkcs12", $scope.pkcs12_to_restore, {headers:{"Content-Type":"text/plain"}}).success(function(data) {
            $scope.pkcs12_restore_result = data;
            if (data.success) {
                $scope.refresh_status();
                $scope.pkcs12_to_restore = "";
            }
        }).error(function(data) {
            $scope.pkcs12_restore_result = {error:true};
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
            $scope.authorized_keys_result = data;
        }).error(function(data) {
            $scope.authorized_keys_result = {error: true};
        });
    }
}]);
app.run(["$rootScope", "$http", "$resource", function($scope, $http, $resource) {
    // screenshot
    $scope.take_screenshot = function() {
        $scope.screenshot_result = {loading: true};
        $http.get("/screenshot?t=" + new Date().getTime()).success(function(data){
            $scope.screenshot = data;
            $scope.screenshot_result = {success: true};
        }).error(function(data) {
            $scope.screenshot_result = {error: true};
        });
    }

    var status = $resource("/status");
    $scope.refresh_status = function() {
        $scope.status = status.get();
    }
    $scope.refresh_status();
}]);

