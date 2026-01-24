<?php

/**
 * OPcache Preload Script
 * 
 * This script is intended to be used with the opcache.preload php.ini directive.
 */
(function() {
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator(__DIR__ . "/../sites")
    );

    $count = 0;
    foreach ($iterator as $file) {
        if ($file->isFile() && $file->getExtension() === "php") {
            try {
                if (function_exists("opcache_compile_file")) {
                    opcache_compile_file($file->getRealPath());
                    $count++;
                }
            } catch (Throwable $e) {
                error_log("OPcache Preload Error: " . $e->getMessage() . " in " . $file->getRealPath());
            }
        }
    }
    error_log("OPcache Preload: Compiled $count files into OPcache.");
})();
