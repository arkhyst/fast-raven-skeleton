<?php

declare(strict_types=1);
require __DIR__ . "/../vendor/autoload.php";

use SmartGoblin\Components\Core\Server;
use SmartGoblin\Components\Core\Config;
use SmartGoblin\Components\Core\Template;
use SmartGoblin\Components\Routing\Endpoint;
use SmartGoblin\Components\Routing\Router;

// Main Configuration. sitePath SHOULD ALWAYS BE __DIR__ unless you know what you are doing. siteName is NOT the subdomain.
$config = Config::new(__DIR__, "main", false);

// Which hosts are allowed to request the API.
$config->configureAllowedHosts(["127.0.0.1", "localhost"]);

// Cookie Session Configuration. Domain can be set to .domain.com to accept all subdomains inside your domain.
$config->configureAuthorization("YOURSESSIONNAME", 7, "localhost");

// Where to redirect if route not found.
$config->configureNotFoundRedirects("/");

// Where to redirect if not authorized. Leave subdomain empty to use the main domain. DO NOT USE a restricted site.
$config->configureUnauthorizedRedirects("/", "");

// Default template for all views.
$template = Template::new("Smart Site", "0.0.1", "en");

// View Router configuration. You can append a template to each view.
$viewRouter = Router::endpoints([
    Endpoint::view(false, "/", "main.html"),
    Endpoint::view(false, "/ping", "ping.html", Template::flex(title: "Ping test", autofill: [ 
            "#api-result-span" => "/api/ping"
        ]
    ))
]);

// API Router configuration. /api/ prefix is automatically added.
$apiRouter = Router::endpoints([
    Endpoint::api(false, "GET","/health", "Health.php"),
    Endpoint::api(false, "GET","/ping", "Pong.php")
]);

// If router gets to big, use Router::files() instead.
// $apiRouter = Router::files(["/v1" => "main.php", "/v2" => "new_version/main.php"]);

/* ------------------------------------------------------- */

// Server initialization.
$server = Server::new();

// Server configuration.
$server->configure($config, $template, $viewRouter, $apiRouter);

// This is where the magic happens.
$server->run();

?>