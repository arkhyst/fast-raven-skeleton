<?php

use SmartGoblin\Components\Core\Template;

use SmartGoblin\Workers\Bee;

// Default template for all views.
$template = Template::new("Smart Site", Bee::env("VERSION", "0.0.1"), "en");

return $template;

?>