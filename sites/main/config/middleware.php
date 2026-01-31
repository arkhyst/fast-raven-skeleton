<?php

use FastRaven\Services\LogService;

use FastRaven\Components\Http\Request;
use FastRaven\Components\Routing\Middleware;

// Create a new middleware holder instance.
$middleware = Middleware::new();

// Add a new available to use middleware.
$middleware->add("alwaysPass", function(Request $request): bool {
    LogService::log("This gets executed BEFORE endpoint execution -- Check config/middleware.php to remove this line.");
    // You can limit it to request types. 
    // if($request->getType() === EndpointType::API)
    // Or use Shared methods for more complex operations.
    // Shared\HelperClass::log("test");

    return true; // Return false to deny request processing
});

return $middleware;