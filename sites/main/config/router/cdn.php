<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Types\MiddlewareType;

// CDN Router configuration. /cdn/ prefix is automatically added.
$cdnRouter = Router::new(MiddlewareType::CDN)
    ->add(Endpoint::cdn(false, "GET","/favicon", "Favicon.php"));

return $cdnRouter;