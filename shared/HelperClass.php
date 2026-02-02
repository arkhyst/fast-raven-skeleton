<?php

namespace Shared;

use FastRaven\Services\LogService;

/**
 * You can create custom classes in the shared folder that are available in all projects.
 */
final class HelperClass {
    public static function log(string $message): void {
        LogService::log("[HelloWorld!] $message");
    }
}
