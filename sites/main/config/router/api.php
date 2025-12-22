<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::endpoints([
    Endpoint::api(false, "GET","/health", "Health.php"),
    Endpoint::api(false, "GET","/ping", "Pong.php")
]);

return $apiRouter;

// If router gets to big, use Router::files() instead and refer to config/router folder.
// $apiRouter = Router::files(Collection::new([
//     Item::new("/v1", "main.php"),
//     Item::new("/v2", "new_version/main.php"),
// ]));