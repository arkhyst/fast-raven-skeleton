<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;
use FastRaven\Components\Data\Collection;
use FastRaven\Components\Data\Item;

// View Router configuration. You can append a template to each view.
$viewRouter = Router::endpoints([
    Endpoint::view(false, "/", "main.html"),
    Endpoint::view(false, "/ping", "ping.html", Template::flex(title: "Ping test", autofill: Collection::new([
        Item::new("#api-result-span", "/api/ping")
    ])))
]);

return $viewRouter;

// If router gets to big, use Router::files() instead and refer to config/router folder.
// $viewRouter = Router::files(Collection::new([
//     Item::new("/", "main.php"),
//     Item::new("/admin", "admin.php"),
// ]));