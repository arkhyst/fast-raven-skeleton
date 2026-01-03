<?php

declare(strict_types=1);
require __DIR__ . "/../../vendor/autoload.php";

use FastRaven\Server;
use FastRaven\Workers\Bee;
use FastRaven\Types\ProjectFolderType;

// Server initialization. sitePath SHOULD ALWAYS BE __DIR__ unless you know what you are doing.
$server = Server::initialize(__DIR__);

// Server configuration.
$server->configure(
    Server::getConfiguration(),
    Server::getTemplate(),
    Server::getViewRouter(),
    Server::getApiRouter(),
    Server::getCdnRouter()
);

require_once Bee::buildProjectPath(ProjectFolderType::CONFIG, "filters.php");

// This is where the magic happens.
$server->run();