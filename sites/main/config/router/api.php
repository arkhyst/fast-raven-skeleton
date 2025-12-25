<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Types\MiddlewareType;

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::new(MiddlewareType::API)
    ->add(Endpoint::api(false, "GET","/health", "Health.php"))
    ->add(Endpoint::api(false, "GET","/ping", "Pong.php"));

return $apiRouter;