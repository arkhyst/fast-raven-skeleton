<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Http\Request;
use FastRaven\Components\Data\Item;

return function(Request $request, Template $baseTemplate): Template {
    $page = Template::new("ping.php", $baseTemplate->getTitle()." - Ping test");
    $page->addData(Item::new("test", "This is a test"));
    return $page;
};