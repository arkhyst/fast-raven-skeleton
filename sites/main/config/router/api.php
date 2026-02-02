<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Types\EndpointType;

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::new(EndpointType::API)
    ->add(Endpoint::api(false, "GET", "/health", "Health.php"))
    ->add(Endpoint::api(false, "POST", "/pong", "Pong.php"))
    ->add(Endpoint::api(false, "POST", "/autoauthorize", "AutoAuth.php"));

return $apiRouter;