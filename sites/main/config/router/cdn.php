<?php

use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

// CDN Router configuration. /cdn/ prefix is automatically added.
$cdnRouter = Router::cdn([
    Endpoint::cdn(false, "GET","/favicon", "Favicon.php"),
]);

return $cdnRouter;