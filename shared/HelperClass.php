<?php

namespace Shared;

use FastRaven\Workers\LogWorker;

/**
 * You can create custom classes in the shared folder that are available in all projects.
 */
final class HelperClass {
    public static function log(string $message): void {
        LogWorker::log("[HelloWorld!] $message");
    }
}
