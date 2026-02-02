<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;

use FastRaven\Services\LogService;

return function(Request $request): Response {
    LogService::log("Health API call was processed successfully");
    return Response::new(true, 200);
};