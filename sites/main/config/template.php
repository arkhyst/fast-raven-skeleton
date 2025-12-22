<?php

use FastRaven\Components\Core\Template;

use FastRaven\Workers\Bee;

// Default template for all views.
$template = Template::new("Fast Raven Site", Bee::env("VERSION", "0.0.1"), "en");

return $template;