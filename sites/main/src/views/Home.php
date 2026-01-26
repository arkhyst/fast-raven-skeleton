<?php

use FastRaven\Components\Core\Template;
use FastRaven\Components\Http\Request;

return function(Request $request, Template $baseTemplate): Template {
    $page = Template::new("main.php", $baseTemplate->getTitle());
    return $page;
};