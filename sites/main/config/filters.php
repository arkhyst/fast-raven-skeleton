<?php

use FastRaven\Workers\LogWorker;

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

$server->addStarter(function(Request $request) {
    LogWorker::log("This gets executed BEFORE Kernel::process() -- Check config/filters.php to remove this line.");
    // You can limit it to request types. 
    // if($request->getType() === MiddlewareType::API)
    // Or use Shared methods for more complex operations.
    // Shared\HelperClass::log("test");

    return true; // Return false to deny request processing
});

$server->addFinisher(function(Request $request, Response $response) { 
    LogWorker::log("This gets executed AFTER Kernel::process() -- Check config/filters.php to remove this line.");
    return true; // Return false to deny response sending
});