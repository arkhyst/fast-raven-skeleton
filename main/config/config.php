<?php

use SmartGoblin\Components\Core\Config;

use SmartGoblin\Workers\Bee;

// Main Configuration. siteName is not the subdomain.
$config = Config::new("main", false);

// Which hosts are allowed to request the API.
$config->configureAllowedHosts([Bee::env("SITE_ADDRESS", "localhost")]);

// Cookie Session Configuration. Domain can be set to .domain.com to accept all subdomains inside your domain.
$config->configureAuthorization("YOURSESSIONNAME", 7, Bee::env("SITE_ADDRESS", "localhost"));

// Where to redirect if route not found.
$config->configureNotFoundRedirects("/");

// Where to redirect if not authorized. Leave subdomain empty to use the main domain. DO NOT USE a restricted site.
$config->configureUnauthorizedRedirects("/", "");

return $config;

?>