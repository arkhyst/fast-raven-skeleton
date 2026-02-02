<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Http\Request;
use FastRaven\Services\AuthService;

return function(Request $request, Template $baseTemplate): Template {
    AuthService::destroyAuthorization();

    $page = Template::new("ping.php", $baseTemplate->getTitle()." - Ping test");
    $page->addData("test", "This is a test");
    return $page;
};