<?php

use FastRaven\Components\Core\Config;

// Main Configuration. siteName is not the subdomain.
$config = Config::new("main", false);

// Cookie Session Configuration.
$config->configureAuthorization("YOURSESSIONNAME", 7, false);

// Redirect settings: notFound path, unauthorized path, subdomain (empty = main domain)
$config->configureRedirects("/", "/", "");

// Define whether to register logs or restrict what data to register.
$config->configurePrivacy(true, true);

// Configure rate-limiting per middleware type (VIEW, API, CDN). -1 = disabled.
$config->configureRateLimits(200, 200, 200);

// Configure input/file size limits in KB. -1 = disabled.
$config->configureLengthLimits(256, 5120);

// File-based cache settings. Set gcProbability to 0 to disable framework GC.
$config->configureCache(1, 50);

return $config;