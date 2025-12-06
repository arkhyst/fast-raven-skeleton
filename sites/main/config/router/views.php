<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

// View Router configuration. You can append a template to each view.
$viewRouter = Router::endpoints([
    Endpoint::view(false, "/", "main.html"),
    Endpoint::view(false, "/ping", "ping.html", Template::flex(title: "Ping test", autofill: [ 
            "#api-result-span" => "/api/ping"
        ]
    ))
]);

return $viewRouter;

// If router gets to big, use Router::files() instead and refer to config/router folder.
// $apiRouter = Router::files(["/v1" => "main.php", "/v2" => "new_version/main.php"]);

?>