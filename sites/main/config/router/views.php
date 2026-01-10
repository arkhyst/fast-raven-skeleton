<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Routing\Endpoint;
use FastRaven\Components\Routing\Router;

use FastRaven\Components\Data\Collection;
use FastRaven\Components\Data\Item;

use FastRaven\Types\EndpointType;

// View Router configuration. You can append a template to each view.
$viewRouter = Router::new(EndpointType::VIEW)
    ->add(Endpoint::view(false, "/", "main.html"))
    ->add(Endpoint::view(false, "/ping", "ping.html", Template::flex(title: "Ping test", autofill: Collection::new([
        Item::new("#api-result-span", "/api/ping")
    ]))));

return $viewRouter;