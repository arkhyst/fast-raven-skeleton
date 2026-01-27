<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Http\Request;

return function(Request $request, Template $baseTemplate): Template {
    $page = Template::new("ping.php", $baseTemplate->getTitle()." - Ping test");
    $page->addData("test", "This is a test");
    return $page;
};