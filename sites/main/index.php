<?php

declare(strict_types=1);
require __DIR__ . "/../../vendor/autoload.php";

use FastRaven\Server;

// sitePath SHOULD ALWAYS BE __DIR__ unless you know what you are doing. Leave empty for the same value as preload.

// Environment preload.
Server::preload(__DIR__);

// Retrieve configuration, template and routers.
$config = Server::getConfiguration();
$template = Server::getTemplate();
$viewRouter = Server::getViewRouter();
$apiRouter = Server::getApiRouter();

// Server initialization.
$server = Server::createInstance();

// Server configuration.
$server->configure($config, $template, $viewRouter, $apiRouter);

// This is where the magic happens.
$server->run();