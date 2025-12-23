<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::endpoints([
    Endpoint::api(false, "GET","/health", "Health.php"),
    Endpoint::api(false, "GET","/ping", "Pong.php")
]);

return $apiRouter;