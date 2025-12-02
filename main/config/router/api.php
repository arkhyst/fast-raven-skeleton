<?php

use SmartGoblin\Components\Routing\Endpoint;
use SmartGoblin\Components\Routing\Router;

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::endpoints([
    Endpoint::api(false, "GET","/health", "Health.php"),
    Endpoint::api(false, "GET","/ping", "Pong.php")
]);

return $apiRouter;

// If router gets to big, use Router::files() instead and refer to config/router files.
// $apiRouter = Router::files(["/v1" => "main.php", "/v2" => "new_version/main.php"]);

?>